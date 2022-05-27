library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.ReCOPTypes.all;

entity ReCOPAddressRegister_TestBench is
    port (
        placeholder     : out std_logic
    );
end entity ReCOPAddressRegister_TestBench;

architecture test of ReCOPAddressRegister_TestBench is
    
    component ReCOPAddressRegister is
        generic (
            AR_init             : in recop_mem_addr := (others => '0')
        );
        port (
            clk                 : in std_logic;
            rst                 : in std_logic;
            -- control
            wr_AR               : in std_logic;
            mux_select          : in std_logic_vector(1 downto 0);
    
            -- inputs
            Ry                  : in recop_reg;
            SP_incremented      : in recop_mem_addr;
            SP                  : in recop_mem_addr;
            operand             : in recop_reg;
            -- outputs
            DM_ADR              : out recop_mem_addr
        );
    end component ReCOPAddressRegister;

    constant CLK_PERIOD     : time              := 10 ns;
    constant AR_init        : recop_mem_addr    := std_logic_vector(to_unsigned(62009, recop_mem_addr'length));
    constant test_base_addr : natural           := 32450;
    constant test_last_valid_mux : natural      := 3; -- "11"

    signal clk                  : std_logic     := '0';
    signal rst                  : std_logic     := '0';
    -- control  
    signal wr_AR                : std_logic     := '0';
    signal mux_select           : std_logic_vector(1 downto 0)    := (others => '0');
    -- inputs   
    signal Ry                   : recop_reg           := std_logic_vector(to_unsigned(test_base_addr+2, recop_reg'length));
    signal SP_incremented       : recop_mem_addr      := std_logic_vector(to_unsigned(test_base_addr, recop_mem_addr'length));
    signal SP                   : recop_mem_addr      := std_logic_vector(to_unsigned(test_base_addr+1, recop_mem_addr'length));
    signal operand              : recop_reg           := std_logic_vector(to_unsigned(test_base_addr+3, recop_reg'length));
    -- outputs  
    signal DM_ADR               : recop_mem_addr;
begin

    AddressRegister : ReCOPAddressRegister
        generic map (
            AR_init => AR_init
        )
        port map (
            clk => clk,
            rst => rst,
            -- control
            wr_AR => wr_AR,
            mux_select => mux_select,
            -- inputs
            Ry => Ry,
            SP_incremented => SP_incremented,
            SP => SP,
            operand => operand,
            -- outputs
            DM_ADR => DM_ADR
        );

    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

    test: process
        variable prev_DM_ADR : recop_mem_addr := (others => '0');
    begin
        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delay for delta cycles

        -- Test Initialisation
        assert (DM_ADR = AR_init)
            report "Initialisation failed: AR not initialised" severity warning;


        -- Test Mux
        wr_AR <= '1';
        for i in 0 to 2 ** mux_select'length -1 loop
            mux_select <= std_logic_vector(to_unsigned(i, mux_select'length));
            prev_DM_ADR := DM_ADR;

            wait until rising_edge(clk); wait for CLK_PERIOD/10;

            if i <= test_last_valid_mux then
                assert (DM_ADR = std_logic_vector(to_unsigned(test_base_addr + i, DM_ADR'length)))
                    report "Mux failed: AR not value of input for mux_select= " & integer'image(i) severity warning;
            else
                assert (DM_ADR = prev_DM_ADR)
                    report "Mux failed: AR changed on invalid mux_select= " & integer'image(i) severity warning;
            end if;
        end loop;
        

        -- Test Reset
        rst <= '1';
        wait until rising_edge(clk); wait for CLK_PERIOD/10;

        rst <= '0';
        assert (DM_ADR = AR_init)
            report "Reset failed: AR not initialised" severity warning;


        -- Test Mux (copied)
        wr_AR <= '1';
        for i in 0 to 2 ** mux_select'length -1 loop
            mux_select <= std_logic_vector(to_unsigned(i, mux_select'length));
            prev_DM_ADR := DM_ADR;

            wait until rising_edge(clk); wait for CLK_PERIOD/10;

            if i <= test_last_valid_mux then
                assert (DM_ADR = std_logic_vector(to_unsigned(test_base_addr + i, DM_ADR'length)))
                    report "Mux post-test failed: AR not value of input for mux_select= " & integer'image(i) severity warning;
            else
                assert (DM_ADR = prev_DM_ADR)
                    report "Mux post-test failed: AR changed on invalid mux_select= " & integer'image(i) severity warning;
            end if;
        end loop;

        report "ReCOPAddressRegister Test: OK";
        wait;

    end process test;
    
    
    
end architecture test;




