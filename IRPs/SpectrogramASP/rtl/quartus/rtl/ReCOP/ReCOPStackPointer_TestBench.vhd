library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.ReCOPTypes.all;

entity ReCOPStackPointer_TestBench is
    port (
        placeholder     : out std_logic
    );
end entity ReCOPStackPointer_TestBench;

architecture rtl of ReCOPStackPointer_TestBench is

    component ReCOPStackPointer is
        generic (
            SP_init         : recop_mem_addr    := (others => '0')
            -- TODO: replace with TYPES from library!
        );
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            -- control
            wr_SP           : in std_logic;
            mux_select      : in std_logic_vector(1 downto 0);
            push_not_pull   : in std_logic; -- 1: push, 0: pull
            
            -- inputs
            DM_OUT          : in recop_mem_addr;
            immediate       : in recop_mem_addr;
            -- outputs
            SP              : out recop_mem_addr;
            SP_incremented  : out recop_mem_addr
        );
    end component ReCOPStackPointer;

    constant CLK_PERIOD     : time          := 10 ns;
    constant SP_init        : recop_mem_addr := std_logic_vector(to_unsigned(123, recop_mem_addr'length));

    signal  clk             : std_logic     := '0';
    signal  rst             : std_logic     := '0';
    -- control
    signal  wr_SP           : std_logic;
    signal  mux_select      : std_logic_vector(1 downto 0);
    signal  push_not_pull   : std_logic;
    -- inputs
    signal  DM_OUT          : recop_mem_addr;
    signal  immediate       : recop_mem_addr;
    -- outputs
    signal  SP              : recop_mem_addr;
    signal  SP_incremented  : recop_mem_addr;
begin

    SPModule : ReCOPStackPointer
        generic map (
            SP_init => SP_init
        )
        port map (
            clk => clk,
            rst => rst,

            wr_SP => wr_SP,
            mux_select => mux_select,
            push_not_pull => push_not_pull,

            DM_OUT => DM_OUT,
            immediate => immediate,

            SP => SP,
            SP_incremented => SP_incremented
        );
    
    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

    test: process
        variable state : natural := 0;
        variable prev_SP        : recop_mem_addr;
        variable prev_SP_inc    : recop_mem_addr;
    begin
        prev_SP := SP; prev_SP_inc := SP_incremented;
        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delay for delta cycles

        -- Test Initialisation
        assert (SP = SP_init)
            report "Initialisation failed: SP not initialised" severity warning;
        assert (SP_incremented = std_logic_vector(unsigned(SP_init) + to_unsigned(1, SP_incremented'length)))
            report "Initialisation failed: SP_incremented incorrect" severity warning;

        -- Test Pull
        -- AR <- SP, SP <- SP-1
        wr_SP <= '1';
        mux_select <= "00";
        push_not_pull <= '0';

        prev_SP := SP; prev_SP_inc := SP_incremented;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (SP = std_logic_vector(unsigned(prev_SP) - to_unsigned(1, SP'length)))
            report "Pull failed: SP not updated" severity warning;
        assert (SP_incremented = std_logic_vector(unsigned(SP) + to_unsigned(1, SP_incremented'length)))
            report "Pull failed: SP_incremented incorrect" severity warning;


        -- Test Push
        -- AR <- SP+1, SP <- SP+1
        wr_SP <= '1';
        mux_select <= "00";
        push_not_pull <= '1';

        prev_SP := SP; prev_SP_inc := SP_incremented;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (SP = std_logic_vector(unsigned(prev_SP) + to_unsigned(1, SP'length)))
            report "Push failed: SP not updated" severity warning;
        assert (SP_incremented = std_logic_vector(unsigned(SP) + to_unsigned(1, SP_incremented'length)))
            report "Push failed: SP_incremented incorrect" severity warning;


        -- Test Pull Fail
        wr_SP <= '0';
        mux_select <= "00";
        push_not_pull <= '0';

        prev_SP := SP; prev_SP_inc := SP_incremented;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (SP = prev_SP)
            report "Pull Fail failed: SP was updated" severity warning;
        assert (SP_incremented = prev_SP_inc)
            report "Pull Fail failed: SP_incremented incorrect" severity warning;

        
        -- Test Load Immediate
        wr_SP <= '1';
        mux_select <= "10";
        immediate <= std_logic_vector(to_unsigned(54321, SP'length));

        prev_SP := SP; prev_SP_inc := SP_incremented;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (SP = std_logic_vector(to_unsigned(54321, SP'length)))
            report "Immediate failed: SP not updated" severity warning;
        assert (SP_incremented = std_logic_vector(unsigned(SP) + to_unsigned(1, SP_incremented'length)))
            report "Immediate failed: SP_incremented incorrect" severity warning;


        -- Test Push
        -- AR <- SP+1, SP <- SP+1
        wr_SP <= '1';
        mux_select <= "00";
        push_not_pull <= '1';

        prev_SP := SP; prev_SP_inc := SP_incremented;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (SP = std_logic_vector(unsigned(prev_SP) + to_unsigned(1, SP'length)))
            report "Push failed: SP not updated" severity warning;
        assert (SP_incremented = std_logic_vector(unsigned(SP) + to_unsigned(1, SP_incremented'length)))
            report "Push failed: SP_incremented incorrect" severity warning;

        
        -- Test Load DM_OUT
        -- value from DM is faked
        wr_SP <= '1';
        mux_select <= "01";
        DM_OUT <= std_logic_vector(to_unsigned(200, SP'length));

        prev_SP := SP; prev_SP_inc := SP_incremented;
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        assert (SP = std_logic_vector(to_unsigned(200, SP'length)))
            report "DM_OUT failed: SP not updated" severity warning;
        assert (SP_incremented = std_logic_vector(unsigned(SP) + to_unsigned(1, SP_incremented'length)))
            report "DM_OUT failed: SP_incremented incorrect" severity warning;


        report "ReCOPStackPointer Test: OK";
        wait;

    end process test;
    
end architecture rtl;
