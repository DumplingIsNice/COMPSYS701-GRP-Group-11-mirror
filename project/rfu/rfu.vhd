library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.TdmaMinTypes.all;


entity rfu is 
	port(clock : in std_logic;
		  recv : in tdma_min_port;
		  message : out tdma_min_port;
		  clr_irq : in std_logic;	
		  irq : out std_logic
	);
end entity;

architecture behaviour of rfu is 
	
begin
	
	process(clock)
		begin
		--- Message address of ReCOP on TDMA-MIN is "1000"	
			if recv.data(23 downto 20) = "1000" then 
				irq <= '1';
				message <= recv;
			else 
				irq <= '0';
			end if;
		
	end process;

end behaviour; 
