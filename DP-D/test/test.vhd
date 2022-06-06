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

entity test is 
	generic (
		N : integer := 8;
		M : integer := 2;
		row : integer := 8
	);
end entity;

architecture sim of test is 
	signal clock : std_logic;
	signal data_read : std_logic := '1';
	signal data_write : std_logic;
	signal data_in : data_array(0 to row-1);
	signal data_out : data_array(0 to M-1);
	
begin
  clk_gen : process
  begin
      wait for 10ns;
      clock <= '1';
      wait for 10ns;
      clock <= '0';
  end process clk_gen;
  
  
  initialise : for i in 0 to N-1 generate
     data_in(i) <= std_logic_vector(to_signed(255, 16));
  end generate;   
    
	DP_D : entity work.DP_D
	generic map (
		N => N,
		M => M,
		row => row
	)
	port map (
		clock => clock,
		data_read => data_read,
		data_write => data_write, 
		data_in => data_in, 
		data_out => data_out
	);
	
end architecture sim;