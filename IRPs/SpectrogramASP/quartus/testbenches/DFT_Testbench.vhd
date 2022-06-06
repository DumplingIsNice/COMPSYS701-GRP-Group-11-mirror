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
            x_direct_ready		: in std_logic;
            x_direct			: in signal_word;
            new_window  		: in std_logic;
            -- outputs
            enable				: out std_logic; -- value of x must change each clk cycle - disable to stall operation
            rst_sinusoid		: out std_logic; -- reset sinusoid approximation and contents, but keep c_sum in pipeline
            update_output       : out std_logic; -- update magnitudes register

            x                   : out signal_word;
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
            magnitudes			: out magnitudes_array;
            output_updated      : out std_logic
		);
	end component DFTDataPath;

    constant    CLK_PERIOD  : time      := 10 ns;
    signal      clk         : std_logic := '0';
    signal      rst         : std_logic := '0';

    signal x_direct_ready   : std_logic := '0';
    signal x_direct         : signal_word := (others => '0');
    signal new_window       : std_logic := '0';

    signal enable           : std_logic := '0';
    signal rst_sinusoid     : std_logic := '0';
    signal update_output    : std_logic := '0';
    signal output_updated	: std_logic := '0';

    signal noc_recv         : tdma_min_port;

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
            x_direct_ready	=> x_direct_ready,
            x_direct => x_direct,
            new_window => new_window,
            -- outputs
            enable => enable,
            rst_sinusoid => rst_sinusoid,
            update_output => update_output,

            x => x,
            -- noc
            noc_send => open,
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
            magnitudes => magnitudes,
            output_updated => output_updated
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
        wait for 4*CLK_PERIOD; -- let initiatialistions propagate through pipeline
    

        -- set input mode as direct via NoC
        noc_recv.data(31) <= '1';
        noc_recv.data(27 downto 24) <= x"6"; -- NOC_SET_INPUT_MODE
        noc_recv.data(15 downto 0) <= x"0002"; -- NOC_INPUT_MODE_DIRECT
        wait for CLK_PERIOD;
        noc_recv.data <= (others => '0');

        -- set run mode as auto via NoC
        noc_recv.data(31) <= '1';
        noc_recv.data(27 downto 24) <= x"5"; -- NOC_SET_RUN_MODE
        noc_recv.data(15 downto 0) <= x"0001"; -- NOC_RUN_MODE_AUTO
        wait for CLK_PERIOD;
        noc_recv.data <= (others => '0');


        -- enable via NoC
        noc_recv.data(31) <= '1';
        noc_recv.data(27 downto 24) <= x"2"; -- NOC_SET_ENABLE

        -- signal that direct input is ready
        x_direct_ready <= '1';
        
        -- input feed test (arbitrary value)
        x_direct <= to_signed(14000, signal_word'length);
        wait for CLK_PERIOD;
        noc_recv.data <= (others => '0');


        -- Test with generated data
        new_window <= '1';
        wait until rising_edge(clk);
        wait for CLK_PERIOD/2;
        new_window <= '0';

        file_open(file_test_signal, "int16_signal.txt", read_mode);

        for x_idx in 0 to WINDOW_WIDTH-1 loop
            wait for CLK_PERIOD/5;

            readline(file_test_signal, test_signal_line);
            read(test_signal_line, test_signal_int);
            
            test_signal_sample := to_signed(test_signal_int, signal_word'length);
            x_direct <= test_signal_sample;

            wait until rising_edge(clk);
        end loop;
        
        wait until falling_edge(clk);
        wait for 3 * CLK_PERIOD; -- pipeline delay is 3 full cycles
        wait for CLK_PERIOD + CLK_PERIOD/10;  -- wait for output to update (cycle + delta)

        x_direct_ready <= '0'; -- disable processing

        file_open(file_log, "test_log.txt", write_mode);
        for k_idx in 0 to K_LENGTH-1 loop
            write(log_line, to_integer(magnitudes(k_idx)));
            writeline(file_log, log_line);
        end loop;

        file_close(file_test_signal);
        file_close(file_log);

        report "x-DIRECT LOGGING COMPLETE";


        -- -- With NoC Feed


        -- set input mode as NoC via NoC
        noc_recv.data(31) <= '1';
        noc_recv.data(27 downto 24) <= x"6"; -- NOC_SET_INPUT_MODE
        noc_recv.data(15 downto 0) <= x"0001"; -- NOC_INPUT_MODE_NOC
        wait for CLK_PERIOD;
        noc_recv.data <= (others => '0');

        -- set run mode as auto via NoC
        noc_recv.data(31) <= '1';
        noc_recv.data(27 downto 24) <= x"5"; -- NOC_SET_RUN_MODE
        noc_recv.data(15 downto 0) <= x"0001"; -- NOC_RUN_MODE_AUTO
        wait for CLK_PERIOD;
        noc_recv.data <= (others => '0');


        -- Test with generated data
        new_window <= '1';
        wait until rising_edge(clk);
        wait for CLK_PERIOD/2;
        new_window <= '0';

        file_open(file_test_signal, "int16_signal.txt", read_mode);

        for x_idx in 0 to WINDOW_WIDTH-1 loop
            wait for CLK_PERIOD/5;

            readline(file_test_signal, test_signal_line);
            read(test_signal_line, test_signal_int);
            
            test_signal_sample := to_signed(test_signal_int, signal_word'length);
            
            noc_recv.data(31) <= '1';
            noc_recv.data(27 downto 24) <= x"3"; -- NOC_NEW_SAMPLE
            noc_recv.data(15 downto 0) <= std_logic_vector(test_signal_sample);

            wait until rising_edge(clk);

            wait for CLK_PERIOD/5;
            noc_recv.data <= (others => '0'); -- simulate gap between packets in NoC
            
            wait until rising_edge(clk);
        end loop;


        -- enable via NoC
        noc_recv.data(31) <= '1';
        noc_recv.data(27 downto 24) <= x"2"; -- NOC_SET_ENABLE

        wait for CLK_PERIOD;
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';


        file_open(file_log, "test_log_noc.txt", write_mode);
        for k_idx in 0 to K_LENGTH-1 loop
            write(log_line, to_integer(magnitudes(k_idx)));
            writeline(file_log, log_line);
        end loop;

        file_close(file_test_signal);
        file_close(file_log);

        report "x-NoC LOGGING COMPLETE";
        wait;

    end process test;
    
    
end architecture test;

