library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.ReCOPTypes.all;

entity ReCOPAddressRegister is
    generic (
        AR_init             : in recop_mem_addr := (others => '0')
    );
    port (
        clk                 : in std_logic;
        rst                 : in std_logic;
        -- control
        wr_AR               : in std_logic;
        mux_select          : in std_logic_vector(1 downto 0);

        -- inputs
        Ry                  : in recop_reg;
        SP_incremented      : in recop_mem_addr;
        SP                  : in recop_mem_addr;
        immediate           : in recop_reg;
        -- outputs
        DM_ADR              : out recop_mem_addr
    );
end entity ReCOPAddressRegister;

architecture rtl of ReCOPAddressRegister is
    
begin

    main: process(clk)
        variable v_AR       : recop_mem_addr    := AR_init;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                v_AR := AR_init;
            else
                if wr_AR = '1' then
                    case mux_select is
                        when "00" =>
                            -- push
                            v_AR := SP_incremented;
                        when "01" =>
                            -- pull/pop
                            v_AR := SP;
                        when "10" =>
                            -- register Ry
                            v_AR := Ry;
                        when "11" =>
                            -- immediate (instruction operand)
                            v_AR := immediate;
                        when others =>
                            -- do nothing;
                    end case;
                end if;
            end if;

            DM_ADR <= v_AR;
        end if;
    end process main;

    
end architecture rtl;