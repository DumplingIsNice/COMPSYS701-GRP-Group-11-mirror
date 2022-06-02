library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;

entity DFTDataPathUnit is
	port (
        clk             : in std_logic;
        rst             : in std_logic;

		-- control
		restart			: in std_logic; -- reinitialise from LUT
        -- inputs
        cos_w_LUT       : in signed_fxp_sinusoid;
        yn1_LUT         : in signed_fxp_sinusoid;
        yn2_LUT         : in signed_fxp_sinusoid;
        x               : in signal_word;
        -- outputs
        c_sum           : out signed_correlation_sum
	);
end entity DFTDataPathUnit;

architecture rtl of DFTDataPathUnit is
	
	component DFTGenerateReference is
		port (
			clk		        : in std_logic;
			rst             : in std_logic;
			-- inputs
			cos_w           : in signed_fxp_sinusoid;
			yn1             : in signed_fxp_sinusoid;
			yn2             : in signed_fxp_sinusoid;
			-- outputs
			cos_w_out       : out signed_fxp_sinusoid;
			yn1_out         : out signed_fxp_sinusoid;
			yn              : out signed_fxp_sinusoid
		);
	end component DFTGenerateReference;

	component DFTSumCorrelation is
		port (
			clk		        : in std_logic;
			rst             : in std_logic;
			-- inputs
			x               : in signal_word;
			yn              : in signed_fxp_sinusoid;
			c_sum_in        : in signed_correlation_sum;
			-- outputs
			c_sum_out       : out signed_correlation_sum
		);
	end component DFTSumCorrelation;

    -- output from DFTGenerateReference
	signal yn1_out         : signed_fxp_sinusoid        := (others => '0');
	signal yn_out          : signed_fxp_sinusoid        := (others => '0');

    -- input to DFTGenerateReference (from self, or LUT)
	signal yn1_src         : signed_fxp_sinusoid;
	signal yn2_src         : signed_fxp_sinusoid;

    -- output from DFTSumCorrelation
	signal c_sum_out       : signed_correlation_sum     := (others => '0');

    -- input to DFTSumCorrelation (from self, or reset to 0)
	signal c_sum_src       : signed_correlation_sum;

begin

    -- WARNING:
    -- This circular wiring requires all outputs to be well-defined on initialisation.

    c_sum <= c_sum_out;

	yn1_src <= yn1_LUT when (rst = '1' or restart = '1') else yn_out;
	yn2_src <= yn2_LUT when (rst = '1' or restart = '1') else yn1_out;
	c_sum_src <= (others => '0') when (rst = '1' or restart = '1') else c_sum_out;

	GenerateReference: DFTGenerateReference
        port map (
            clk	=> clk,
            rst => rst,
            -- inputs from previous link
            cos_w => cos_w_LUT,
            yn1 => yn1_src,
            yn2 => yn2_src,
            -- outputs
            cos_w_out => open,
            yn1_out => yn1_out,
            yn => yn_out
        );

	SumCorrelation: DFTSumCorrelation
        port map (
            clk	=> clk,
            rst => rst,
            -- inputs
            x => x,
            yn => yn_out,
            c_sum_in => c_sum_src,
            -- outputs
            c_sum_out => c_sum_out
        );
	

	
end architecture rtl;