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

    component DFTChannelLinkModules_TestBench is
        port (
            placeholder         : out std_logic
        );
    end component DFTChannelLinkModules_TestBench;

    component DFTChannelLink_TestBench is
        generic (
            input_width         : natural   := 512; -- elements
            input_word_length   : natural   := 16;  -- bits
            sinusoid_word_length: natural   := 16   -- bits
        );
        port (
            placeholder         : out std_logic
        );
    end component DFTChannelLink_TestBench;

    signal      placeholder1    : std_logic;
    signal      placeholder2    : std_logic;
    
begin

    ModuleTest : DFTChannelLinkModules_TestBench
        generic map (
            input_width => input_width,
            input_word_length => input_word_length,
            sinusoid_word_length => sinusoid_word_length
        )
        port map (            
            placeholder => placeholder2
        );

    LinkTest : DFTChannelLink_TestBench
        generic map (
            input_width => input_width,
            input_word_length => input_word_length,
            sinusoid_word_length => sinusoid_word_length
        )
        port map (           
            placeholder => placeholder1
        );

    
    

    placeholder <= placeholder1 or placeholder2;

end architecture test;