library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity DFTSumCorrelation is
	generic (
        input_width                 : natural   := 512; -- elements
        input_word_length           : natural   := 16;  -- bits
        sinusoid_word_length        : natural   := 16   -- bits
	);
	port (
        clk		        : in std_logic;
        -- inputs
        x               : in signed(input_word_length-1 downto 0);
        yn              : in signed(sinusoid_word_length-1 downto 0);
        c_sum_in        : in signed(input_word_length + natural(ceil(log2(real(input_width))))-1 downto 0);
        -- outputs
        c_sum_out       : out signed(input_word_length + natural(ceil(log2(real(input_width))))-1 downto 0)
	);
end entity;

architecture rtl of DFTSumCorrelation is
    
begin
    
    main: process(clk)
        variable v_mult     : signed(input_word_length + sinusoid_word_length -1 downto 0);
        variable v_c_sum    : signed(c_sum_in'range);
    begin
        if rising_edge(clk) then
            v_mult := x * yn;
            v_c_sum := v_mult(x'length-1 + sinusoid_word_length-1 downto sinusoid_word_length-1)
                        + c_sum_in;
            v_c_sum := c_sum_in + v_c_sum(x'range);

            c_sum_out <= v_c_sum;
        end if;
    end process main;
    
end architecture rtl;