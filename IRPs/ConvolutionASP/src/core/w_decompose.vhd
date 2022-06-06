library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.CommonTypes.all;

-------------------------------------------------
-- Weight decomposition or signed, integer weights
-- Hao Lin 26/05/2022
-- Note: only stable up to +42 and -42
--       algorithm is not robust to cover all possible vales
-------------------------------------------------

entity w_decompose is
    port(
            w_i                         : in matrix_elem_8;
            rdy                         : out boolean;
            shift_a, shift_b, shift_c   : out std_logic_vector(2 downto 0);
            sel_a, sel_b, sel_c         : out std_logic_vector(3 downto 0)
    );
end entity; 

architecture rtl of w_decompose is
    type array_9 is array (0 to 8) of integer;

    constant comp_val : array_9     := (1, 2, 4, 8, 16, 32, 64, 128, 0);

    constant W_NEG  : std_logic_vector(3 downto 0)   := std_logic_vector(to_signed(-1, 4));
    constant W_POS  : std_logic_vector(3 downto 0)   := std_logic_vector(to_signed(1, 4));
    constant W_ZERO : std_logic_vector(3 downto 0)   := std_logic_vector(to_signed(0, 4));

    procedure IsBetween (
                            variable p : in integer;
                            variable t : out integer;
                            variable b : out integer
    ) is
        variable pos : integer;
        variable top : integer;
        variable bot : integer;
    begin
        pos := p;
        if (pos < comp_val(7)) and (pos > comp_val(6)) then
            top := 7;
            bot := 6;
        elsif (pos > comp_val(5)) then
            top := 6;
            bot := 5;
        elsif (pos > comp_val(4)) then
            top := 5;
            bot := 4;
        elsif (pos > comp_val(3)) then
            top := 4;
            bot := 3;
        elsif (pos > comp_val(2)) then
            top := 3;
            bot := 2;
        elsif (pos > comp_val(1)) then
            top := 2;
            bot := 1;
        elsif (pos > comp_val(0)) then
            top := 1;
            bot := 0;
        else
            top := 0;
            bot := 8;
        end if;
        t := top;
        b := bot;
    end procedure IsBetween;   

