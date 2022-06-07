library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.TdmaMinTypes.all;

entity AspControl is
	port (
		clock : in  std_logic;

		key   : in  std_logic_vector(3 downto 0);
		sw    : in  std_logic_vector(9 downto 0);
		ledr  : out std_logic_vector(9 downto 0);

		send  : out tdma_min_port;
		recv  : in  tdma_min_port
	);
end entity;

architecture rtl of AspControl is
	signal audio_out_addr	: tdma_min_addr := x"01";	-- to dac
	-- note: should not actually receive audio data, added solely to enable/disable adc and dac
begin

	process(clock)
		variable edge, edge1  : std_logic;
		variable state : natural := 0;

		variable v_led	: std_logic_vector(9 downto 0);
	begin
		if rising_edge(clock) then
			-- Custom: Check for KEY1 press
			-- if key(1) = '0' and edge1 = '1' then
			-- 	if audio_out_addr = x"01" then
			-- 		audio_out_addr <= x"03"; 	-- output to alternate
			-- 	else
			-- 		audio_out_addr <= x"01";	-- output directly to DAC
			-- 	end if;
			-- end if;
			-- edge1 := key(1);
		
		
			-- Check for KEY0 press
			if key(0) = '0' and edge = '1' then
				if state > 4 then
					state := 4;
				else
					state := 9;
				end if;
			end if;
			edge := key(0);

			-- Process data if available
			if recv.data(31 downto 28) = "1000" and recv.data(16) = '0' and key(2) = '1' then
				send.addr <= audio_out_addr;
				send.data <= recv.data;
			elsif recv.data(31 downto 28) = "1000" and recv.data(16) = '1' and key(1) = '1' then
				send.addr <= audio_out_addr;
				send.data <= recv.data;

			-- Otherwise send configuration commands
			-- State 0 is disabled, state 5 is enabled
			else
				case state is

					-- Enable DAC channel 0
					when 9 =>
						send.addr <= x"01";
						send.data <= x"b1020000";
						state := 8;

					-- Enable DAC channel 1
					when 8 =>
						send.addr <= x"01";
						send.data <= x"b1030000";
						state := 7;

					-- Enable ADC channel 0
					when 7 =>
						send.addr <= x"00";
						send.data <= x"a0220000";
						state := 6;

					-- Enable ADC channel 1
					when 6 =>
						send.addr <= x"00";
						send.data <= x"a0230000";
						state := 5;

					-- Disable ADC channel 0
					when 4 =>
						send.addr <= x"00";
						send.data <= x"a0000000";
						state := 3;

					-- Disable ADC channel 1
					when 3 =>
						send.addr <= x"00";
						send.data <= x"a0010000";
						state := 2;

					-- Disable DAC channel 0
					when 2 =>
						send.addr <= x"01";
						send.data <= x"b1000000";
						state := 1;

					-- Disable DAC channel 1
					when 1 =>
						send.addr <= x"01";
						send.data <= x"b1010000";
						state := 0;

					when others =>
						send.addr <= x"01";
						send.data <= x"00000000";
				end case;
			end if;

			v_led := std_logic_vector(to_unsigned(state, v_led'length));
			ledr <= v_led;
		end if;
	end process;

end architecture;
