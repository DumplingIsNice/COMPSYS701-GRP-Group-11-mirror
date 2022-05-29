library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;

entity DFTGenerateReference_TestBench is
    port (
        placeholder     : out std_logic
    );
end entity DFTGenerateReference_TestBench;

architecture test of DFTGenerateReference_TestBench is

    component DFTGenerateReference is
        port (
            clk		        : in std_logic;
            rst             : in std_logic;
    
            -- inputs from previous link
            cos_w           : in signed_fxp_sinusoid;
            yn1             : in signed_fxp_sinusoid;
            yn2             : in signed_fxp_sinusoid;
            -- outputs
            cos_w_out       : out signed_fxp_sinusoid   := (others => '0');
            yn1_out         : out signed_fxp_sinusoid   := (others => '0');
            yn              : out signed_fxp_sinusoid   := (others => '0')
        );
    end component DFTGenerateReference;

    function assert_nearly_equal(
        a            : in signed_fxp_sinusoid;
        b            : in signed_fxp_sinusoid;
        tolerance    : in natural)
        return boolean is
        variable flag : boolean;
        variable sum  : integer;
    begin
        sum := abs(to_integer(a));
        sum := abs(sum - abs(to_integer(b)));
        -- sum := abs(to_integer(abs(a)) - to_integer(abs(b)));
        return sum <= integer(tolerance);
    end assert_nearly_equal;


    constant    CLK_PERIOD  : time      := 10 ns;
    signal      clk         : std_logic := '0';
    signal      rst         : std_logic := '0';

    -- inputs
    signal      cos_w           : signed_fxp_sinusoid;
    signal      yn1             : signed_fxp_sinusoid;
    signal      yn2             : signed_fxp_sinusoid;
    -- outputs
    signal      cos_w_out       : signed_fxp_sinusoid;
    signal      yn1_out         : signed_fxp_sinusoid;
    signal      yn              : signed_fxp_sinusoid;

    constant    AMPLITUDE       : real := real(2**(signed_fxp_sinusoid'length -1) -1);

    -- PARAMETER --
    constant    ASSERT_TOLERANCE    : natural := 8; -- error to ignore
        -- tolerance of 8 is guaranteed no errors under normal operation
        -- when window_width=512 simulate for 4 ms to complete the test
begin
    
    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

    GenerateReferenceBlock: DFTGenerateReference
        port map (
            clk => clk,
            rst => rst,
    
            -- inputs from previous link
            cos_w => cos_w,
            yn1 => yn1,
            yn2 => yn2,
            -- outputs
            cos_w_out => cos_w_out,
            yn1_out => yn1_out,
            yn => yn
        );

    UNIT_TEST: process
        variable k      : real   := 0.0;
        variable n      : real   := 0.0;
        variable wk     : real   := 0.0;

        variable prev_cos_w : signed_fxp_sinusoid;
        variable prev_yn1   : signed_fxp_sinusoid;

        variable answer_cos : signed_fxp_sinusoid;
        variable answer_sin : signed_fxp_sinusoid;
    begin

        report "DFTGenerateReference: Testing with tolerance of "
            & natural'image(ASSERT_TOLERANCE) & " (" & real'image(100.0 * real(ASSERT_TOLERANCE)/AMPLITUDE)
            & " % of amplitude " & real'image(AMPLITUDE) & ")";

        -- Test DC
        wait until rising_edge(clk);

        cos_w <= to_signed(integer(round(AMPLITUDE)), signed_fxp_sinusoid'length);
        yn1 <= to_signed(integer(round(AMPLITUDE)), signed_fxp_sinusoid'length);
        yn2 <= to_signed(integer(round(AMPLITUDE)), signed_fxp_sinusoid'length);

        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delta cycles

        answer_cos := to_signed(integer(round(AMPLITUDE-2.0)), signed_fxp_sinusoid'length);
        -- division by 2^15 rather than 2^15 -1 leads to an error most noticeable near max amplitude
        assert ((yn = answer_cos) and (cos_w_out = cos_w) and (yn1_out = yn1))
            report "DFTGenerateReference: Failed (DC)" severity warning;

        
        -- Test Reset
        wait until rising_edge(clk);

        cos_w <= to_signed(integer(round(AMPLITUDE)), signed_fxp_sinusoid'length);
        yn1 <= to_signed(integer(round(AMPLITUDE)), signed_fxp_sinusoid'length);
        yn2 <= to_signed(integer(round(AMPLITUDE)), signed_fxp_sinusoid'length);

        rst <= '1';
        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delta cycles
        rst <= '0';

        answer_cos := to_signed(0, signed_fxp_sinusoid'length);
        assert ((yn = answer_cos)
            and (cos_w_out = to_signed(0, signed_fxp_sinusoid'length))
            and (yn1_out = to_signed(0, signed_fxp_sinusoid'length)))
            report "DFTGenerateReference: Failed (Reset)" severity warning;

        wait until rising_edge(clk); wait for CLK_PERIOD/10; -- delta cycles

        
        -- Doesn't test approximations using own outputs due to growing error making it hard to correctly assert
        for k_idx in 0 to WINDOW_WIDTH/2 -1 loop
            for n_idx in 0 to WINDOW_WIDTH-1 loop

                -- wait until rising_edge(clk):
                --      write new test parameters
                -- wait for delta cycles:
                --      check prev test
                -- wait until rising_edge(clk):
                --      ...
                
                -- Test cosine for k=? n=?
                wait until rising_edge(clk);

                prev_cos_w := cos_w;
                prev_yn1 := yn1;

                k := real(k_idx);
                n := real(n_idx);
                wk := 2.0 * MATH_PI * (k / real(WINDOW_WIDTH));
                answer_cos := to_signed(integer(round(AMPLITUDE * cos(n * wk))), signed_fxp_sinusoid'length);

                cos_w <= to_signed(integer(round(AMPLITUDE * cos(wk))), signed_fxp_sinusoid'length);
                yn1 <= to_signed(integer(round(AMPLITUDE * cos((n-1.0) * wk))), signed_fxp_sinusoid'length);
                yn2 <= to_signed(integer(round(AMPLITUDE * cos((n-2.0) * wk))), signed_fxp_sinusoid'length);

                -- Check prev test
                wait for CLK_PERIOD/10; -- delta cycles


                -- Test sine for k=? n=?
                wait until rising_edge(clk);

                prev_cos_w := cos_w;
                prev_yn1 := yn1;

                k := real(k_idx);
                n := real(n_idx);
                wk := 2.0 * MATH_PI * (k / real(WINDOW_WIDTH));
                answer_sin := to_signed(integer(round(AMPLITUDE * sin(n * wk))), signed_fxp_sinusoid'length);

                cos_w <= to_signed(integer(round(AMPLITUDE * cos(wk))), signed_fxp_sinusoid'length);
                yn1 <= to_signed(integer(round(AMPLITUDE * sin((n-1.0) * wk))), signed_fxp_sinusoid'length);
                yn2 <= to_signed(integer(round(AMPLITUDE * sin((n-2.0) * wk))), signed_fxp_sinusoid'length);


                -- Check prev test
                wait for CLK_PERIOD/10; -- delta cycles

                assert (assert_nearly_equal(yn, answer_cos, ASSERT_TOLERANCE)
                        and (cos_w_out = prev_cos_w) and (yn1_out = prev_yn1))
                report "DFTGenerateReference: Failed cosine (k=" & real'image(k) & ", n=" & real'image(n) & ")"
                    & LF & integer'image(to_integer(signed(yn))) & " was not " & integer'image(to_integer(signed(answer_cos)))
                severity warning;


                -- Test N/A
                wait until rising_edge(clk);

                prev_cos_w := cos_w;
                prev_yn1 := yn1;
                

                -- Check prev test
                wait for CLK_PERIOD/10; -- delta cycles

                assert (assert_nearly_equal(yn, answer_sin, ASSERT_TOLERANCE)
                    and (cos_w_out = prev_cos_w) and (yn1_out = prev_yn1))
                report "DFTGenerateReference: Failed sine (k=" & real'image(k) & ", n=" & real'image(n) & ")"
                    & LF & integer'image(to_integer(signed(yn))) & " was not " & integer'image(to_integer(signed(answer_sin)))
                severity warning;

            end loop;
        end loop;

        report "DFTGenerateReference: Test Complete";
        wait;

    end process UNIT_TEST;
    
end architecture test;