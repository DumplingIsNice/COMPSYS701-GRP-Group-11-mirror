library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.ReCOPTypes.all;

entity ReCOPStackPointer is
    generic (
        SP_init         : recop_mem_addr    := (others => '0')
        -- TODO: replace with TYPES from library!
    );
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        -- control
        wr_SP           : in std_logic;
        mux_select      : in std_logic_vector(1 downto 0);
        push_not_pull   : in std_logic; -- 1: push, 0: pull

        -- inputs
        DM_OUT          : in recop_mem_addr;
        immediate       : in recop_mem_addr;
        -- outputs
        SP              : out recop_mem_addr;
        SP_incremented  : out recop_mem_addr
    );
end entity;

architecture rtl of ReCOPStackPointer is
begin

    main: process(clk)
        variable v_SR                : recop_mem_addr    := SP_init;
    begin
        if rising_edge(clk) then

            if (rst = '1') then
                v_SR := SP_init;
            else
                if (wr_SP = '1') then
                    case mux_select is
                        when "00" =>
                            -- write +-SR (push or pull/pop)
                            if (push_not_pull = '1') then
                                v_SR := std_logic_vector(unsigned(v_SR) + to_unsigned(1, v_SR'length));
                            else
                                v_SR := std_logic_vector(unsigned(v_SR) - to_unsigned(1, v_SR'length));
                            end if;
                        when "01" =>
                            -- write DM_OUT (data memory output)
                            v_SR := DM_OUT;
                        when "10" =>
                            -- write immediate (from instruction operand)
                            v_SR := immediate;
                        when others =>
                            -- invalid
                    end case;
                end if;
            end if;

            SP_incremented <= std_logic_vector(unsigned(v_SR) + to_unsigned(1, v_SR'length)); -- use output value of v_SR
            SP <= v_SR;
        end if;
    end process main;

end architecture rtl;