library IEEE;

use ieee.std_logic_1164.all;

entity ReCOP_Control_Unit is
    port(
        clock : in std_logic;
        IR_CODE : in std_logic_vector(7 downto 0);
        flag_status : in std_logic;
        PC_MUX : out std_logic_vector(1 downto 0);
        --IR_MUX: out std_logic;
        ALU_MUX : out std_logic;
        RF_MUX: out std_logic_vector(1 downto 0);
        AR_MUX: out std_logic_vector(1 downto 0);
        IDM_MUX: out std_logic_vector(1 downto 0);
        OUT_MUX: out std_logic_vector(1 downto 0);
        ADD_SUM_OP : out std_logic;
        ALU_OP : out std_logic_vector( 1 downto 0);
        mem_write : out std_logic;
        mem_sel : out std_logic;
        RF_Write : out std_logic;
        RF_Read : out std_logic
        mem_read : out std_logic;
        PC_Write : out std_logic;
        IR_Write : out std_logic;
        AR_Write : out std_logic

    );
end entity;

architecture control is
    signal AddressingMode : std_logic_vector(1 downto 0) := IR_CODE(7 downto 6);
    signal OPCODE : std_logic_vector(5 downto 0) := IR_CODE(5 downto 0);
    signal state : std_logic := '0';
    begin
        AddressingMode <= IR_CODE(7 downto 6);
        OPCODE <= IR_CODE(5 downto 0);

        --Cycle through T1 and T2 states
        process (clock)
        begin
            state <= not state;
        end process;

        --00 Addition, 01 subtraction, 10 AND, 11 OR
        

        ALU_OP <= "00" when OPCODE = "001000" else
                    "01" when OPCODE = "000011" else
                    "10" when OPCODE = "001000" else
                    "11" when OPCODE = "001100" else "00";
        
        ALU_MUX <= '1' when AddressingMode = "11" else '0';

        RF_MUX <= "00" when OPCODE= "000000" and AddressingMode = "01" else
            "01" when OPCODE="000000" and AddressingMode = "10" else
            "10" when (OPCODE="001000" or OPCODE ="001100" or OPCODE="111000" or OPCODE="000011") else
            "00";

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
        mem_write <= '1' when state = '1' and (OPCODE = "000010" or OPCODE = "011101") else
            '0';
        mem_read <= '1' when (state = '1' and OPCODE = "000000") or state = '0' else
            '0';
        PC_Write <= '1' when state = '0' or OPCODE = "011000" else 
            '0';
        IR_Write <= '1' when state = '0'  else
            '0';
        AR_Write <= '1' when state = '0' or OPCODE = "000000" or OPCODE = "000010" or OPCODE = "011101" else
            '0';
end architecture;
        
        
