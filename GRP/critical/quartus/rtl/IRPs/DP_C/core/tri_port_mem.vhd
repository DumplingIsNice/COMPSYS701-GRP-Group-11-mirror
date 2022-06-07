library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.CommonTypes.all;

-------------------------------------------------
-- Tri port, Asynchronyous Shifting Buffer Memory
-- Hao Lin 24/05/2022
-------------------------------------------------

entity tri_port_mem is
    generic(
        ADDR_WIDTH  : integer := 3;
        WORD_WIDTH  : integer := true_rec_data_w
    );
    port(
        clk         : in std_logic;
        data_i      : in img_row;
        data0_o     : out img_row;
        data1_o     : out img_row;
        data2_o     : out img_row
    );
end tri_port_mem;

architecture rtl of tri_port_mem is 
    type data_struc is array (0 to ADDR_WIDTH-1) of img_row;
    signal data : data_struc;
begin

    data0_o <= data(0);
    data1_o <= data(1);
    data2_o <= data(2);

    shift: process(clk, data, data_i) is
        variable d0, d1, d2 : img_row := (others => (others => '0'));
    begin
        if (rising_edge(clk)) then
            d2 := data(1);
            d1 := data(0);
            d0 := data_i;
        end if;
        
        data(2) <= d2;
        data(1) <= d1;
        data(0) <= d0;
    end process;

end architecture rtl;