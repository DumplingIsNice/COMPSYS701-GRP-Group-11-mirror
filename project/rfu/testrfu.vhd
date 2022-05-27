library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.TdmaMinTypes.all;

entity testrfu is
end entity testrfu;

architecture sim of testrfu is
	signal clock : std_logic := '1';
	signal send  : tdma_min_port;
	signal recv  : tdma_min_port;
	signal irq : std_logic;
	signal clr_irq : std_logic;
	
	
	begin
	recv.data(31 downto 0) <= "00000000000000000000000000000000";
	recv.data(23 downto 20) <= "1000" after 30 ns;
	

	rfu : entity work.rfu
	port map ( 
		clock => clock,
		recv => recv,
		message => recv,
		clr_irq => clr_irq,
		irq => irq
	);
	
	ReCOP : entity work.ReCOP
	port map (
		clock => clock,
		irq => irq,
		message => recv,
		send => send,
		clr_irq => clr_irq
	);
	
		
end architecture sim;	
		