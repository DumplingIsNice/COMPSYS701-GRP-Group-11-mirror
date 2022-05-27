library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.ReCOPTypes.all;

package ReCOPISAConstants is

    constant opcode_AND         : std_logic_vector(5 downto 0)  := "001000";
    constant opcode_OR          : std_logic_vector(5 downto 0)  := "001100";
    constant opcode_ADD         : std_logic_vector(5 downto 0)  := "111000";
    constant opcode_LDR         : std_logic_vector(5 downto 0)  := "000000";
    constant opcode_STR         : std_logic_vector(5 downto 0)  := "000010";
    constant opcode_JMP         : std_logic_vector(5 downto 0)  := "011000";
    
end package ReCOPISAConstants;