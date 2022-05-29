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
        variable v_yn       : signed_fxp_sinusoid                                       := (others => '0');
        variable v_yn1      : signed_fxp_sinusoid                                       := (others => '0');
        variable v_cos_w    : signed_fxp_sinusoid                                       := (others => '0');
    begin
        if rising_edge(clk) then
            if rst = '1' then
                v_yn_mult   := (others => '0');
                v_yn_sub    := (others => '0');
                v_yn        := (others => '0');
                v_yn1       := (others => '0');
                v_cos_w     := (others => '0');
            else
                v_yn1 := yn1;
                v_cos_w := cos_w;

                v_yn_mult := (others => '0');
                v_yn_mult := resize(cos_w & '0', v_yn_mult'length);
                v_yn_mult := resize(v_yn_mult * yn1, v_yn_mult'length);

                -- note that the right shift is dividing by 2^15, when for accuracy it should be 2^15 -1
                v_yn_sub := v_yn_mult(v_yn_sub'length-1 + signed_fxp_sinusoid'length-1 downto signed_fxp_sinusoid'length-1)
                            - resize(yn2, v_yn_sub'length);
                v_yn := v_yn_sub(v_yn'range);
            end if;

        yn <= v_yn;
        yn1_out <= v_yn1;
        cos_w_out <= v_cos_w;
        end if;
    end process main;
    
end architecture rtl;