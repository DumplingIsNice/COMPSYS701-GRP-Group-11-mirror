library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.TdmaMinTypes.all;

entity PipConfig is
	generic (stages : positive
	);
	port (clock : in std_logic;
			data_ctrl : in std_logic_vector(7 downto 0);
			data_i_sel, data_o_sel : out std_logic_vector(stages-1 downto 0)
	);
end entity; 


architecture behaviour of PipConfig is

begin

	process(clock)
		begin
		
			-- based on ctrl input from recop, select data i and o signals for memory	
				
	end process;


end architecture;
