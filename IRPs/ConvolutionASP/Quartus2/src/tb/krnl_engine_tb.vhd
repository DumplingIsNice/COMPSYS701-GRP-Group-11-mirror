library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.CommonTypes.all;
use work.TdmaMinTypes.all;

entity krnl_engine_tb is
end krnl_engine_tb;

architecture tb of krnl_engine_tb is
    signal clk, en         : std_logic := '0';
    constant clk_period          : Time      := 20 ns;

    signal kernel_i    : krnl_weight_vec;
    signal feature_i   : krnl_word_vec;
    signal mac_o       : matrix_elem_32;

    constant KERNEL_CONTENT : krnl_weight_vec := (
        int_to_matrix_elem_8(3), int_to_matrix_elem_8(4), int_to_matrix_elem_8(4),
        int_to_matrix_elem_8(4), int_to_matrix_elem_8(2), int_to_matrix_elem_8(4),   
        int_to_matrix_elem_8(4), int_to_matrix_elem_8(4), int_to_matrix_elem_8(1)
    );

begin

    clk         <= not clk after clk_period/2;
    en <= '0', '1' after 20 ns, '0' after 40 ns;

    img_gen: process(en) is
        variable x, y : integer;
    begin
        x := 0;
        y := 0;

        for i in 0 to kernel_i'length-1 loop
            -- kernel_i(x) <= int_to_matrix_elem_8(100);
            feature_i(x) <= int_to_matrix_elem_32(x);
            x := x+1;
        end loop;
        kernel_i <= KERNEL_CONTENT;
    end process;

    krnl_engine : entity work.krnl_engine
        port map(
            kernel_i    => kernel_i,
            feature_i   => feature_i,
            mac_o       => mac_o
        );

end tb;