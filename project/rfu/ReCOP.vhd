library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

library work;
use work.TdmaMinTypes.all;


entity ReCOP is  
	port(clock, irq : in std_logic;
		  message : in tdma_min_port;
		  --data_ctrl : in std_logic_vector(7 downto 0);
		  send : out tdma_min_port;
		  clr_irq : out std_logic
		);  
end entity;

architecture behaviour of RecOP is 

begin

	process(clock, irq)
	begin
		if irq = '1' then
		
-- control of data and messages from DPs/ASPs
--		case message.data(31 downto 28) is 
--			when "1100" => send.data() <= 
--			when "1101" => send.data() <= 
--			when "1110" => send.data()
--			when "1111" => send.data()
			
			clr_irq <= '1';
		else
			clr_irq <= '0';
		end if;
	
	end process;

end architecture;
			