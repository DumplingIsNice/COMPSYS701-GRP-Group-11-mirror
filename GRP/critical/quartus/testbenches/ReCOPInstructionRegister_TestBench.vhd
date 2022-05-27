library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.ReCOPTypes.all;

entity ReCOPInstructionRegister_TestBench is
    port (
        placeholder     : out std_logic
    );
end entity ReCOPInstructionRegister_TestBench;

architecture rtl of ReCOPInstructionRegister_TestBench is
    
    component ReCOPInstructionRegister is
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
    end component ReCOPInstructionRegister;

    constant CLK_PERIOD         : time                  := 10 ns;
    constant IR_init            : recop_instruction     := std_logic_vector(to_unsigned(12345, recop_instruction'length));

    constant test_instruction_1   : recop_instruction     := x"6789abcd";
    constant test_instruction_2   : recop_instruction     := x"abcd6789";

    signal  clk             : std_logic         := '0';
    signal  rst             : std_logic         := '0';

    -- control
    signal wr_IR       : std_logic         := '0';
    -- inputs
    signal PM_OUT      : recop_instruction      := (others => '0');
    -- outputs
    signal IR_AM       : std_logic_vector(1 downto 0);
    signal IR_Opcode   : std_logic_vector(5 downto 0);
    signal IR_Rz       : std_logic_vector(3 downto 0);
    signal IR_Rx       : std_logic_vector(3 downto 0);
    signal IR_Operand  : std_logic_vector(15 downto 0);

begin

    InstructionRegister: ReCOPInstructionRegister
        generic map (
            IR_init => IR_init
        )
        port map (
            clk => clk,
            rst => rst,
            -- control
            wr_IR => wr_IR,
    
            -- inputs
            PM_OUT => PM_OUT,
            -- outputs
            IR_AM => IR_AM,
            IR_Opcode => IR_Opcode,
            IR_Rz => IR_Rz,
            IR_Rx => IR_Rx,
            IR_Operand => IR_Operand
        );

    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

    test: process
    begin
        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delay for delta cycles

        -- Test Init
        assert ((IR_AM & IR_Opcode & IR_Rz & IR_Rx & IR_Operand) = IR_init)
            report "Initialisation failed: IR not initialised" severity warning;


        -- Test Write
        wr_IR <= '1';
        PM_OUT <= test_instruction_1;

        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delay for delta cycles

        assert ((IR_AM & IR_Opcode & IR_Rz & IR_Rx & IR_Operand) = test_instruction_1)
            report "Write failed: IR incorrect" severity warning;


        -- Test Write Fail
        wr_IR <= '0';
        PM_OUT <= test_instruction_2;

        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delay for delta cycles

        assert ((IR_AM & IR_Opcode & IR_Rz & IR_Rx & IR_Operand) /= test_instruction_2) and
                ((IR_AM & IR_Opcode & IR_Rz & IR_Rx & IR_Operand) = test_instruction_1)
            report "Write Fail failed: IR updated while wr_IR low" severity warning;


        -- Test Reset
        rst <= '1';

        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delay for delta cycles
        rst <= '0';

        assert ((IR_AM & IR_Opcode & IR_Rz & IR_Rx & IR_Operand) = IR_init)
            report "Reset failed: IR not initialised" severity warning;

        -- Test Write
        wr_IR <= '1';
        PM_OUT <= test_instruction_2;

        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delay for delta cycles

        assert ((IR_AM & IR_Opcode & IR_Rz & IR_Rx & IR_Operand) = test_instruction_2)
            report "Write failed: IR incorrect" severity warning;


        report "ReCOPInstructionRegister Test: OK";
        wait;
       
    end process test;

    
end architecture rtl;