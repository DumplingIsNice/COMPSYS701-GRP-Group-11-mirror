library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package data_type_package is
    type data_array is array(natural range <>) of std_logic_vector(15 downto 0);
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type_package.all;
library work;
use work.TdmaMinTypes.all;

entity TopLevel is
	generic (
		N : integer := 8;
		M : integer := 2;
		row : integer := 8
	);
	port (
		CLOCK_50		: in std_logic;
		recv 			: in tdma_min_port;
		send 			: out tdma_min_port
		);
end entity TopLevel;

architecture behaviour of TopLevel is 

	signal data_read 	: std_logic := '1';
	signal data_write : std_logic;
	signal data_in 	: data_array(0 to row-1);
	signal data_out 	: data_array(0 to M-1);
	
begin
	
	process(CLOCK_50) 
	begin
		if(rising_edge(CLOCK_50)) then
			for index in 0 to row-1 loop
				data_in(index) <= std_logic_vector(to_signed(2,16));
			end loop;
		end if;
	end process;
	
	DP_D : entity work.DP_D
		generic map (
			N => N,
			M => M,
			row => row
		)
		port map (
			clock => CLOCK_50,
			data_read => data_read,
			data_write => data_write, 
			data_in => data_in, 
			data_out => data_out
		);
	
end architecture behaviour;