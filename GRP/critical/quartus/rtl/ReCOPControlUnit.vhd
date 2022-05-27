library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.ReCOPTypes.all;
use work.ReCOPConstants.all;
use work.ReCOPISAConstants.all;

entity ReCOPControlUnit is
    port (
        clk         : in std_logic;
        rst         : in std_logic;

        -- inputs
        -- instruction register
        IR_AM       : in std_logic_vector(1 downto 0);
        IR_Opcode   : in std_logic_vector(5 downto 0);
        IR_Rz       : in std_logic_vector(3 downto 0);
        IR_Rx       : in std_logic_vector(3 downto 0);
        IR_Operand  : in std_logic_vector(15 downto 0);


        -- outputs
        PM_OUT              : out recop_instruction;

        -- program counter
        wr_PC               : out std_logic;
        PC_mux_select       : out std_logic_vector(1 downto 0);

        -- instruction register
        wr_IR               : out std_logic;

        -- stack pointer
        wr_SP               : out std_logic;
        SP_mux_select       : out std_logic_vector(1 downto 0);
        push_not_pull       : out std_logic;

        -- address register
        wr_AR               : out std_logic;
        AR_mux_select       : out std_logic_vector(1 downto 0)
    );
end entity ReCOPControlUnit;

architecture rtl of ReCOPControlUnit is
    
begin

    program_counter: process(IR_AM)
    begin
        case IR_AM is
            when "00" =>
                -- inherent: PC+1
                PC_mux_select <= "00";
                wr_PC <= '1';
            when "01" =>
                -- immediate: operand
                PC_mux_select <= "01";
                wr_PC <= '1';
            when "10" =>
                -- direct: DM_OUT
                PC_mux_select <= "11";
                wr_PC <= '1';
            when "11" =>
                -- register: Ry
                PC_mux_select <= "10";
                wr_PC <= '1';        
            when others =>
                -- invalid
                -- PC_mux_select irrelevant
                wr_PC <= '0';
        end case;
    end process program_counter;

    instruction_register: process
    begin
        wr_IR <= '1';
        wait;
    end process instruction_register;

    stack_pointer: process(IR_AM)
    begin
        case IR_AM is
            when "00" =>
                -- inherent: SP+-1
                case IR_Opcode is
                    when opcode_LDR =>
                        -- if LDR, then pull from stack
                        push_not_pull <= '0';
                        wr_SP <= '1';
                    when opcode_STR =>
                        -- if STR, then push to stack
                        push_not_pull <= '1';
                        wr_SP <= '1';
                    when others =>
                        -- invalid    
                        wr_SP <= '0';
                end case;
                SP_mux_select <= "00";
            when "01" =>
                -- immediate: operand
                SP_mux_select <= "10";
                wr_SP <= '1';
            when "10" =>
                -- direct: DM_OUT
                SP_mux_select <= "01";
                wr_SP <= '1';
            when others =>
                -- invalid
                -- SP_mux_select <= "00";
                wr_SP <= '0';
        end case;

    end process stack_pointer;
    
    address_register: process(IR_AM)
    begin
        case IR_AM is
            when "00" =>
                -- inherent: SP+-1
                case IR_Opcode is
                    when opcode_LDR =>
                        -- if LDR, then pull from stack
                        AR_mux_select <= "01";
                        wr_AR <= '1';
                    when opcode_STR =>
                        -- if STR, then push to stack
                        AR_mux_select <= "00";
                        wr_AR <= '1';
                    when others =>
                        -- invalid
                        -- SP_mux_select <= "00";    
                        wr_AR <= '0';
                end case;
            when "01" =>
                -- immediate: operand
                AR_mux_select <= "11";
                wr_AR <= '1';
            when "10" =>
                -- direct: undefined -- invalid
                -- AR_mux_select <= "00";
                wr_AR <= '0';
            when "11" =>
                -- register: Ry
                AR_mux_select <= "10";
                wr_AR <= '1';
            when others =>
                -- invalid
                -- SP_mux_select <= "00";
                wr_AR <= '0';
        end case;
    end process address_register;    

    
end architecture rtl;