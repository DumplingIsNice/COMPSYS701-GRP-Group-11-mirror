library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.ReCOPTypes.all;

entity ReCOPInstructionRegister is
    generic (
        IR_init     : recop_instruction := (others => '0')
    );
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        -- control
        wr_IR       : in std_logic;

        -- inputs
        PM_OUT      : in recop_instruction;
        -- outputs
        IR_AM       : out std_logic_vector(1 downto 0);
        IR_Opcode   : out std_logic_vector(5 downto 0);
        IR_Rz       : out std_logic_vector(3 downto 0);
        IR_Rx       : out std_logic_vector(3 downto 0);
        IR_Operand  : out std_logic_vector(15 downto 0)
    );
end entity ReCOPInstructionRegister;

architecture rtl of ReCOPInstructionRegister is
begin

    main: process(clk)
        variable v_IR : recop_instruction := IR_init;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                v_IR := IR_init;
            else
                if wr_IR = '1' then
                    v_IR := PM_OUT;
                end if;
            end if;

            IR_AM <= v_IR(31 downto 30);
            IR_Opcode <= v_IR(29 downto 24);
            IR_Rz <= v_IR(23 downto 20);
            IR_Rx <= v_IR(19 downto 16);
            IR_Operand <= v_IR(15 downto 0);
        end if;
    end process main;

end architecture rtl;