library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.CommonTypes.all;
use work.TdmaMinTypes.all;

entity multi_engine_tb is
end multi_engine_tb;

architecture tb of multi_engine_tb is
    signal clk                         : std_logic := '0';

    signal feature_i : matrix_elem_32;
    signal weight_i  : matrix_elem_8;
    signal result_o  : matrix_elem_32;

    constant clk_period          : Time      := 20 ns;
begin

    clk         <= not clk after clk_period/2;

    weight_i_gen: process (clk) is
        variable cnt    : integer := -42;
        variable cnt_y  : integer := 65500;
        -- variable cnt_y  : integer := 0;
    begin
        if (rising_edge(clk)) then
            weight_i <= 
            std_logic_vector(to_signed(cnt, weight_i'length)) after 10 ns
            ;
            feature_i <= std_logic_vector(to_unsigned(cnt_y, feature_i'length));

            if (cnt > 41) then
                cnt := -42;

                if (cnt_y > 65535) then
                    cnt_y := 0;
                else
                    cnt_y := cnt_y + 1;
                end if;
            else
                cnt := cnt + 1;
            end if;
        end if;
    end process;

    conv_engine : entity work.multi_engine
        port map(
            feature_i => feature_i,
            weight_i  => weight_i,
            result_o  => result_o
        );

end tb;