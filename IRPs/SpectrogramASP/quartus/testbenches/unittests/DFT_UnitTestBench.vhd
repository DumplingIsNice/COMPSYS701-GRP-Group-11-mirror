library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity DFT_UnitTestBench is
    port (
        placeholder         : out std_logic
    );
end entity;

architecture test of DFT_UnitTestBench is
    
    component DFTMagnitude_TestBench is
        port (
            placeholder     : out std_logic
        );
    end component DFTMagnitude_TestBench;

    component DFTGenerateReference_TestBench is
        port (
            placeholder     : out std_logic
        );
    end component DFTGenerateReference_TestBench;
begin

    placeholder <= '1';

    MagnitudeTestBench: DFTMagnitude_TestBench
        port map (
            placeholder => open
        );

    GenerateReferenceTestBench: DFTGenerateReference_TestBench
        port map (
            placeholder => open
        );
    
end architecture test;