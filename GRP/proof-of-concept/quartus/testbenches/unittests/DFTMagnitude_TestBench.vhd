library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;

entity DFTMagnitude_TestBench is
    port (
        placeholder     : out std_logic
    );
end entity DFTMagnitude_TestBench;

architecture test of DFTMagnitude_TestBench is

    component DFTMagnitude is
        generic (
            word_length		: natural	:= 16 -- bits
        );
        port (
            clk				: in std_logic;
            rst				: in std_logic;
    
            -- inputs
            a				: in signed(word_length-1 downto 0);
            b				: in signed(word_length-1 downto 0);
            -- outputs
            magnitude		: out unsigned(word_length+1-1 downto 0)
                -- extra bit since we are adding two values
        );
    end component DFTMagnitude;

    constant    CLK_PERIOD  : time      := 10 ns;
    signal      clk         : std_logic := '0';
    signal      rst         : std_logic := '0';

    constant    word_length : natural   := 16;

    signal      a           : signed(word_length-1 downto 0);
    signal      b           : signed(word_length-1 downto 0);
    signal      magnitude   : unsigned(word_length downto 0);

    constant    MAX         : signed(word_length-1 downto 0)    := to_signed(2**(word_length-1) -1, a'length);
    constant    MIN         : signed(word_length-1 downto 0)    := to_signed(-(2**(word_length-1) -1), a'length);

begin
    
    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

    MagnitudeBlock: DFTMagnitude
        generic map (
            word_length => word_length
        )
        port map (
            clk => clk,
            rst => rst,
            -- inputs
            a => a,
            b => b,
            -- outputs
            magnitude => magnitude
        );

    -- max + min/2

    UNIT_TEST: process
    begin

        -- Test Maximum Positive
        a <= MAX;
        b <= MAX;
        
        wait for CLK_PERIOD;

        assert (magnitude = resize(unsigned(MAX + shift_right(MAX, 1)), magnitude'length))
            report "DFTMagnitude: Failed (Maximum Positive)" severity warning;


        -- Test Maximum Negative
        a <= MIN;
        b <= MIN;
        
        wait for CLK_PERIOD;

        assert (magnitude = resize(unsigned(MAX + shift_right(MAX, 1)), magnitude'length))
            report "DFTMagnitude: Failed (Maximum Negative)" severity warning;


        -- Test Reset
        a <= MIN;
        b <= MIN;
        
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';

        assert (magnitude = to_unsigned(0, magnitude'length))
            report "DFTMagnitude: Failed Reset" severity warning;


        -- Test Maximum Positive/Negative
        a <= MIN;
        b <= MAX;
        
        wait for CLK_PERIOD;

        assert (magnitude = resize(unsigned(MAX + shift_right(MAX, 1)), magnitude'length))
            report "DFTMagnitude: Failed (Maximum Positive/Negative)" severity warning;


        -- Test 0, 0
        a <= to_signed(0, a'length);
        b <= to_signed(0, b'length);
        
        wait for CLK_PERIOD;

        assert (magnitude = to_unsigned(0, magnitude'length))
            report "DFTMagnitude: Failed (0, 0)" severity warning;

        -- Test -1, 0
        a <= to_signed(-1, a'length);
        b <= to_signed(0, b'length);
        
        wait for CLK_PERIOD;

        assert (magnitude = to_unsigned(1, magnitude'length))
            report "DFTMagnitude: Failed (-1, 0)" severity warning;


        -- Test -1, 0
        a <= to_signed(-1, a'length);
        b <= to_signed(0, b'length);
        
        wait for CLK_PERIOD;

        assert (magnitude = to_unsigned(1, magnitude'length))
            report "DFTMagnitude: Failed (-1, 0)" severity warning;


        -- Test 1, -1
        a <= to_signed(1, a'length);
        b <= to_signed(-1, b'length);
        
        wait for CLK_PERIOD;

        assert (magnitude = to_unsigned(1, magnitude'length))
            report "DFTMagnitude: Failed (1, -1)" severity warning;
            -- truncation error means the min term will be lost


        -- Test 2, -2
        a <= to_signed(2, a'length);
        b <= to_signed(-2, b'length);
        
        wait for CLK_PERIOD;

        assert (magnitude = to_unsigned(3, magnitude'length))
            report "DFTMagnitude: Failed (2, -2)" severity warning;


        report "DFTMagnitude: Test Complete";
        wait;
    end process UNIT_TEST;
    
end architecture test;