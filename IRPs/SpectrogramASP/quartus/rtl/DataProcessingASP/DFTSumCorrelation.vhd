library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;

entity DFTSumCorrelation is
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
end entity;

architecture rtl of DFTSumCorrelation is
    
begin
    
    main: process(clk)
        variable v_mult     : signed(signal_word'length + signed_fxp_sinusoid'length -1 downto 0)  := (others => '0');
        variable v_c_sum    : signed(c_sum_in'range)    := (others => '0');
    begin
        if rising_edge(clk) then
            if rst = '1' then
                v_mult  := (others => '0');
                v_c_sum := (others => '0');
            else
                v_mult := x * yn;
                v_c_sum := v_mult(x'length-1 + signed_fxp_sinusoid'length-1 downto signed_fxp_sinusoid'length-1)
                            + c_sum_in;
                v_c_sum := c_sum_in + v_c_sum(x'range);
            end if;

            c_sum_out <= v_c_sum;
        end if;
    end process main;
    
end architecture rtl;