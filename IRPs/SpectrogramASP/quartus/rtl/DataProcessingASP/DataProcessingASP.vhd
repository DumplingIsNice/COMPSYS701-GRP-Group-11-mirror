library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use STD.textio.all;

library work;
use work.DFTTypes.all;
use work.TdmaMinTypes.all;

-- Placeholder top level file for the ASP for rough synthesis

entity DataProcessingASP is
    port (
        clk     : in std_logic;
		rst		: in std_logic;

		magnitudes			: out magnitudes_array;

		noc_send			: out tdma_min_port;
		noc_recv			: in tdma_min_port
    );
end entity DataProcessingASP;

architecture rtl of DataProcessingASP is
    
    component DFTControlUnit is
        port (
            clk					: in std_logic;
            rst					: in std_logic;
    
            -- inputs
            x_ready				: in std_logic;
            new_window  		: in std_logic;
            -- outputs
            enable				: out std_logic; -- value of x must change each clk cycle - disable to stall operation
            rst_sinusoid		: out std_logic; -- reset sinusoid approximation and contents, but keep c_sum in pipeline
            update_output       : out std_logic; -- update magnitudes register
            output_updated		: out std_logic;
            -- noc
            noc_send			: out tdma_min_port;
            noc_recv			: in tdma_min_port
        );
    end component DFTControlUnit;

    component DFTDataPath is
		port (
            clk					: in std_logic;
            rst					: in std_logic;
    
            -- control
            enable				: in std_logic; -- value of x must change each clk cycle - disable to stall operation
            rst_sinusoid		: in std_logic; -- reset sinusoid approximation and contents, but keep c_sum in pipeline
                -- redundant w/ combinatorial synthesis?
            update_output       : in std_logic; -- update magnitudes register
    
            -- inputs
            x					: in signal_word;
            -- outputs
            magnitudes			: out magnitudes_array
		);
	end component DFTDataPath;

    signal x_ready          : std_logic := '0';
    signal new_window       : std_logic := '0';

    signal enable           : std_logic := '0';
    signal rst_sinusoid     : std_logic := '0';
    signal update_output    : std_logic := '0';
    signal output_updated	: std_logic := '0';

    signal x                : signal_word;

begin

    ControlUnit: DFTControlUnit
        port map (
            clk	=> clk,
            rst	=> rst,
            -- inputs
            x_ready	=> x_ready,
            new_window => new_window,
            -- outputs
            enable => enable,
            rst_sinusoid => rst_sinusoid,
            update_output => update_output,
            output_updated => output_updated,
            -- noc
            noc_send => noc_send,
            noc_recv => noc_recv
        );

    DataPath: DFTDataPath
		port map (
			clk	=> clk,
			rst => rst,

			-- control
			enable => enable,
			rst_sinusoid => rst_sinusoid,
			update_output => update_output,
            -- inputs
            x => x,
            -- outputs
            magnitudes => magnitudes
		);

end architecture rtl;