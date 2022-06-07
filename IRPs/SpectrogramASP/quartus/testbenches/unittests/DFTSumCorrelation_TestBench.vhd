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

    component DFTSumCorrelation is
        port (
            clk		        : in std_logic;
            rst             : in std_logic;
            -- inputs
            x               : in signal_word;
            yn              : in signed_fxp_sinusoid;
            c_sum_in        : in signed_correlation_sum;
            -- outputs
            c_sum_out       : out signed_correlation_sum    := (others => '0')
        );
    end component DFTSumCorrelation;

    -- inputs
    signal test_x               : signal_word               := (others => '0');
    signal test_yn              : signed_fxp_sinusoid       := (others => '0');
    signal test_c_sum_in        : signed_correlation_sum    := (others => '0');
    -- outputs
    signal test_c_sum_out       : signed_correlation_sum    := (others => '0');

begin
    
    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

    SumCorrelation : DFTSumCorrelation
        port map (
            clk => clk,
            rst => rst,
            -- inputs
            x => test_x,
            yn => test_yn,
            c_sum_in => test_c_sum_in,
            -- ouputs
            c_sum_out => test_c_sum_out
        );

    UNIT_TEST: process
        variable v_x    : real                      := 0.0;
        variable v_yn   : real                      := 0.0;
        variable v_sum  : real                      := 0.0;
        variable answer : real                      := 0.0;
    begin

        -- note that int(+3.8) will truncate to +3 (towards 0)!
        -- note that int(-3.8) will truncate to -4 (towards -inf)!
        -- Hence we use floor() to observe this inaccuracy.
        
        -- Test Zeros
        v_x := 0.0;
        v_yn := 0.0;
        v_sum := 0.0;
        answer := floor(v_x * v_yn / 2.0**(signed_fxp_sinusoid'length-1)) + v_sum;

        test_x <= to_signed(integer(round(v_x)), test_x'length);
        test_yn <= to_signed(integer(round(v_yn)), test_yn'length);
        test_c_sum_in <= to_signed(integer(round(v_sum)), test_c_sum_in'length);

        wait for CLK_PERIOD;

        assert (test_c_sum_out = to_signed(integer(round(answer)), test_c_sum_out'length))
            report "DFTSumCorrelation: Failed (All Zeroes)" severity warning;


        -- Test Positive Multiply No-Add
        v_x := 2000.0;
        v_yn := 31000.0;
        v_sum := 0.0;
        answer := floor(v_x * v_yn / 2.0**(signed_fxp_sinusoid'length-1)) + v_sum;

        test_x <= to_signed(integer(round(v_x)), test_x'length);
        test_yn <= to_signed(integer(round(v_yn)), test_yn'length);
        test_c_sum_in <= to_signed(integer(round(v_sum)), test_c_sum_in'length);

        wait for CLK_PERIOD;

        assert (test_c_sum_out = to_signed(integer(round(answer)), test_c_sum_out'length))
            report "DFTSumCorrelation: Failed (Positive Multiply No-Add)" severity warning;


        -- Test Negative Multiply No-Add
        v_x := -14000.0;
        v_yn := 5200.0;
        v_sum := 0.0;
        answer := floor(v_x * v_yn / 2.0**(signed_fxp_sinusoid'length-1)) + v_sum;

        test_x <= to_signed(integer(round(v_x)), test_x'length);
        test_yn <= to_signed(integer(round(v_yn)), test_yn'length);
        test_c_sum_in <= to_signed(integer(round(v_sum)), test_c_sum_in'length);

        wait for CLK_PERIOD;

        assert (test_c_sum_out = to_signed(integer(round(answer)), test_c_sum_out'length))
            report "DFTSumCorrelation: Failed (Negative Multiply No-Add)" severity warning;

        
        -- Test Negative Multiply Add
        v_x := 32000.0;
        v_yn := 200.0;
        v_sum := 1920.0;
        answer := floor(v_x * v_yn / 2.0**(signed_fxp_sinusoid'length-1)) + v_sum;

        test_x <= to_signed(integer(round(v_x)), test_x'length);
        test_yn <= to_signed(integer(round(v_yn)), test_yn'length);
        test_c_sum_in <= to_signed(integer(round(v_sum)), test_c_sum_in'length);

        wait for CLK_PERIOD;

        assert (test_c_sum_out = to_signed(integer(round(answer)), test_c_sum_out'length))
            report "DFTSumCorrelation: Failed (Negative Multiply Add)" severity warning;


        -- Test Large Negative Multiply Add
        v_x := 20821.0;
        v_yn := -31972.0;
        v_sum := 40300.0;
        answer := floor(v_x * v_yn / 2.0**(signed_fxp_sinusoid'length-1)) + v_sum;

        test_x <= to_signed(integer(round(v_x)), test_x'length);
        test_yn <= to_signed(integer(round(v_yn)), test_yn'length);
        test_c_sum_in <= to_signed(integer(round(v_sum)), test_c_sum_in'length);

        wait for CLK_PERIOD;

        assert (test_c_sum_out = to_signed(integer(round(answer)), test_c_sum_out'length))
            report "DFTSumCorrelation: Failed (Large Negative Multiply Add)" severity warning;


        
        wait for CLK_PERIOD;

        report "DFTSumCorrelation: Test Complete";
        wait;

    end process UNIT_TEST;
    
end architecture test;