library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use STD.textio.all;

library work;
use work.DFTTypes.all;

entity DFTChannelLinkModules_TestBench is
    port (
        placeholder         : out std_logic
    );
end entity;

architecture test of DFTChannelLinkModules_TestBench is

    constant    CLK_PERIOD  : time      := 10 ns;
    signal      clk         : std_logic := '0';
    signal      rst         : std_logic := '0';

    -- wiring
    signal yn                   : signed_fxp_sinusoid;

    -- test signals
    signal  t_x                  : signal_word; -- input element
    signal  t_cos_w_in           : signed_fxp_sinusoid;
    signal  t_yn1_in             : signed_fxp_sinusoid; -- 16, sine precision
    signal  t_yn2_in             : signed_fxp_sinusoid;
    signal  t_prev_sum_in        : signed_correlation_sum;

    signal c_sum_out             : signed_correlation_sum;

    component DFTGenerateReference is
        port (
            clk		        : in std_logic;
            rst             : in std_logic;
    
            -- inputs from previous link
            cos_w           : in signed_fxp_sinusoid;
            yn1             : in signed_fxp_sinusoid;
            yn2             : in signed_fxp_sinusoid;
            -- outputs
            cos_w_out       : out signed_fxp_sinusoid;
            yn1_out         : out signed_fxp_sinusoid;
            yn              : out signed_fxp_sinusoid
        );
    end component DFTGenerateReference;

    component DFTSumCorrelation is
        port (
            clk		        : in std_logic;
            rst             : in std_logic;

            -- inputs
            x               : in signal_word;
            yn              : in signed_fxp_sinusoid;
            c_sum_in        : in signed_correlation_sum;
            -- outputs
            c_sum_out       : out signed_correlation_sum
        );
    end component DFTSumCorrelation;


    constant word_length    : natural := c_sum_out'length;
    signal a                : signed(word_length-1 downto 0);
    signal b                : signed(word_length-1 downto 0);
    signal magnitude        : unsigned(word_length+1 -1 downto 0);

    component DFTMagnitude is
        generic (
            word_length		: natural	:= 16 -- bits
        );
        port (
            clk				: in std_logic;
            rst				: in std_logic;
    
            -- inputs
            a				: in signed(word_length-1 downto 0);
            b				: in signed(word_length-1 downto 0);
            -- outputs
            magnitude		: out unsigned(word_length+1 -1 downto 0)
        );
    end component DFTMagnitude;

