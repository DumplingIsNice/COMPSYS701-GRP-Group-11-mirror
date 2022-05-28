library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use STD.textio.all;

library work;
use work.DFTTypes.all;

entity DFT_Testbench is
    port (
        placeholder     : out std_logic
    );
end entity DFT_Testbench;

architecture test of DFT_Testbench is
    
    component DFTControlUnit is
        port (
            clk					: in std_logic;
            rst					: in std_logic;
    
            -- inputs
            x_ready				: in std_logic;
            -- outputs
            enable				: out std_logic; -- value of x must change each clk cycle - disable to stall operation
            rst_sinusoid		: out std_logic; -- reset sinusoid approximation and contents, but keep c_sum in pipeline
            update_output       : out std_logic -- update magnitudes register
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
            -- NoC
            -- noc_send			: out tdma_min_port;
            -- noc_recv			: in tdma_min_port
		);
	end component DFTDataPath;

    constant    CLK_PERIOD  : time      := 10 ns;
    signal      clk         : std_logic := '0';
    signal      rst         : std_logic := '0';

    signal x_ready          : std_logic := '0';

    signal enable           : std_logic := '0';
    signal rst_sinusoid     : std_logic := '0';
    signal update_output    : std_logic := '0';

    signal x                : signal_word;

begin

    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

    ControlUnit: DFTControlUnit
        port map (
            clk	=> clk,
            rst	=> rst,
            -- inputs
            x_ready	=> x_ready,
            -- outputs
            enable => enable,
            rst_sinusoid => rst_sinusoid,
            update_output => update_output
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
            magnitudes => open

			-- NoC
			-- noc_send			: out tdma_min_port;
			-- noc_recv			: in tdma_min_port
		);
    
   test: process
   begin
       -- TODO
        wait for 4*CLK_PERIOD; 
       
        x_ready <= '1';
        x <= to_signed(14000, signal_word'length);
        wait for CLK_PERIOD;

        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';

   end process test;
    
    
end architecture test;

