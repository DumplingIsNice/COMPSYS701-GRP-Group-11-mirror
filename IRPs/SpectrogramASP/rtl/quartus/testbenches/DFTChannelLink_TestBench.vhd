library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity DFTChannelLink_TestBench is
    generic (
        input_width         : natural   := 512; -- elements
        input_word_length   : natural   := 16;  -- bits
        sinusoid_word_length: natural   := 16   -- bits
    );
    port (
        placeholder         : out std_logic
    );
end entity;

architecture test of DFTChannelLink_TestBench is

    constant    CLK_PERIOD  : time      := 10 ns;
    signal      clk         : std_logic := '0';
    signal      t_rst       : std_logic := '1';

    -- signals
    signal  t_x                  : signed(input_word_length-1 downto 0); -- input element
    signal  t_cos_w_in           : signed(sinusoid_word_length-1 downto 0);
    signal  t_yn1_in             : signed(sinusoid_word_length-1 downto 0); -- 16, sine precision
    signal  t_yn2_in             : signed(sinusoid_word_length-1 downto 0);
    signal  t_prev_sum_in        : signed(input_word_length +1 + natural(ceil(log2(real(input_width)))) -1 downto 0);


    component DFTChannelLink
        generic (
            input_width         : natural   := 512; -- elements
            input_word_length   : natural   := 16;  -- bits
            sinusoid_word_length: natural   := 16   -- bits
        );
        port (
            clk	    	    : in std_logic;
            rst		        : in std_logic;
    
            -- static input
            x               : in signed(input_word_length-1 downto 0); -- input element
            -- inputs from previous link
            cos_w_in        : in signed(sinusoid_word_length-1 downto 0);
            yn1_in          : in signed(sinusoid_word_length-1 downto 0); -- 16, sine precision
            yn2_in          : in signed(sinusoid_word_length-1 downto 0);
            prev_sum_in     : in signed(input_word_length +1 + natural(ceil(log2(real(input_width)))) -1 downto 0);
            -- outputs
            cos_w_out       : out signed(sinusoid_word_length-1 downto 0);
            yn_out          : out signed(sinusoid_word_length-1 downto 0);
            yn1_out         : out signed(sinusoid_word_length-1 downto 0);
            sum             : out signed(input_word_length +1 + natural(ceil(log2(real(input_width)))) -1 downto 0); -- 16 + log2(input_width)
            done            : out std_logic
        );
    end component DFTChannelLink;

begin

    ExampleLink : DFTChannelLink
        port map (
            clk => clk,
            rst => t_rst,

            x => t_x,
            cos_w_in => t_cos_w_in,
            yn1_in => t_yn1_in,
            yn2_in => t_yn2_in,
            prev_sum_in => t_prev_sum_in,

            cos_w_out => open,
            yn_out => open,
            yn1_out => open,
            sum => open,
            done => open
        );

    -- TODO: read from file, check word length correct?

    -- for first sample in a cosine of k=20 for #samples=512:
    -- y[n-1] = 1 => 32767
    -- y[n-2] = cos(-wk) = cos(-2*pi*k/#samples) => 31785
    -- cos(wk) = cos(2*pi*k/#samples) => 31785
    -- where values are scaled  and truncated to an int with amplitude 2^15 -1
    t_x <= to_signed(20100, input_word_length);
    t_cos_w_in <= to_signed(31785, sinusoid_word_length);
    t_yn1_in <= to_signed(32767, sinusoid_word_length);
    t_yn2_in <= to_signed(31785, sinusoid_word_length);
    t_prev_sum_in <= (others => '0');

    clk <= not clk after CLK_PERIOD/2;
    t_rst <= '0' after CLK_PERIOD;

    placeholder <= '1'; -- must be present for synthesiser to not optimise entity away

end test;