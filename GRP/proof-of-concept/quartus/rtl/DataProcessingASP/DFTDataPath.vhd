library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;
use work.DFTSinusoidLUT.all;

entity DFTDataPath is
    port (
        clk					: in std_logic;
        rst					: in std_logic;

        -- control
        enable				: in std_logic; -- value of x must change each clk cycle - disable to stall operation
        rst_sinusoid		: in std_logic; -- reset sinusoid approximation and contents, but keep c_sum in pipeline
        update_output       : in std_logic; -- update magnitudes register

        -- inputs
        x					: in signal_word;
        -- outputs
        magnitudes			: out magnitudes_array;
        output_updated      : out std_logic -- pulses a tick after update_output is received
    );
end entity DFTDataPath;

architecture rtl of DFTDataPath is

    -- each k is a harmonic to evaluate
    -- each k requires a pair of values: cos(-wk), sin(-wk)

    signal working_magnitudes   : magnitudes_array	:= (others => (others => '0'));

    component DFTDataPathUnit is
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            -- control
            restart			: in std_logic;
            -- inputs
            cos_w_LUT       : in signed_fxp_sinusoid;
            yn1_LUT         : in signed_fxp_sinusoid;
            yn2_LUT         : in signed_fxp_sinusoid;
            x               : in signal_word;
            -- outputs
            c_sum           : out signed_correlation_sum
        );
    end component DFTDataPathUnit;

    component DFTMagnitude is
        generic (
            word_length		: natural
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

    signal  sinusoid_clk    : std_logic;

begin

    sinusoid_clk <= clk and enable;

    main: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                
            else

            end if;
        end if;
    end process main;

    UPDATE_MAGNITUDES: process(clk)
    begin
        if rising_edge(clk) then
                if rst = '1' then
                    magnitudes <= (others => (others => '0'));
                else
                    if update_output = '1' then
                        magnitudes <= working_magnitudes;
                    end if;
                end if;
        end if;
    end process UPDATE_MAGNITUDES;

    UPDATED_SIGNAL: process(clk)
        variable prev_update_output : std_logic := '0';
    begin
        if rising_edge(clk) then
            if rst = '1' then
                prev_update_output := '0';
                output_updated <= '0';
            else
                output_updated <= prev_update_output;
                prev_update_output := update_output;
            end if;
        end if;
    end process UPDATED_SIGNAL;

    GEN_UNITS: for k in 0 to K_LENGTH-1 generate
        signal c_sum_re         : signed_correlation_sum := (others => '0');
        signal c_sum_im         : signed_correlation_sum := (others => '0');
        signal magnitude        : unsigned(signal_word'length downto 0);
    begin

        ReCosUnit: entity work.DFTDataPathUnit
            port map (
                clk => sinusoid_clk,
                rst => rst,
                -- control
                restart => rst_sinusoid,
                -- inputs
                cos_w_LUT => K_SINUSOID_LUT(K_SINUSOID_LUT'length-1 - 2*k),
                yn1_LUT => to_signed(2**15 -1, signed_fxp_sinusoid'length),
                yn2_LUT => K_SINUSOID_LUT(K_SINUSOID_LUT'length-1 - 2*k),
                x => x,
                -- outputs
                c_sum => c_sum_re
            );

        ImSinUnit: entity work.DFTDataPathUnit
            port map (
                clk => sinusoid_clk,
                rst => rst,
                -- control
                restart => rst_sinusoid,
                -- inputs
                cos_w_LUT => K_SINUSOID_LUT(K_SINUSOID_LUT'length-1 - 2*k),
                yn1_LUT => to_signed(0, signed_fxp_sinusoid'length),
                yn2_LUT => K_SINUSOID_LUT(K_SINUSOID_LUT'length-1 - (2*k)-1),
                x => x,
                -- outputs
                c_sum => c_sum_im
            );

        ApproximateMagnitude : entity work.DFTMagnitude
            generic map (
                word_length => signal_word'length
            )
            port map (
                clk	=> sinusoid_clk,
                rst	=> rst,

                -- inputs
                a => c_sum_re(c_sum_re'length-1 downto c_sum_re'length - signal_word'length), -- shift right by log2(WINDOW_WIDTH)
                b => c_sum_im(c_sum_im'length-1 downto c_sum_im'length - signal_word'length), -- shift right by log2(WINDOW_WIDTH)
                -- outputs
                magnitude => magnitude
            );
        
        -- divide to input size (NOTE: magnitude is now proportional ONLY, must be scaled to original value!)
        working_magnitudes(k) <= signed(magnitude(magnitude'length-1 downto magnitude'length - signal_word'length));
    end generate GEN_UNITS;

end architecture rtl;