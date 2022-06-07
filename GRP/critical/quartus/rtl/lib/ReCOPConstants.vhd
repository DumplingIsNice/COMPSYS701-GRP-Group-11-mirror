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
    constant PM_DATA_WIDTH   : integer := 16;

    constant DM_ADDR_WIDTH   : integer := GENERAL_ADDR_WIDTH;
    constant DM_DATA_WIDTH   : integer := 16;

    constant REG_FILE_DATA_WIDTH : integer := 16;

    -- ReCOPAddressRegister intialisation addr
    constant AR_INIT : recop_mem_addr := (others => '0');

    -- Control Signals
    ------------------------------------------------------------------------
    constant RF_IN_SEL_IR_OPERAND   : std_logic_vector(1 downto 0)  := "00";
    constant RF_IN_SEL_RX           : std_logic_vector(1 downto 0)  := "01";
    constant RF_IN_SEL_ALU_OUT      : std_logic_vector(1 downto 0)  := "10";

    constant MUX_A_SEL_IR_OPERAND   : std_logic_vector(1 downto 0)  := "00";
    constant MUX_A_SEL_RX           : std_logic_vector(1 downto 0)  := "01";
    constant MUX_A_SEL_ONE          : std_logic_vector(1 downto 0)  := "10";
    
    constant MUX_B_SEL_RZ           : std_logic := '1';
    constant MUX_B_SEL_IR_OPERAND   : std_logic := '0';

    constant DM_MUX_SEL_IR_OPERAND  : std_logic_vector(1 downto 0) := "00";
    constant DM_MUX_SEL_RX          : std_logic_vector(1 downto 0) := "01";
    constant DM_MUX_SEL_PM_ADR      : std_logic_vector(1 downto 0) := "10";
    
end package ReCOPConstants;