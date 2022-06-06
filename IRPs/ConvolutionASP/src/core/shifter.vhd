library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.CommonTypes.all;

-------------------------------------------------
-- A shifter (not barrel) AND [1, -1, 0] -> [positive, negative, zero] line mux
-- Hao Lin 24/05/2022
-------------------------------------------------

entity shifter is
    generic(
        LINE_WIDTH : integer := 32
    );
    port(
        en        : in boolean;
        shift_i   : in matrix_elem_32;
        sl_sel    : in std_logic_vector(2 downto 0);
        mux_sel   : in std_logic_vector(3 downto 0);
        shift_o   : out matrix_elem_32
    );
end entity shifter;

architecture rtl of shifter is
    signal pos_line, neg_line, shift_line : signed(LINE_WIDTH-1 downto 0) := (others => 'Z');
begin
    pos_line <= signed(shift_i);

    two_complement: process (pos_line)
        constant bit_mask : signed(LINE_WIDTH-1 downto 0) := "00000000000000001111111111111111"; -- "00000000111111111111111111111111";
        variable n_line   : signed(LINE_WIDTH-1 downto 0) := (others => '0');
    begin
        n_line := -signed(resize(pos_line, n_line'length));
        neg_line <= n_line; -- and bit_mask;
        
    end process two_complement; 

    mux: process (pos_line, neg_line, mux_sel)
    begin
        case to_integer(signed(mux_sel)) is 
        when 1 =>
            shift_line <= pos_line;
        when -1 =>
            shift_line <= neg_line;
        when others =>
            shift_line <= to_signed(0, shift_line'length);
        end case;
    end process mux;

    shifter: process (shift_line, sl_sel, en)
    variable s_o : signed(LINE_WIDTH-1 downto 0);
    begin
        if (en = true) then
            -- would shift_left() function be optimised? While it is not an barrel shifter, it accomplishes the result?
            s_o := shift_left(shift_line, to_integer(unsigned(sl_sel)));
        else
            s_o := to_signed(0, s_o'length);
        end if;
        shift_o <= std_logic_vector(s_o);
    end process shifter;   

end architecture rtl;
