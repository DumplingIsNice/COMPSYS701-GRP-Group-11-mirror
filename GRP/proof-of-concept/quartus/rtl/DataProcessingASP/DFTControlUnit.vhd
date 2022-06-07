library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;
use work.TdmaMinTypes.all;

entity DFTControlUnit is
	port (
		clk					: in std_logic;
		rst					: in std_logic;

		-- inputs
		x_direct_ready		: in std_logic	 := '0';			-- 
		x_direct			: in signal_word := (others => '0');		-- bus meant for direct connect to the datapath (not streamed via NoC)
		new_window  		: in std_logic;

		-- outputs
		enable				: out std_logic	:= '0'; -- value of x must change each clk cycle - disable to stall operation
        rst_sinusoid		: out std_logic	:= '0'; -- reset sinusoid approximation and contents, but keep c_sum in pipeline
		update_output       : out std_logic	:= '0'; -- update magnitudes register

		x					: out signal_word;		-- muxed data to send to the datapath
	
		-- NoC
		noc_send			: out tdma_min_port;
		noc_recv			: in tdma_min_port
	);
end entity DFTControlUnit;

architecture rtl of DFTControlUnit is

	constant FORWARD_ADDR		: std_logic_vector(7 downto 0)		:= x"01"; -- forward audio packets to this addr

	constant NOC_SET_DISABLE	: std_logic_vector(27 downto 24)	:= x"1";
	constant NOC_SET_ENABLE		: std_logic_vector(27 downto 24) 	:= x"2";
	constant NOC_NEW_SAMPLE		: std_logic_vector(27 downto 24) 	:= x"3";
	constant NOC_NEW_WINDOW		: std_logic_vector(27 downto 24) 	:= x"4";
	constant NOC_SET_RUN_MODE	: std_logic_vector(27 downto 24) 	:= x"5";
	constant NOC_SET_INPUT_MODE : std_logic_vector(27 downto 24)	:= x"6";

	constant NOC_RUN_MODE_AUTO	: std_logic_vector(15 downto 0)		:= x"0001";
	constant NOC_RUN_MODE_TRIGGERED : std_logic_vector(15 downto 0)	:= x"0002";

	constant NOC_INPUT_MODE_NOC	: std_logic_vector(15 downto 0)		:= x"0001";
	constant NOC_INPUT_MODE_DIRECT : std_logic_vector(15 downto 0)	:= x"0002";

	constant AUDIO_DATA_HEADER	: std_logic_vector(3 downto 0)		:= "1000";

	signal	noc_rst_sinusoid	: std_logic := '0';
	signal	noc_enable			: std_logic := '0';
	signal	noc_select_direct_x	: std_logic := '0';

	signal	noc_x				: signal_word	:= (others => '0');
	signal	noc_x_ready			: std_logic		:= '0';

