library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

entity DFTChannelLink is
	generic (
        input_width                 : natural   := 512; -- elements
        input_word_length           : natural   := 16;  -- bits
        sinusoid_word_length        : natural   := 16   -- bits
	);
	port (
        clk		        : in std_logic;
        rst		        : in std_logic;

        -- static input
        x               : in signed(input_word_length-1 downto 0); -- input element
        -- inputs from previous link
        cos_w_in        : in signed(sinusoid_word_length-1 downto 0);
        yn1_in          : in signed(sinusoid_word_length-1 downto 0); -- 16, sine precision
        yn2_in          : in signed(sinusoid_word_length-1 downto 0);
        prev_sum_in     : in signed(input_word_length +1 + natural(ceil(log2(real(input_width))))-1 downto 0);
        -- outputs
        cos_w_out       : out signed(sinusoid_word_length-1 downto 0);
        yn_out          : out signed(sinusoid_word_length-1 downto 0);
        yn1_out         : out signed(sinusoid_word_length-1 downto 0);
        sum             : out signed(input_word_length +1 + natural(ceil(log2(real(input_width))))-1 downto 0); -- 16 + log2(input_width)
        done            : out std_logic
	);
end entity;

architecture rtl of DFTChannelLink is
begin   
    pipeline: process(clk)
        -- capture inputs
        variable    cos_w           : signed(sinusoid_word_length-1 downto 0);
        variable    yn1             : signed(sinusoid_word_length-1 downto 0);
        variable    yn2             : signed(sinusoid_word_length-1 downto 0);
        variable    prev_sum        : signed(input_word_length + natural(ceil(log2(real(input_width))))-1 downto 0);

        -- output regs
        variable    yn              : signed(sinusoid_word_length-1 downto 0);
        variable    c               : signed(input_word_length +1 + natural(ceil(log2(real(input_width)))) -1 downto 0);
        
        -- internal regs
        variable    state           : std_logic_vector(3 downto 0)  := x"0";
            -- pipeline state: x"0" is reserved, x"f" is complete, x"1" to x"e" is progress through pipeline.
        variable    yn_mult         : signed(2*sinusoid_word_length +1 -1 downto 0);
        variable    c_mult          : signed(2*input_word_length -1 downto 0);
            -- compiler should optimise this out, only the first sinusoid_word_length bits are used
            -- this temporary variable is required since we can't slice a multiplier output
    begin

        if rising_edge(clk) then
            if rst = '1' then
                -- load inputs (excepting x, presumed to be static)
                cos_w := cos_w_in;
                yn1 := yn1_in;
                yn2 := yn2_in;
                prev_sum := prev_sum_in;

                -- reset counters, internal regs
                state   := x"1"; -- begin
            else
                case state is
                    -- yn = 2*cos_w*y[n-1] - y[n-2]
                    when x"1" =>
                        yn_mult := yn1 * (cos_w(cos_w'length-1 downto 0) & '0');
                            -- (cos_w << 1) to get 2*cos_w 
                            -- note how an extra bit is needed in yn_mult due to the shift, theoretical max amplitudes
                        state := x"2";
                    when x"2" =>
                        yn_mult := yn_mult(yn_mult'length-1 downto sinusoid_word_length-1) - resize(yn2, yn_mult'length);
                            -- remove amplitude scaling by >> by sinusoid_word_length-1 (-1 as we ignore sign bit)
                        yn := yn_mult(sinusoid_word_length-1 downto 0);
                            -- since sinusoid amplitude must be <= 1 we know the output must have a length of sinusoid_word_length,
                            -- so we may discard the upper half-word without loss of precision
                        state := x"3";
                    -- correlation[k][n] = y[k][n] * x[n]
                    when x"3" =>
                        c_mult := yn * x;
                        c := resize(c_mult(c_mult'length-1 downto sinusoid_word_length-1), c'length);
                            -- (c_mult >> sinusoid_word_length-1) to remove sin amplitude scaling, then pad to size of c
                        state := x"4";
                    -- correlation[k] = sum(y[k] * x)
                    when x"4" =>
                        c := c + prev_sum;
                        
                        -- complete!
                        state := x"f";
                    when others =>
                        -- invalid    
                end case;
            end if;

            if (state = x"f") then
                -- done
                cos_w_out <= cos_w;
                yn_out  <= yn;
                yn1_out <= yn1_in;
                sum     <= c;
                done <= '1';
            else
                -- not done
                cos_w_out <= (others => '0');
                yn_out  <= (others => '0');
                yn1_out <= (others => '0');
                sum     <= (others => '0');
                done <= '0';
            end if;
        end if;
    end process pipeline;

end rtl;