library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;

entity pm_tb is
end pm_tb;

architecture tb of pm_tb is
    constant ADDR_WIDTH : integer := 10;
    constant WORD_SIZE : integer := 16;

    signal clk : std_logic := '0';
    signal addr : std_logic_vector(9 downto 0) := (others => '0');
    signal pm_o : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');

    constant clk_period          : Time      := 20 ns;

begin
    clk <= not clk after clk_period/2;

    pm: entity work.ReCOP_pm
        generic map(
            ADDR_WIDTH => ADDR_WIDTH,
            WORD_WIDTH => WORD_SIZE
        )
        port map(
            clk     => clk,
            addr    => addr,
            pm_o    => pm_o
        );

        addr_gen: process(clk) is 
            variable cnt : integer := 1000;
        begin
            if (rising_edge(clk)) then
                addr <= std_logic_vector(to_unsigned(cnt, addr'length));
    
                if (cnt > 1023) then
                    cnt := 0;
                else
                    cnt := cnt + 1;
                end if;
            end if;
        end process;
end tb;