begin

	-- enable <= '1' when (noc_enable = '1' and
	-- 				((x_direct_ready = '1' and noc_select_direct_x = '1')
	-- 				or (noc_x_ready = '1' and noc_select_direct_x = '0'))) else '0';
	enable <= noc_enable;
					-- run datapath when enabled and data ready for processing
	rst_sinusoid <= '1' when (new_window = '1' or noc_rst_sinusoid = '1') else '0'; -- auto run starts new window

	x <= x_direct when noc_select_direct_x = '1' else noc_x;

	main: process(clk)
		constant PIPELINE_DELAY : natural	:= 3; -- clock cycles

		variable v_enable 		: std_logic := '0';
		variable v_rst_sinusoid : std_logic := '0';
		variable v_is_auto		: std_logic	:= '1';
		variable v_input_mode_direct	: std_logic := '0';

		variable v_noc_x		: signal_word := (others => '0');
		variable v_noc_x_ready	: std_logic := '0';

		variable v_prev_noc_enable : std_logic := '0'; -- capture edge

		variable window_done	: std_logic := '0'; -- internal flag used in trigger run mode to only run once
		variable v_update_output: std_logic := '0';
		variable x_index		: unsigned(natural(ceil(log2(real(WINDOW_WIDTH + PIPELINE_DELAY)))) downto 0)	:= (others => '0');
	begin
		if rising_edge(clk) then
			if rst = '1' then
				v_enable := '0';
				v_rst_sinusoid := '0';
				v_is_auto := '1';
				v_input_mode_direct := '0';

				v_noc_x := (others => '0');

				window_done := '0';

				-- x counter
				x_index := (others => '0');
				update_output <= '0';
			else

				noc_send.data <= (others => '0');

				if v_rst_sinusoid = '1' and noc_enable = '1' and v_prev_noc_enable = '1' then
					v_rst_sinusoid := '0'; -- cleared one full cycle after set
				end if;
				if v_noc_x_ready = '1' and noc_enable = '1' and v_prev_noc_enable = '1' then
					v_noc_x_ready := '0'; -- cleared one full cycle after set
				end if;
				if (v_update_output = '1' and noc_enable = '1' and v_prev_noc_enable = '1') then
					v_update_output := '0'; -- cleared one full cycle after set
				end if;

				v_prev_noc_enable := noc_enable;

				if noc_recv.data(31) = '1' then
					case noc_recv.data(27 downto 24) is
						when NOC_SET_ENABLE =>
							v_enable := '1';
						when NOC_SET_DISABLE =>
							v_enable := '0';
						when NOC_NEW_WINDOW =>
							v_rst_sinusoid := '1';
						when NOC_SET_RUN_MODE =>
							case noc_recv.data(15 downto 0) is
								when NOC_RUN_MODE_AUTO =>
									-- run as long as data is provided
									v_is_auto := '1';
								when NOC_RUN_MODE_TRIGGERED =>
									-- run one window and output, then do not update the output again until restarted
									-- (will continue to process in the background, if new data is provided)
									v_is_auto := '0';
								when others =>
									-- invalid
							end case;
						when NOC_SET_INPUT_MODE =>
							case noc_recv.data(15 downto 0) is
								when NOC_INPUT_MODE_DIRECT =>
									v_input_mode_direct := '1';
								when NOC_INPUT_MODE_NOC =>
									v_input_mode_direct := '0';
								when others =>
									-- invalid
							end case;
						when others =>
							-- append to 'others =>' to support adc formatting
							if (noc_recv.data(27 downto 24) = NOC_NEW_SAMPLE)
								or (noc_recv.data(31 downto 28) = AUDIO_DATA_HEADER) then
								v_noc_x_ready := '1'; -- set enable high for one cycle
								v_noc_x := resize(signed(noc_recv.data(15 downto 0)), signal_word'length);
								-- WARNING: assumes noc packet data size is matched to declared signal_word size!

								-- then forward audio packets
								noc_send.addr <= FORWARD_ADDR;
								noc_send.data <= noc_recv.data;
							end if;
							-- invalid
					end case;
				end if;

				-- x counter
				if new_window = '1' then
					x_index := (others => '0');
				else
					if noc_enable = '1' then
						x_index := x_index + 1;

						if window_done = '0' then
							if (x_index >= to_unsigned(WINDOW_WIDTH + PIPELINE_DELAY, x_index'length)) then
								x_index := to_unsigned(PIPELINE_DELAY, x_index'length);
								v_update_output := '1';
								if v_is_auto = '0' then
									window_done := '1';
								end if;
							end if;
						end if;
					end if;
				end if;
			end if;

			update_output <= v_update_output;

			if (v_enable = '1' and
				((x_direct_ready = '1' and noc_select_direct_x = '1')
				or (noc_x_ready = '1' and noc_select_direct_x = '0')))
				then
				noc_enable <= '1';
			else
				noc_enable <= '0';
			end if;

			noc_rst_sinusoid <= v_rst_sinusoid;

			noc_select_direct_x <= v_input_mode_direct;
			noc_x <= v_noc_x;
			noc_x_ready <= v_noc_x_ready;
		end if;
	end process main;
	
end architecture rtl;