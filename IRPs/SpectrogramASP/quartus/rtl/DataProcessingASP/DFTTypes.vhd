library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package DFTTypes is
    
    constant WINDOW_WORD_LENGTH         : natural         := 16;
    constant WINDOW_LENGTH              : natural         := 512;
    constant SINUSOID_WORD_LENGTH       : natural         := 16;

    subtype signed_fxp_sinusoid is      signed(SINUSOID_WORD_LENGTH-1 downto 0);
    subtype signed_correlation_sum is   signed(WINDOW_WORD_LENGTH + natural(ceil(log2(real(WINDOW_LENGTH))))-1 downto 0);

    subtype signal_word is              signed(WINDOW_WORD_LENGTH-1 downto 0);
    type    signal_window is            array (WINDOW_LENGTH-1 downto 0) of signal_word;
    
end package DFTTypes;