library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;
use work.TdmaMinTypes.all;

entity GRP_Testbench is
	generic (
		ports : positive := 8
	);
end entity;

architecture test of GRP_Testbench is

    constant CLK_PERIOD     : time := 10 ns;
	signal clk              : std_logic := '1';
	signal rst				: std_logic := '0';

    signal magnitudes          	: magnitudes_array;
	signal magnitudes_updated	: std_logic;

	signal KEY           		: std_logic_vector(3 downto 0) := (others => '1'); -- default unpressed
	signal SW            		: std_logic_vector(9 downto 0) := (others => '0'); -- default unselected
	signal LEDR          		: std_logic_vector(9 downto 0);
	signal HEX0          		: std_logic_vector(6 downto 0);
	signal HEX1          		: std_logic_vector(6 downto 0);
	signal HEX2          		: std_logic_vector(6 downto 0);
	signal HEX3          		: std_logic_vector(6 downto 0);
	signal HEX4          		: std_logic_vector(6 downto 0);
	signal HEX5          		: std_logic_vector(6 downto 0);

	signal send_port : tdma_min_ports(0 to ports-1);
	signal recv_port : tdma_min_ports(0 to ports-1);

begin

	clk <= not clk after 10 ns;

	tdma_min : entity work.TdmaMin
	generic map (
		ports => ports
	)
	port map (
		clock => clk,
		sends => send_port,
		recvs => recv_port
	);

	asp_adc : entity work.TestAdc
	generic map (
		forward => 2 -- 2 to asp_tasktwo, 1 to asp_dac
	)
	port map (
		clock => clk,
		send  => send_port(0),
		recv  => recv_port(0)
	);

	asp_dac : entity work.TestDac
	port map (
		clock => clk,
		send  => send_port(1),
		recv  => recv_port(1)
	);
	
    asp_dft: entity work.DataProcessingASP
    port map (
        clk => clk,
        rst	=> rst,

        -- inputs
        x_direct_ready => '0', -- unimplemented, NoC only
        x_direct => (others => '0'),
        -- outputs
        magnitudes => magnitudes,
        magnitudes_updated => magnitudes_updated,
        -- NoC
        noc_send => send_port(2),
        noc_recv => recv_port(2)
    );

	DispFrequency : entity work.DispPrimaryFrequency
	port map (
		clk => clk,
		rst => rst,
		-- inputs
		start_run => magnitudes_updated,
		magnitudes => magnitudes,
		-- outputs
		seg0 => HEX0,
		seg1 => HEX1,
		seg2 => HEX2,
		seg3 => HEX3,
		seg4 => HEX4,
		seg5 => HEX5
	);

	asp_control : entity work.AspControl
	port map (
		clock => clk,

		key => KEY,
		sw => SW,

		ledr => LEDR,

		send => send_port(4),
		recv => recv_port(4)
	);


    -- Init the DFT-ASP via hardware, in lieu of ReCOP
    INIT_DFT: process(clk)
		constant test_port	: natural := 7; -- co-opt an unused port
		constant dft_port	: std_logic_vector(7 downto 0) := x"02";

		constant port_delay : integer := 8;
		variable port_delay_counter : integer := 0;

		variable send_data	: tdma_min_data	  := (others => '0');

		variable state : std_logic_vector(3 downto 0) := x"0";
		variable edge3 : std_logic := '1';
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state := x"0";
				edge3 := '1';

				send_data := (others => '0');
			else
				if (KEY(3) = '0' and edge3 = '1') then
					state := x"0";
				end if;
				edge3 := KEY(3);

				if (port_delay_counter < port_delay) then -- wait for NoC to send
					port_delay_counter := port_delay_counter + 1;
				else
					port_delay_counter := 0;

					send_data := (others => '0'); -- clear

					case state is
						when x"0" =>
							-- set input mode as NoC via NoC
							send_port(test_port).addr <= dft_port;
							send_data(31) := '1';
							send_data(27 downto 24) := x"6"; -- NOC_SET_INPUT_MODE
							send_data(15 downto 0) := x"0001"; -- NOC_INPUT_MODE_NOC

							state := x"1";
						when x"1" =>
							-- set run mode as auto
							send_port(test_port).addr <= dft_port;
							send_data(31) := '1';
							send_data(27 downto 24) := x"5"; -- NOC_SET_RUN_MODE
							send_data(15 downto 0) := x"0001"; -- NOC_RUN_MODE_AUTO

							state := x"2";
						when x"2" =>
							-- enable
							send_port(test_port).addr <= dft_port;
							send_data(31) := '1';
							send_data(27 downto 24) := x"2"; -- NOC_SET_ENABLE

							state := x"3";
						when x"3" =>
							-- start new window
							send_port(test_port).addr <= dft_port;
							send_data(31) := '1';
							send_data(27 downto 24) := x"4"; -- NOC_NEW_WINDOW

							state := x"4";
						when x"4" =>
							-- clear port
							send_data := (others => '0');

							state := x"5";
						when others =>
							-- do nothing
					end case;

					send_port(test_port).data <= send_data;
				end if;
			end if;
		end if;
	end process INIT_DFT;

end architecture test;
