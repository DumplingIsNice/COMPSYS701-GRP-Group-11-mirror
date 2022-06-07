library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.CommonTypes.all;

-------------------------------------------------
-- Primary 3x3 Kernel Convolution Module
-- Hao Lin 24/05/2022
-- 
-- Takes in vectorised form of kernel slice and 
-- corresponding weights + feature input
-------------------------------------------------

entity krnl_engine is
    port(
        kernel_i    : in krnl_weight_vec;
        feature_i   : in krnl_word_vec;
        mac_o       : out matrix_elem_32
    );
end krnl_engine;

architecture rtl of krnl_engine is 

component multi_engine 
port(
    feature_i : in matrix_elem_32;
    weight_i  : in matrix_elem_8;
    result_o  : out matrix_elem_32
);
end component;

signal feature_vec, results_vec      : krnl_word_vec   := (others => (others => '0'));
signal krnl_vec                      : krnl_weight_vec := (others => (others => '0'));
signal results_o                     : signed(31 downto 0)  := (others => '0');

begin

    multi_engine_gen: for i in krnl_vec'range generate
        for all : multi_engine use entity work.multi_engine;
    begin
        multi : multi_engine 
            port map(
                        feature_i => feature_vec(i), 
                        weight_i => krnl_vec(i), 
                        result_o => results_vec(i)
                    );
    end generate multi_engine_gen;

    sum: process(kernel_i, feature_i, results_vec) is
    begin
        krnl_vec <= kernel_i;
        feature_vec <= feature_i;

        results_o <= signed(results_vec(0))
                    +signed(results_vec(1))
                    +signed(results_vec(2))
                    +signed(results_vec(3))
                    +signed(results_vec(4))
                    +signed(results_vec(5))
                    +signed(results_vec(6))
                    +signed(results_vec(7))
                    +signed(results_vec(8))
        ;
    end process sum;

    mac_o <= std_logic_vector(results_o);
end architecture rtl;