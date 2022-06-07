library IEEE;

use ieee.std_logic_1164.all;

library work;
use work.ReCOPTypes.all;
use work.ReCOPConstants.all;

entity ReCOP_Control_Unit is
    port(
        IR_CODE : in std_logic_vector(7 downto 0);
        flag_status : in std_logic;
        PC_MUX : out std_logic_vector(1 downto 0);
        --IR_MUX: out std_logic;
        ALU_MUX : out std_logic;
        RF_MUX: out std_logic_vector(1 downto 0);
        AR_MUX: out std_logic_vector(1 downto 0);
        IDM_MUX: out std_logic_vector(1 downto 0);
        ADD_SUM_OP : out std_logic;
        ALU_OP : out std_logic_vector( 1 downto 0);
        mem_write : out std_logic;
        mem_read  : out std_logic;
        mem_sel : out std_logic;
        RF_Write : out std_logic;
        RF_Read : out std_logic 
    );
end entity;

architecture control of ReCOP_Control_Unit is
    signal AddressingMode : std_logic_vector(1 downto 0) := IR_CODE(7 downto 6);
    signal OPCODE : std_logic_vector(5 downto 0) := IR_CODE(5 downto 0);
    signal state : std_logic := '0';
    begin
        AddressingMode <= IR_CODE(7 downto 6);
        OPCODE <= IR_CODE(5 downto 0);
        --00 Addition, 01 subtraction, 10 AND, 11 OR
        ALU_OP <= "00" when OPCODE = "001000" else
                    "01" when OPCODE = "000011" else
                    "10" when OPCODE = "001000" else
                    "11" when OPCODE = "001100" else "00";
        
        ALU_MUX <= MUX_B_SEL_RZ when AddressingMode = "11" else MUX_B_SEL_IR_OPERAND;

        RF_MUX <=   RF_IN_SEL_IR_OPERAND when OPCODE= "000000" and AddressingMode = "01" else
                    RF_IN_SEL_RX when OPCODE="000000" and AddressingMode = "10" else
                    RF_IN_SEL_ALU_OUT when (OPCODE="001000" or OPCODE ="001100" or OPCODE="111000" or OPCODE="000011") else
                    RF_IN_SEL_IR_OPERAND;

        PC_MUX <= "01" when OPCODE="011000" and AddressingMode="11" and state = '1' else
                "10" when OPCODE="011000" and AddressingMode="01" and state = '1' else
                "11";
        
        IDM_MUX <= "00" when OPCODE="000010" and AddressingMode="01" else
                "01" when OPCODE="000010" and (AddressingMode="10" or AddressingMode="11") else
                "10" when OPCODE="011101" and AddressingMode="10" else
                "00";
        AR_MUX <= "00" when (OPCODE="011101" and AddressingMode="10") or state = '0' else
                "01" when OPCODE="000000" and AddressingMode="11" and state = '1' else
                "10" when OPCODE="000010" and (AddressingMode="01" or AddressingMode="11") and state = '1' else
                "11" when AddressingMode = "10" and (OPCODE="000000" or OPCODE="000010" or OPCODE="011101") else
                "00";

        RF_Write <= '1' when state = '1' and (OPCODE = "001000" or OPCODE = "001100" or OPCODE = "111000" or OPCODE = "000100" or OPCODE="000000" or OPCODE = "011110") else
            '0';
        
        RF_Read <= '1' when state = '1' and (OPCODE = "001000" or OPCODE = "001100" or OPCODE = "111000" or OPCODE = "000100" or (OPCODE="000000" and AddressingMode="11") or OPCODE = "011110") else
            '0';
        mem_write <= '1' when state = '1' and (OPCODE = "000010" or OPCODE = "011101") else
            '0';
        mem_read <= '1' when (state = '1' and OPCODE = "000000") or state = '0' else
            '0';
    end architecture;
        
