library ieee;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

package ReCOPTypes is

    -- Main Types --
    subtype recop_instruction is    std_logic_vector(31 downto 0);
    subtype recop_reg is            std_logic_vector(31 downto 0);
    subtype recop_mem_addr is       std_logic_vector(31 downto 0);

    subtype recop_data is std_logic_vector(15 downto 0);
    
end package ReCOPTypes;