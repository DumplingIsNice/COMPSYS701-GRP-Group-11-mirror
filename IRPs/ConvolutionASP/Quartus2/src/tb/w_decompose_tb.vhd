library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.CommonTypes.all;
use work.TdmaMinTypes.all;

entity w_decompose_tb is
end w_decompose_tb;

architecture tb of w_decompose_tb is
    signal w_i                         : matrix_elem_8;
    signal shift_a, shift_b, shift_c   : std_logic_vector(2 downto 0);
    signal sel_a, sel_b, sel_c         : std_logic_vector(3 downto 0);
    signal en, clk        : std_logic := '0';
    signal sum_w : integer;
    signal rdy   : boolean;

    constant clk_period          : Time      := 20 ns;
begin

    -- w_i <=
    -- std_logic_vector(to_signed(111, w_i'length)) after 10 ns
    -- ;
    en          <= '0';

    clk         <= not clk after clk_period/2;

    sum_w <= to_integer(signed(sel_a))*2**to_integer(unsigned(shift_a)) 
            + to_integer(signed(sel_b))*2**to_integer(unsigned(shift_b)) 
            + to_integer(signed(sel_c))*2**to_integer(unsigned(shift_c));

    w_i_gen: process (clk) is
        variable cnt : integer := -45;
    begin
        if (rising_edge(clk)) then
            w_i <=
            std_logic_vector(to_signed(cnt, w_i'length)) after 10 ns
            ;
            if (cnt > 45) then
                cnt := -45;
            else
                cnt := cnt + 1;
            end if;
        end if;
    end process;

    w_decompose : entity work.w_decompose
        port map (
            w_i     => w_i,
            shift_a => shift_a,
            shift_b => shift_b,
            shift_c => shift_c,
            sel_a   => sel_a, 
            sel_b   => sel_b, 
            sel_c   => sel_c,
            rdy     => rdy
        );

end tb;