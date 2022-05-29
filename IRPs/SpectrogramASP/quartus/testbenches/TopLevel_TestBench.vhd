library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity TopLeveL_TestBench is
    generic (
        input_width         : natural   := 512; -- elements
        input_word_length   : natural   := 16;  -- bits
        sinusoid_word_length: natural   := 16   -- bits
    );
    port (
        placeholder         : out std_logic
    );
end entity;

architecture test of TopLevel_TestBench is

    component DFT_Testbench is
        port (
            placeholder     : out std_logic
        );
    end component DFT_Testbench;

    component DFT_UnitTestBench is
        port (
            placeholder         : out std_logic
        );
    end component;

    -- component DFTChannelLinkModules_TestBench is
    --     port (
    --         placeholder         : out std_logic
    --     );
    -- end component DFTChannelLinkModules_TestBench;
    
begin

    DFTTest: DFT_Testbench
        port map (
            placeholder => open
        );

    DFTUnitTest: DFT_UnitTestBench
        port map (
            placeholder => open
        );

    -- ModuleTest : DFTChannelLinkModules_TestBench
    --     port map (            
    --         placeholder => open
    --     );    


    placeholder <= '1';

end architecture test;