begin
    decomposition: process (w_i) is 
        variable is_pos, skip : boolean;
        variable w, w_positive  : signed(7 downto 0);
        variable a, b, c, a_diff, b_diff, c_diff, sum, w_int   : integer;

        variable sl_a, sl_b, sl_c : std_logic_vector(2 downto 0);
        variable w_a, w_b, w_c : std_logic_vector(3 downto 0);

        variable inv_w_a, inv_w_b, inv_w_c : integer;
    begin
        rdy <= false;
        skip := false;

        w := signed(w_i);
        w_positive := abs(w);
        w_int := to_integer(w_positive);

        sl_a := std_logic_vector(to_unsigned(0, sl_a'length));
        sl_b := std_logic_vector(to_unsigned(0, sl_b'length));
        sl_c := std_logic_vector(to_unsigned(0, sl_c'length));
        w_a := W_ZERO;
        w_b := W_ZERO;
        w_c := W_ZERO;

        if w > 0 then
            is_pos := true;
        elsif w < 0 then 
            is_pos := false;
        else 
            skip := true;
            is_pos := true;
        end if;
        
        sum := 0;
        
        if skip = false then
            -------------------------------------------------
            -- sl_a determination
            -------------------------------------------------
            IsBetween(w_int, a, b);
            
            a_diff := abs(comp_val(a) - w_int);
            b_diff := abs(comp_val(b) - w_int);
            c_diff := 0;
            
            if a_diff = 0 then
                sl_a := std_logic_vector(to_unsigned(a, sl_a'length));
                sl_b := std_logic_vector(to_unsigned(0, sl_b'length));
                sl_c := std_logic_vector(to_unsigned(0, sl_c'length));
                w_a := W_POS;
                w_b := W_ZERO;
                w_c := W_ZERO;
            elsif b_diff = 0 then
                sl_a := std_logic_vector(to_unsigned(b, sl_a'length));
                sl_b := std_logic_vector(to_unsigned(0, sl_b'length));
                sl_c := std_logic_vector(to_unsigned(0, sl_c'length));
                w_a := W_POS;
                w_b := W_ZERO;
                w_c := W_ZERO;
            else
                if (a_diff >= b_diff) then
                    sl_a := std_logic_vector(to_unsigned(b, sl_a'length));
                    sum := sum + to_integer(signed(W_POS))*comp_val(to_integer(unsigned(sl_a)));
            
                    if (sum > w_int) then
                        w_a := W_POS;
                        w_b := W_NEG;
                    elsif (sum < w_int) then
                        w_a := W_POS;
                        w_b := W_POS;
                    end if;
            
                    -------------------------------------------------
                    -- sl_b determination, branch b_diff
                    -------------------------------------------------
                    IsBetween(b_diff, a, c);
            
                    a_diff := abs(comp_val(a) - b_diff);
                    c_diff := abs(comp_val(c) - b_diff);
            
                    if a_diff = 0 then
                        sl_b := std_logic_vector(to_unsigned(a, sl_b'length));
                        sl_c := std_logic_vector(to_unsigned(0, sl_c'length));
                        w_c := W_ZERO;
                    elsif c_diff = 0 then
                        sl_b := std_logic_vector(to_unsigned(c, sl_b'length));
                        sl_c := std_logic_vector(to_unsigned(0, sl_c'length));
                        w_c := W_ZERO;
                    else
                        if (a_diff >= c_diff) then
                            sl_b := std_logic_vector(to_unsigned(c, sl_b'length));
                    
                            sum := sum + to_integer(signed(w_b))*comp_val(to_integer(unsigned(sl_b)));
            
                            if (sum > w_int) then
                                w_c := W_NEG;
                            elsif (sum < w_int) then
                                w_c := W_POS;
                            end if;
            
                            -------------------------------------------------
                            -- sl_c determination, branch b_diff, c_diff
                            -------------------------------------------------
                            IsBetween(c_diff, b, a);
                
                            b_diff := abs(comp_val(b) - c_diff);
                            a_diff := abs(comp_val(a) - c_diff);
            
                            if b_diff = 0 then
                                sl_c := std_logic_vector(to_unsigned(b, sl_c'length));
                            elsif a_diff = 0 then
                                sl_c := std_logic_vector(to_unsigned(a, sl_c'length));
                            end if;
                    
                        elsif (a_diff < c_diff) then
                            sl_b := std_logic_vector(to_unsigned(a, sl_b'length));
                    
                            sum := sum + to_integer(signed(w_b))*comp_val(to_integer(unsigned(sl_b)));
            
                            if (sum > w_int) then
                                w_c := W_NEG;
                            elsif (sum < w_int) then
                                w_c := W_POS;
                            end if;
            
                            -------------------------------------------------
                            -- sl_c determination, branch b_diff, a_diff
                            -------------------------------------------------
                            IsBetween(a_diff, b, c);
                
                            b_diff := abs(comp_val(b) - a_diff);
                            c_diff := abs(comp_val(c) - a_diff);
            
                            if b_diff = 0 then
                                sl_c := std_logic_vector(to_unsigned(b, sl_c'length));
                            elsif c_diff = 0 then
                                sl_c := std_logic_vector(to_unsigned(c, sl_c'length));
                            end if;
                        end if;
                    end if;
            
            --------------------------------------------------------- OG
                elsif (a_diff < b_diff) then
                    sl_a := std_logic_vector(to_unsigned(a, sl_a'length));
                    sum := sum + to_integer(signed(W_POS))*comp_val(to_integer(unsigned(sl_a)));
            
                    if (sum > w_int) then
                        w_a := W_POS;
                        w_b := W_NEG;
                    elsif (sum < w_int) then
                        w_a := W_POS;
                        w_b := W_POS;
                    end if;
            
                    -------------------------------------------------
                    -- sl_b determination, branch a_diff
                    -------------------------------------------------
                    IsBetween(a_diff, b, c);
            
                    b_diff := abs(comp_val(b) - a_diff);
                    c_diff := abs(comp_val(c) - a_diff);
            
                    if b_diff = 0 then
                        sl_b := std_logic_vector(to_unsigned(b, sl_b'length));
                        sl_c := std_logic_vector(to_unsigned(0, sl_c'length));
                        w_c := W_ZERO;
                    elsif c_diff = 0 then
                        sl_b := std_logic_vector(to_unsigned(c, sl_b'length));
                        sl_c := std_logic_vector(to_unsigned(0, sl_c'length));
                        w_c := W_ZERO;
                    else
                        if (b_diff >= c_diff) then
                            sl_b := std_logic_vector(to_unsigned(c, sl_b'length));
            
                            sum := sum + to_integer(signed(w_b))*comp_val(to_integer(unsigned(sl_b)));
            
                            if (sum > w_int) then
                                w_c := W_NEG;
                            elsif (sum < w_int) then
                                w_c := W_POS;
                            end if;
            
                            -------------------------------------------------
                            -- sl_c determination, branch a_diff, c_diff
                            -------------------------------------------------
                            IsBetween(c_diff, a, b);
                    
                            a_diff := abs(comp_val(a) - c_diff);
                            b_diff := abs(comp_val(b) - c_diff);
            
                            if a_diff = 0 then
                                sl_c := std_logic_vector(to_unsigned(a, sl_c'length));
                            elsif b_diff = 0 then
                                sl_c := std_logic_vector(to_unsigned(b, sl_c'length));
                            end if;
                    
                        elsif (b_diff < c_diff) then
                            sl_b := std_logic_vector(to_unsigned(b, sl_b'length));
                    
                            sum := sum + to_integer(signed(w_b))*comp_val(to_integer(unsigned(sl_b)));
            
                            if (sum > w_int) then
                                w_c := W_NEG;
                            elsif (sum < w_int) then
                                w_c := W_POS;
                            end if;
            
                            -------------------------------------------------
                            -- sl_c determination, branch a_diff, b_diff
                            -------------------------------------------------
                            IsBetween(b_diff, a, c);
                
                            a_diff := abs(comp_val(a) - b_diff);
                            c_diff := abs(comp_val(c) - b_diff);
            
                            if a_diff = 0 then
                                sl_c := std_logic_vector(to_unsigned(a, sl_c'length));
                            elsif c_diff = 0 then
                                sl_c := std_logic_vector(to_unsigned(c, sl_c'length));
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;

        inv_w_a := -to_integer(unsigned(w_a));
        inv_w_b := -to_integer(unsigned(w_b));
        inv_w_c := -to_integer(unsigned(w_c));

        -------------------------------------------------
        -- Final Signal Assignment
        -------------------------------------------------
        
        if (is_pos = false) then
            sel_a <= std_logic_vector(to_signed(inv_w_a, sel_a'length));
            sel_b <= std_logic_vector(to_signed(inv_w_b, sel_b'length));
            sel_c <= std_logic_vector(to_signed(inv_w_c, sel_c'length));
        else
            sel_a <= w_a;
            sel_b <= w_b;
            sel_c <= w_c;
        end if;

        shift_a <= sl_a;
        shift_b <= sl_b;
        shift_c <= sl_c;

        rdy <= true;

    end process decomposition;
end architecture rtl;