library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;

entity DFTSumCorrelation_TestBench is
    port (
        placeholder     : out std_logic
    );
end entity DFTSumCorrelation_TestBench;

architecture test of DFTSumCorrelation_TestBench is


    constant    CLK_PERIOD  : time      := 10 ns;
    signal      clk         : std_logic := '0';
    signal      rst         : std_logic := '0';

begin
    
    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

    UNIT_TEST: process
    begin
        
        wait for CLK_PERIOD;

        wait for CLK_PERIOD;

        wait for CLK_PERIOD;

    end process UNIT_TEST;
    
end architecture test;