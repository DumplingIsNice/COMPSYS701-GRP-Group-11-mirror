library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;

entity DFTControlUnit is
	port (
		clk					: in std_logic;
		rst					: in std_logic;

		-- inputs
		x_ready				: in std_logic;

		-- outputs
		enable				: out std_logic	:= '0'; -- value of x must change each clk cycle - disable to stall operation
        rst_sinusoid		: out std_logic	:= '0'; -- reset sinusoid approximation and contents, but keep c_sum in pipeline
		update_output       : out std_logic	:= '0' -- update magnitudes register
	);
end entity DFTControlUnit;

architecture rtl of DFTControlUnit is

	-- type fsm_state is (ST_RESET, ST_READY, ST_WORK, ST_EXIT);

	-- signal state		: fsm_state;
	-- signal next_state	: fsm_state;

begin

	enable <= x_ready;
	rst_sinusoid <= '0';

	k_counter: process(clk)
		variable k_index	: unsigned(natural(ceil(log2(real(K_LENGTH))))-1 downto 0)	:= (others => '0');
	begin
		if rising_edge(clk) then
			if rst = '1' then
				k_index := (others => '0');
				update_output <= '0';
			else
				k_index := k_index + 1;

				if (k_index >= K_LENGTH) then
					k_index := (others => '0');
					update_output <= '1';
				else
					update_output <= '0';
				end if;
			end if;
		end if;
	end process k_counter;

	-- update_state: process(clk)
	-- begin
	-- 	if rising_edge(clk) then
	-- 		if rst = '1' then
	-- 			state <= ST_RESET;
	-- 		else
	-- 			state <= next_state;
	-- 		end if;
	-- 	end if;
	-- end process update_state;

	-- state_change_logic: process(state, inputs)
	-- begin
	-- 	case state is
	-- 		when ST_RESET =>
	-- 			next_state <= ST_READY;
	-- 		when ST_WORK =>
	-- 		when others =>
	-- 			-- invalid
	-- 	end case;
	-- end process state_change_logic;
	
end architecture rtl;