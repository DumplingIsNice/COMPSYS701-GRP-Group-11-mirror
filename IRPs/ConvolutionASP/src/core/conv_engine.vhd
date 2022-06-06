library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.CommonTypes.all;

-------------------------------------------------
-- Primary Convolution Module
-- Hao Lin 30/05/2022
-- 
-- Takes in vectorised form of kernel slice and 
-- corresponding weights + feature input
-------------------------------------------------

entity conv_engine is
    port(
        clk         : in std_logic;
        en          : std_logic;

        krnl_ld     : in std_logic;
        img_ld      : in std_logic;
        krnl_data   : in krnl_mem;
        img_data    : in img_row;

        conv_done   : out std_logic;
        conv_data   : out true_rec_data_row
    );
end conv_engine;

architecture rtl of conv_engine is 

component krnl_engine 
port(
    kernel_i    : in krnl_weight_vec;
    feature_i   : in krnl_word_vec;
    mac_o       : out matrix_elem_32
);
end component;

type krnl_word_vec_array is array (natural range <>) of krnl_word_vec;
type krnl_weight_vec_array is array (natural range <>) of krnl_weight_vec;

constant IMG_BUFF_W   : integer  := img_w;
constant IMG_BUFF_H   : integer  := krnl_h;
constant PADDED_IMG_H : integer := img_h;
constant PADDED_IMG_W : integer := img_w;

-- Kernel engine ports
signal feature_i                    : krnl_word_vec                                 := (others => (others => '0'));
signal kernel_i                     : krnl_weight_vec                               := (others => (others => '0'));
signal conv_o                       : true_rec_data_row                             := (others => (others => '0'));
constant CONV_O_RANGE               : integer                                       := true_rec_data_w;

-- Local 3ximg_w buffer control signals & ports
signal img_data0, img_data1, img_data2      : img_row := (others => (others => '0'));

signal img_buff_clk, conv_d         : std_logic := '0';
signal mac_o                : matrix_elem_32 := (others => '0');

-- signal current_i : integer;

begin

    conv_data <= conv_o;
    conv_done <= conv_d;

    img_buff : entity work.tri_port_mem
    generic map(
        ADDR_WIDTH => PADDED_IMG_H,
        WORD_WIDTH => PADDED_IMG_W
    )
	port map (
        data_i  => img_data,
        clk => img_buff_clk,
        data0_o  => img_data0,
        data1_o  => img_data1,
        data2_o  => img_data2
	);

    img_buff_clk <= img_ld and en;

    iterate_coln: process(clk, en)
        variable i : integer := -1;
        variable var_conv_done : std_logic := '0';
        variable var_mac_o  : matrix_elem_32;
    begin
        if (rising_edge(clk)) then
            var_conv_done := '0';

            if (en = '1') then
                i := i + 1;
                var_mac_o := mac_o;
                if (i > true_rec_data_w) then
                    var_conv_done := '1';
                    i := -1;
                end if;
            elsif (conv_d = '1') then
                i := -1;
                var_conv_done := '1';
                var_mac_o := int_to_matrix_elem_32(0);
            end if;

            if (i > -1 and i < 32) then
                feature_i(0) <= img_data0(i);
                feature_i(1) <= img_data0(i+1);
                feature_i(2) <= img_data0(i+2);
                feature_i(3) <= img_data1(i);
                feature_i(4) <= img_data1(i+1);
                feature_i(5) <= img_data1(i+2);
                feature_i(6) <= img_data2(i);
                feature_i(7) <= img_data2(i+1);
                feature_i(8) <= img_data2(i+2);
            end if;

            if (i-1 > -1 and i-1 < 32) then
                conv_o(i-1) <= var_mac_o;
            end if;

            -- current_i <= i;
            conv_d    <= var_conv_done;
        end if;
    end process;

    krnl_buff : process(krnl_ld, krnl_data) is 
    begin
        if(rising_edge(krnl_ld)) then
            kernel_i(6) <= krnl_data(0)(0);
            kernel_i(7) <= krnl_data(0)(1);
            kernel_i(8) <= krnl_data(0)(2);
            kernel_i(3) <= krnl_data(1)(0);
            kernel_i(4) <= krnl_data(1)(1);
            kernel_i(5) <= krnl_data(1)(2);
            kernel_i(0) <= krnl_data(2)(0);
            kernel_i(1) <= krnl_data(2)(1);
            kernel_i(2) <= krnl_data(2)(2);
        end if;
    end process;

    -- -- 3D depth repeated wiring to fill out feature_i with the mem port interface:
    -- -- img_data0, img_data1, img_data2
    --     -- Must still loop through img_data0, img_data1, img_data2
    --     -- padded image No. of times to assign all values.
    --     -- Centered at [], for true_rec_data_w times
    --     -------------------------
    --     -- | i, i+1,    i+2 ... |
    --     -- | i, [i+1],  i+2 ... | -->
    --     -- | i, i+1,    i+2 ... |
    --     -------------------------
    -- krnl_engine_wiring_gen: for i in 0 to true_rec_data_w-1 generate
    -- begin
    --     iter_gen: for j in 0 to IMG_BUFF_W-1 generate
    --     begin
    --         feature_i(i)(0) <= img_data0(i);
    --         feature_i(i)(1) <= img_data0(i+1);
    --         feature_i(i)(2) <= img_data0(i+2);
    --         feature_i(i)(3) <= img_data1(i);
    --         feature_i(i)(4) <= img_data1(i+1);
    --         feature_i(i)(5) <= img_data1(i+2);
    --         feature_i(i)(6) <= img_data2(i);
    --         feature_i(i)(7) <= img_data2(i+1);
    --         feature_i(i)(8) <= img_data2(i+2);
    --     end generate iter_gen;
    -- end generate krnl_engine_wiring_gen;

    conv : entity work.krnl_engine 
        port map(
                kernel_i    => kernel_i,
                feature_i   => feature_i,
                mac_o       => mac_o
                );
end architecture rtl;