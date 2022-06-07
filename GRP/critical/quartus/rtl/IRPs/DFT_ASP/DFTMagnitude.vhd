library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity DFTMagnitude is
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
		magnitude		: out unsigned(word_length+1-1 downto 0)
			-- extra bit since we are adding two values
	);
end entity DFTMagnitude;

architecture rtl of DFTMagnitude is
	
begin
	
	main: process(clk)
		variable max	: unsigned(a'range);
		variable min	: unsigned(a'range);
		variable v_mag	: unsigned(magnitude'range) := (others => '0');	
	begin
		-- Note that this can be compiled as a combinatorial process,
		-- as we do not store any values. Output will be on the same rising edge, no delay!
		if rising_edge(clk) then
			if rst = '1' then
				v_mag	:= (others => '0');
			else
				if abs(a) > abs(b) then
					max := unsigned(abs(a));
					min := unsigned(abs(b));
				else
					max := unsigned(abs(b));
					min := unsigned(abs(a));
				end if;

				v_mag := resize(max + unsigned('0' & min(a'length-1 downto 1)), v_mag'length);
			end if;

			magnitude <= v_mag;
		end if;
	end process main;
	
	
end architecture rtl;