begin
    RefStage : DFTGenerateReference
        port map (
            clk	=> clk,
            rst => rst,
            -- inputs from previous link
            cos_w => t_cos_w_in,
            yn1 => t_yn1_in,
            yn2 => t_yn2_in,
            -- outputs
            cos_w_out => open, -- goes to next in pipeline
            yn1_out => open,
            yn => yn
        );

    SumStage : DFTSumCorrelation
        port map (
            clk	=> clk,
            rst => rst,
            -- inputs
            x => t_x,
            yn => yn,
            c_sum_in => t_prev_sum_in,
            -- outputs
            c_sum_out => c_sum_out
        );

    MagnitudeStage : DFTMagnitude
        generic map (
            word_length => word_length
        )
        port map (
            clk	=> clk,
            rst	=> rst,

            -- inputs
            a => a,
            b => b,
            -- outputs
            magnitude => magnitude
        );

    test_magnitude: process
    begin
        a <= to_signed(2 ** 15, a'length);
        b <= to_signed(-2 ** 15, a'length);
        
        wait for CLK_PERIOD;

        assert (magnitude = to_unsigned(49152, magnitude'length))
            report "magnitude incorrect" severity warning;


        a <= to_signed(-1, a'length);
        b <= to_signed(-1, a'length);
        
        wait for CLK_PERIOD;

        assert (magnitude = to_unsigned(1, magnitude'length))
            report "magnitude incorrect" severity warning;


        a <= to_signed(0, a'length);
        b <= to_signed(-1, a'length);
        
        wait for CLK_PERIOD;

        assert (magnitude = to_unsigned(1, magnitude'length))
            report "magnitude incorrect" severity warning;


    end process test_magnitude;

    -- https://www.nandland.com/vhdl/examples/example-file-io.html
    -- unit_test: process
    --     variable x_line         : line;
    --     variable file_SIGNAL    : file;
    -- begin

    --     -- feed inputs: y[n-1], y[n-2], (cosw, -sinw)
    --     -- check outputs: y[n], 

    --     -- feed inputs: x,
    --     -- check outputs: c
    --     -- (sum in process, as well)

    --     file_open(file_SIGNAL, "io/int16_signal.txt", read_mode);

    --     while not endfile(file_SIGNAL) loop
    --         readline(file_SIGNAL, x_line);
    --     end loop;

    --     file_close(file_SIGNAL);

    -- end process unit_test;
    
    unit_test: process
    begin
        -- Configuration
        -- Using default generic values (16-bit sinusoid representation, 16-bit word x,
        -- 512 elements in x).

        -- For the first sample in a cosine of k=20:
        -- y[n-1] = 1       => 32767
        -- y[n-2] = cos(-wk)=> 31785
        -- cos(wk)= cos(wk) => 31785

        -- Let:
        -- c[k] = 0
        -- x[n] = 20100
        -- We expect:
        -- y[n] = 31785 after one clk
        -- c[k] = 19497 after two clk

        
        
        t_yn1_in <= to_signed(32767, signed_fxp_sinusoid'length);
        t_yn2_in <= to_signed(31785, signed_fxp_sinusoid'length);
        t_cos_w_in <= to_signed(31785, signed_fxp_sinusoid'length);

        wait for CLK_PERIOD;
        assert (yn = 31785) report "yn incorrect" severity warning;
        t_x <= to_signed(20100, signal_word'length);
        t_prev_sum_in <= (others => '0');
        
        wait for CLK_PERIOD;
        assert (c_sum_out = 19497) report "c_sum_out incorrect" severity warning;


        -- For the first sample in a sine of k=193:
        -- y[n-1] = 0
        -- y[n-2] = -22883
        -- cos(wk)= -23452

        -- Let:
        -- c[k] = 479*2^15 = 14745600
        -- x[n] = -32767
        -- We expect:
        -- y[n] = 22884 after one clk
        -- c[k] = c[k] + -22883 = 14722717 after two clk
        wait for CLK_PERIOD; -- flush pipeline

        t_yn1_in <= to_signed(0, signed_fxp_sinusoid'length);
        t_yn2_in <= to_signed(-22883, signed_fxp_sinusoid'length);
        t_cos_w_in <= to_signed(-23452, signed_fxp_sinusoid'length);

        wait for CLK_PERIOD;
        assert (yn = 22884) report "yn incorrect" severity warning;
        
        t_x <= to_signed(-32767, signal_word'length);
        t_prev_sum_in <= to_signed(14745600, t_prev_sum_in'length);
        
        wait for CLK_PERIOD;
        assert (c_sum_out = 14722717) report "c_sum_out incorrect" severity warning;

        -- -- For sample n=479 in a cosine of k=193:
        -- -- y[n-1] = 29956
        -- -- y[n-2] = -30714
        -- -- cos(wk)= 22884

        -- -- Let:
        -- -- c[k] = 479*2^15 = 14745600
        -- -- x[n] = -32768
        -- -- We expect:
        -- -- y[n] = -12167 after one clk
        -- -- c[k] = c[k] + 12167 = 15708039 after two clk
        -- wait for CLK_PERIOD; -- flush pipeline

        -- t_yn1_in <= to_signed(29956, sinusoid_word_length);
        -- t_yn2_in <= to_signed(-30714, sinusoid_word_length);
        -- t_cos_w_in <= to_signed(22884, sinusoid_word_length);

        -- wait for CLK_PERIOD;
        -- assert (yn = -7571) report "yn incorrect" severity warning;
        
        -- t_x <= to_signed(-32768, input_word_length);
        -- t_prev_sum_in <= to_signed(14745600, t_prev_sum_in'length);
        
        -- wait for CLK_PERIOD;
        -- assert (c_sum_out = 15708039) report "c_sum_out incorrect" severity warning;
        
        wait;
    end process unit_test;


    clk <= not clk after CLK_PERIOD/2;

    placeholder <= clk; -- must be present for synthesiser to not optimise entity away

end test;