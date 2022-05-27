library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.ReCOPTypes.all;

entity ReCOPProgramCounter_TestBench is
    port (
        placeholder     : out std_logic
    );
end entity ReCOPProgramCounter_TestBench;

architecture rtl of ReCOPProgramCounter_TestBench is

    component ReCOPProgramCounter is
        generic (
            PC_init         : recop_mem_addr    := (others => '0')
        );
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            -- control
            wr_PC           : in std_logic;
            mux_select      : in std_logic_vector(1 downto 0);
            
            -- inputs
            DM_OUT          : in recop_mem_addr;
            Ry              : in recop_reg;
            operand         : in recop_mem_addr;
            -- outputs
            PM_ADR              : out recop_mem_addr
        );
    end component ReCOPProgramCounter;

    constant CLK_PERIOD     : time          := 10 ns;
    constant PC_init        : recop_mem_addr := std_logic_vector(to_unsigned(123, recop_mem_addr'length));

    signal  clk             : std_logic     := '0';
    signal  rst             : std_logic     := '0';
    -- control
    signal  wr_PC           : std_logic     := '0';
    signal  mux_select      : std_logic_vector(1 downto 0) := (others => '0');
    -- inputs
    signal  DM_OUT          : recop_mem_addr;
    signal  Ry              : recop_reg;
    signal  operand         : recop_mem_addr;
    -- outputs
    signal  PM_ADR          : recop_mem_addr;
begin

    ProgramCounter : ReCOPProgramCounter
        generic map (
            PC_init => PC_init
        )
        port map (
            clk => clk,
            rst => rst,

            wr_PC => wr_PC,
            mux_select => mux_select,

            DM_OUT => DM_OUT,
            Ry => Ry,
            operand => operand,

            PM_ADR => PM_ADR
        );
    
    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

    test: process
        variable prev_PM_ADR        : recop_mem_addr;
    begin
        prev_PM_ADR := PM_ADR;
        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delay for delta cycles

        -- Test Initialisation
        assert (PM_ADR = PC_init)
            report "Initialisation failed: PM_ADR not initialised" severity warning;


        -- Test PC+1
        wr_PC <= '1';
        mux_select <= "00";

        prev_PM_ADR := PM_ADR;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (PM_ADR = std_logic_vector(unsigned(prev_PM_ADR) + to_unsigned(1, PM_ADR'length)))
            report "PC+1 failed: PM_ADR not updated" severity warning;


        -- Test PC+1 Fail
        wr_PC <= '0';
        mux_select <= "00";

        prev_PM_ADR := PM_ADR;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (PM_ADR = prev_PM_ADR)
            report "PC+1 Fail failed: PM_ADR was updated" severity warning;

        
        -- Test Load operand
        wr_PC <= '1';
        mux_select <= "01";
        operand <= std_logic_vector(to_unsigned(54321, PM_ADR'length));

        prev_PM_ADR := PM_ADR;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (PM_ADR = std_logic_vector(to_unsigned(54321, PM_ADR'length)))
            report "operand failed: PM_ADR not updated" severity warning;


        -- Test PC+1
        wr_PC <= '1';
        mux_select <= "00";

        prev_PM_ADR := PM_ADR;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (PM_ADR = std_logic_vector(unsigned(prev_PM_ADR) + to_unsigned(1, PM_ADR'length)))
            report "PC+1 failed: PM_ADR not updated" severity warning;


        -- Test Reset
        rst <= '1';

        prev_PM_ADR := PM_ADR;
        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delay for delta cycles

        rst <= '0';
        assert (PM_ADR = PC_init)
            report "Reset failed: PM_ADR not initialised" severity warning;


        -- Test Load Ry
        wr_PC <= '1';
        mux_select <= "10";
        Ry <= std_logic_vector(to_unsigned(9876, Ry'length));

        prev_PM_ADR := PM_ADR;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (PM_ADR = std_logic_vector(to_unsigned(9876, PM_ADR'length)))
            report "DM_OUT failed: PM_ADR not updated" severity warning;


        -- Test Load DM_OUT
        wr_PC <= '1';
        mux_select <= "11";
        DM_OUT <= std_logic_vector(to_unsigned(200, PM_ADR'length));

        prev_PM_ADR := PM_ADR;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (PM_ADR = std_logic_vector(to_unsigned(200, PM_ADR'length)))
            report "DM_OUT failed: PM_ADR not updated" severity warning;


        report "ReCOPStackPointer Test: OK";
        wait;

    end process test;
    
end architecture rtl;
