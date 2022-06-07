library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.CommonTypes.all;
use work.TdmaMinTypes.all;

entity tri_port_mem_tb is
end tri_port_mem_tb;

architecture tb of tri_port_mem_tb is

    constant IMG_BUFF_W : integer  := img_w;
    constant IMG_BUFF_H : integer  := krnl_h;

    signal data_i                           : img_row;
    signal shift_e, init                    : boolean;
    signal data0_o, data1_o, data2_o        : img_row;

    signal img : img_mem := (others => (others => int_to_matrix_elem_32(0)));

    signal clk                  : std_logic := '0';
    constant clk_period         : Time      := 20 ns;
begin
    
    clk         <= not clk after clk_period/2;

    init      <= true after 0 ns, false after 10 ns;

    data_i_gen: process(clk) is
        variable cnt : integer := 0;
    begin
        if (rising_edge(clk)) then
            data_i    <= img(cnt);
            if (cnt > img_h-2) then
                cnt := 0;
            else
                cnt := cnt + 1;
            end if;
        end if;
    end process;

    init_mem: process(init)
    begin
        for i in 0 to img_w-1 loop
            for j in 0 to img_w-1 loop
                img(i)(j) <= int_to_matrix_elem_32(i);
            end loop;
        end loop;
    end process;

    mem : entity work.tri_port_mem
    generic map(
        ADDR_WIDTH => IMG_BUFF_H,
        WORD_WIDTH => IMG_BUFF_W
    )
	port map (
        clk => clk,
        data_i  => data_i,
        data0_o  => data0_o,
        data1_o  => data1_o,
        data2_o  => data2_o
	);

end tb;