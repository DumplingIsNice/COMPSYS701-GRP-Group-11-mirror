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

    constant GENERAL_ADDR_WIDTH : integer   := 10;

    constant PM_ADDR_WIDTH   : integer := GENERAL_ADDR_WIDTH;     -- Program Memory Length (2^x)
    constant PM_DATA_WIDTH   : integer := 32;

    constant DM_ADDR_WIDTH   : integer := GENERAL_ADDR_WIDTH;
    constant DM_DATA_WIDTH   : integer := 32;

    -- ReCOPAddressRegister intialisation addr
    constant AR_INIT : recop_mem_addr := (others => '0');
    
end package ReCOPConstants;