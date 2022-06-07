library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ReCOPALU is
	generic (
		DATA_WIDTH : integer := 16
	);
	port(clock : in std_logic;
		ALU_Control : in std_logic_vector(1 downto 0);
		inputA : in std_logic_vector(DATA_WIDTH-1 downto 0);
		inputB : in std_logic_vector(DATA_WIDTH-1 downto 0);
		ALU_Out : out std_logic_vector(DATA_WIDTH-1 downto 0);
		z_out : out std_logic
		);
end entity ReCOPALU;

architecture beh of ReCOPALU is
	begin
	
	process (clock)
		variable ALU_Out_Var : std_logic_vector(DATA_WIDTH-1 downto 0);
		begin
			if(rising_edge(clock)) then
				case ALU_Control is
					when "00" => --addition
						ALU_Out_Var := std_logic_vector(unsigned(inputA) + unsigned(inputB));
					when "01" => --subtraction
						ALU_Out_Var := std_logic_vector(unsigned(inputA) - unsigned(inputB));
					when "10" => -- logical AND
						ALU_Out_Var := std_logic_vector(unsigned(inputA) and unsigned(inputB));
					when "11" => -- logical OR
						ALU_Out_Var := std_logic_vector(unsigned(inputA) or unsigned(inputB));
				end case;
				ALU_Out <= ALU_Out_Var;
				if(ALU_Out_Var = std_logic_vector(to_signed(0,DATA_WIDTH))) then
					z_out <= '1';
				else
					z_out <= '0';
				end if;
					
			end if;
	end process;
end architecture;
	