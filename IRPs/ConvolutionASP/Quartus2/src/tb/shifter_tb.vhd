library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.CommonTypes.all;
use work.TdmaMinTypes.all;

entity shifter_tb is
end shifter_tb;

architecture tb of shifter_tb is
    signal shift_i   : matrix_elem_32;
    signal sl_sel    : std_logic_vector(2 downto 0);
    signal mux_sel   : std_logic_vector(3 downto 0);
    signal shift_o   : matrix_elem_32;
    signal en        : boolean;

    signal clk : std_logic := '0';
    constant clk_period          : Time      := 20 ns;
begin

    clk         <= not clk after clk_period/2;

    shift_i     <= "00000000111111111111111111111111"--std_logic_vector(to_signed(, shift_i'length)) after 0 ns
    -- std_logic_vector(to_signed(1, shift_i'length)) after 10 ns,
    -- std_logic_vector(to_signed(34, shift_i'length)) after 20 ns,
    -- std_logic_vector(to_signed(234, shift_i'length)) after 30 ns,
    -- std_logic_vector(to_signed(255, shift_i'length)) after 40 ns
    ;

    sl_sel_gen: process (clk) is
        variable cnt : integer := 0;
    begin
        if (rising_edge(clk)) then
            sl_sel <=
            std_logic_vector(to_signed(cnt, sl_sel'length)) after 10 ns
            ;
            if (cnt > 7) then
                cnt := 0;
            else
                cnt := cnt + 1;
            end if;
        end if;
    end process;

    mux_sel     <=  std_logic_vector(to_signed(1, mux_sel'length)) after 0 ns;
                    -- std_logic_vector(to_signed(1, mux_sel'length)) after 5 ns, 
                    -- std_logic_vector(to_signed(0, mux_sel'length)) after 100 ns;
    en          <= true;

    shifter : entity work.shifter
        port map (
            en       => en,
            shift_i   => shift_i,
            sl_sel    => sl_sel,
            mux_sel   => mux_sel,
            shift_o   => shift_o
        );

end tb;