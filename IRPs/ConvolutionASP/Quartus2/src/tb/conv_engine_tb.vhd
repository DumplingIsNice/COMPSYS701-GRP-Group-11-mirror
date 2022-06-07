library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.CommonTypes.all;

entity conv_engine_tb is
end conv_engine_tb;

architecture tb of conv_engine_tb is
    signal clk, en         : std_logic := '0';
    constant clk_period    : Time      := 20 ns;

    signal init            : std_logic;

    signal krnl_ld, img_ld, conv_done   : std_logic := '0';
    signal krnl_data                    : krnl_mem;
    signal img_data                     : img_row := (others => (others => '0'));
    signal conv_data                    : true_rec_data_row := (others => (others => '0'));

    signal krnl         : krnl_mem  := (others => (others => (others => '0')));
    signal img          : img_mem   := (others => (others => (others => '0')));

    constant KRNL_CONTENT : krnl_mem := (
        (int_to_matrix_elem_8(1), int_to_matrix_elem_8(3), int_to_matrix_elem_8(2)),
        (int_to_matrix_elem_8(2), int_to_matrix_elem_8(1), int_to_matrix_elem_8(3)),   
        (int_to_matrix_elem_8(3), int_to_matrix_elem_8(2), int_to_matrix_elem_8(1))
    );

begin

    clk         <= not clk after clk_period/2;
    init      <= '1' after 0 ns, '0' after 30 ns;

    init_mem: process(init)
    begin
        for i in pad_sz_w to img_w-1-pad_sz_w loop
            for j in pad_sz_h to img_h-1-pad_sz_h loop
                img(i)(j) <= int_to_matrix_elem_32(i);
            end loop;
        end loop;

        krnl <= KRNL_CONTENT;
    end process;

    img_gen: process(clk, en, conv_done) is
        variable x, y, cnt, cnt_y : integer := 0;
    begin
        if (rising_edge(clk)) then
            if (en = '1') then
                if (conv_done = '1') then
                    img_data <= img(cnt);
                    if (cnt > img_h-2) then
                        cnt := 0;
                    else
                        if (cnt_y > krnl_w-2) then
                            cnt_y := 0;
                        else
                            cnt_y := cnt_y + 1;
                        end if;
    
                        cnt := cnt + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    img_ld <= conv_done;

    krnl_gen: process(init, clk) is
    begin
        if (rising_edge(clk)) then
            if (init = '1') then
                krnl_ld <= '1';
                krnl_data <= krnl;
            else
                krnl_ld <= '0';
            end if;
        end if;
    end process;

    en <= not init;

    conv_engine : entity work.conv_engine
        port map(
            clk         => clk,
            en          => en,
            krnl_ld     => krnl_ld,
            img_ld      => img_ld,
            krnl_data   => krnl_data,
            img_data    => img_data,
            conv_done   => conv_done,
            conv_data   => conv_data
        );

end tb;