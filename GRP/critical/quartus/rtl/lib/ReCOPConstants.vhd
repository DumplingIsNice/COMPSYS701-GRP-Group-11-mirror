library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.ReCOPTypes.all;

package ReCOPConstants is

    -- Default Values --
    constant IR_INITIAL     : recop_reg         := (others => '0');

    -- Base Memory Addresses --
    constant PC_BASE        : recop_mem_addr    := (others => '0');
    constant SP_BASE        : recop_mem_addr    := (others => '0');
    constant AR_BASE        : recop_mem_addr    := (others => '0');
    
end package ReCOPConstants;