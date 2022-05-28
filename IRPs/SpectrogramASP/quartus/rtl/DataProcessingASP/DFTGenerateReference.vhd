library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.DFTTypes.all;

entity DFTGenerateReference is
	port (
        clk		        : in std_logic;
        rst             : in std_logic;

        -- inputs from previous link
        cos_w           : in signed_fxp_sinusoid;
        yn1             : in signed_fxp_sinusoid;
        yn2             : in signed_fxp_sinusoid;
        -- outputs
        cos_w_out       : out signed_fxp_sinusoid   := (others => '0');
        yn1_out         : out signed_fxp_sinusoid   := (others => '0');
        yn              : out signed_fxp_sinusoid   := (others => '0')
	);
end entity;

architecture rtl of DFTGenerateReference is
    
begin
    
    main: process(clk)
        -- working vars (synthesiser will optimise)
        variable v_yn_mult  : signed(2*signed_fxp_sinusoid'length +1 -1 downto 0)     := (others => '0');
        variable v_yn_sub   : signed(signed_fxp_sinusoid'length +2 -1 downto 0)       := (others => '0');
            -- create so '-' operations are not needlessly generated for extra mult bits
        -- output
        variable v_yn       : signed(yn'range)                                  := (others => '0');
    begin
        if rising_edge(clk) then
            if rst = '1' then
                v_yn_mult   := (others => '0');
                v_yn_sub    := (others => '0');
            else
                v_yn_mult := resize(shift_left(cos_w, 1) * yn1, v_yn_mult'length);

                v_yn_sub := v_yn_mult(v_yn_sub'length-1 + signed_fxp_sinusoid'length-1 downto signed_fxp_sinusoid'length-1)
                            - resize(yn2, v_yn_sub'length);
                v_yn := v_yn_sub(v_yn'range);
            end if;

        yn <= v_yn;
        yn1_out <= yn1;
        cos_w_out <= cos_w;
        end if;
    end process main;
    
end architecture rtl;