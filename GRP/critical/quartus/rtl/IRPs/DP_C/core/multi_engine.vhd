library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.CommonTypes.all;

-------------------------------------------------
-- Primary Convolution Module
-- Hao Lin 24/05/2022
-- 
-- Interacts with 1 input and 
-- all weights for MAC operation
-- 
-- Implements barrel shift
-- Outputs of shifters are added
-- for a kernel, the addition ar done in parallel
-------------------------------------------------

entity multi_engine is
    port(
        feature_i : in matrix_elem_32;
        weight_i  : in matrix_elem_8;
        result_o  : out matrix_elem_32
    );
end multi_engine;

architecture rtl of multi_engine is 
signal shift_a, shift_b, shift_c    : std_logic_vector(2 downto 0) := (others => '0');
signal sel_a, sel_b, sel_c          : std_logic_vector(3 downto 0) := (others => '0');

signal sum_a, sum_b, sum_c     : matrix_elem_32 := (others => '0');
signal sum_o                   : matrix_elem_32 := (others => '0');

signal w_rdy : boolean;

begin

    w_decompose : entity work.w_decompose
    port map (
        w_i     => weight_i,
        shift_a => shift_a,
        shift_b => shift_b,
        shift_c => shift_c,
        sel_a   => sel_a, 
        sel_b   => sel_b, 
        sel_c   => sel_c,
        rdy     => w_rdy
    );

    shifter_a: entity work.shifter
    port map (
        en        => w_rdy,
        shift_i   => feature_i,
        sl_sel    => shift_a,
        mux_sel   => sel_a,
        shift_o   => sum_a
    );

    shifter_b: entity work.shifter
    port map (
        en        => w_rdy,
        shift_i   => feature_i,
        sl_sel    => shift_b,
        mux_sel   => sel_b,
        shift_o   => sum_b
    );

    shifter_c: entity work.shifter
    port map (
        en        => w_rdy,
        shift_i   => feature_i,
        sl_sel    => shift_c,
        mux_sel   => sel_c,
        shift_o   => sum_c
    );

    sum_o <= std_logic_vector(unsigned(sum_a) + unsigned(sum_b) + unsigned(sum_c));

    result_o <= sum_o;

end architecture rtl;