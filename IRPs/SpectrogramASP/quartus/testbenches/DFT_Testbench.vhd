library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use STD.textio.all;

library work;
use work.DFTTypes.all;
use work.TdmaMinTypes.all;

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

    constant    CLK_PERIOD  : time      := 10 ns;
    signal      clk         : std_logic := '0';
    signal      rst         : std_logic := '0';

    signal x_ready          : std_logic := '0';
    signal new_window       : std_logic := '0';

    signal enable           : std_logic := '0';
    signal rst_sinusoid     : std_logic := '0';
    signal update_output    : std_logic := '0';
    signal output_updated	: std_logic := '0';

    signal x                : signal_word;

    signal magnitudes       : magnitudes_array;

begin

    clk <= not clk after CLK_PERIOD/2;
    placeholder <= clk;

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
            noc_send => open,
            noc_recv => (others => (others => '0'))
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
    
    test: process
        variable counter : integer := 0;

        file        file_test_signal    : text;
        variable    test_signal_line    : line;
        variable    test_signal_int     : integer;
        variable    test_signal_sample  : signal_word;

        file        file_log            : text;
        variable    log_line            : line;
    begin
        wait for 4*CLK_PERIOD; 
    
        x_ready <= '1';
        x <= to_signed(14000, signal_word'length);
        wait for CLK_PERIOD;


        -- Test with generated data
        new_window <= '1';
        wait for CLK_PERIOD;
        new_window <= '0';

        file_open(file_test_signal, "int16_signal.txt", read_mode);

        for x_idx in 0 to WINDOW_WIDTH-1 loop
            readline(file_test_signal, test_signal_line);
            read(test_signal_line, test_signal_int);
            
            test_signal_sample := to_signed(test_signal_int, signal_word'length);
            x <= test_signal_sample;

            wait until rising_edge(clk);
        end loop;

        x_ready <= '0'; -- disable processing

        wait for 3 * CLK_PERIOD; -- pipeline delay is 3 full cycles

        file_open(file_log, "test_log.txt", write_mode);
        for k_idx in 0 to K_LENGTH-1 loop
            write(log_line, to_integer(magnitudes(k_idx)));
            writeline(file_log, log_line);
        end loop;

        file_close(file_test_signal);
        file_close(file_log);

        report "LOGGING COMPLETE";
        wait;

    end process test;
    
    
end architecture test;

