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
		x_ready				: in std_logic;
		new_window  		: in std_logic;

		-- outputs
		enable				: out std_logic	:= '0'; -- value of x must change each clk cycle - disable to stall operation
        rst_sinusoid		: out std_logic	:= '0'; -- reset sinusoid approximation and contents, but keep c_sum in pipeline
		update_output       : out std_logic	:= '0'; -- update magnitudes register
	
		-- NoC
		noc_send			: out tdma_min_port;
		noc_recv			: in tdma_min_port
	);
end entity DFTControlUnit;

architecture rtl of DFTControlUnit is

	constant NOC_SET_DISABLE	: std_logic_vector(27 downto 24)	:= x"1";
	constant NOC_SET_ENABLE		: std_logic_vector(27 downto 24) 	:= x"2";
	constant NOC_NEW_SAMPLE		: std_logic_vector(27 downto 24) 	:= x"3";
	constant NOC_NEW_WINDOW		: std_logic_vector(27 downto 24) 	:= x"4";
	constant NOC_SET_MODE		: std_logic_vector(27 downto 24) 	:= x"5";

	constant NOC_RUN_MODE_AUTO	: std_logic_vector(15 downto 0)		:= x"0001";
	constant NOC_RUN_MODE_TRIGGERED : std_logic_vector(15 downto 0)	:= x"0002";

	signal	noc_rst_sinusoid	: std_logic := '0';
	signal	noc_enable			: std_logic := '0';

begin

	-- placeholders
	-- rst_sinusoid <= new_window;
	-- enable <= x_ready;

	enable <= x_ready or noc_enable; -- data received from tdma min
	rst_sinusoid <= new_window or noc_rst_sinusoid; -- auto run starts new window  

	main: process(clk)
		constant PIPELINE_DELAY : natural	:= 3; -- clock cycles

		variable v_enable 		: std_logic := '0';
		variable v_rst_sinusoid : std_logic := '0';
		variable v_is_auto		: std_logic	:= '1';
		variable window_done	: std_logic := '0'; -- internal flag used in trigger run mode to only run once
		
		variable x_index		: unsigned(natural(ceil(log2(real(WINDOW_WIDTH + PIPELINE_DELAY)))) downto 0)	:= (others => '0');
	begin
		if rising_edge(clk) then
			if rst = '1' then
				v_enable := '0';
				v_rst_sinusoid := '0';
				window_done := '0';
				v_is_auto := '1';

				-- x counter
				x_index := (others => '0');
				update_output <= '0';
			else

				if v_rst_sinusoid = '1' then
					v_rst_sinusoid := '0'; -- cleared one cycle after set
				end if;

				if noc_recv.data(31) = '1' then
					case noc_recv.data(27 downto 24) is
						when NOC_SET_ENABLE =>
							v_enable := '1';
						when NOC_SET_DISABLE =>
							v_enable := '0';
						when NOC_NEW_WINDOW =>
							v_rst_sinusoid := '1';
						when NOC_SET_MODE =>
							case noc_recv.data(15 downto 0) is
								when NOC_RUN_MODE_AUTO =>
									v_is_auto := '1';
								when NOC_RUN_MODE_TRIGGERED =>
									v_is_auto := '0';
								when others =>
									-- invalid
							end case;
						-- when NOC_NEW_SAMPLE =>
						-- 	-- set enable high for one cycle
						-- 	-- load x
						when others =>
							-- invalid
					end case;
				end if;

				-- x counter
				if new_window = '1' then
					x_index := (others => '0');
				else
					x_index := x_index + 1;

					if window_done = '0' then
						if (x_index >= to_unsigned(WINDOW_WIDTH + PIPELINE_DELAY, x_index'length)) then
							x_index := to_unsigned(PIPELINE_DELAY, x_index'length);
							update_output <= '1';
							if v_is_auto = '0' then
								window_done := '1';
							end if;
						else
							update_output <= '0';
						end if;
					end if;
				end if;
			end if;

			noc_rst_sinusoid <= v_rst_sinusoid;
			noc_enable <= v_enable;
		end if;
	end process main;
	
end architecture rtl;