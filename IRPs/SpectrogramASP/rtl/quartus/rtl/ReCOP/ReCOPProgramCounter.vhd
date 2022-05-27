library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.ReCOPTypes.all;

entity ReCOPProgramCounter is
    generic (
        PC_init         : recop_mem_addr    := (others => '0')
    );
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        -- control
        wr_PC           : in std_logic;
        mux_select      : in std_logic_vector(1 downto 0);

        -- inputs
        DM_OUT          : in recop_mem_addr;
        Ry              : in recop_reg;
        operand         : in recop_mem_addr;
        -- outputs
        PM_ADR          : out recop_mem_addr
    );
end entity;

architecture rtl of ReCOPProgramCounter is
begin

    main: process(clk)
        variable v_PC                : recop_mem_addr    := PC_init;
    begin
        if rising_edge(clk) then

            if (rst = '1') then
                v_PC := PC_init;
            else
                if (wr_PC = '1') then
                    case mux_select is
                        when "00" =>
                            -- PC+1
                            v_PC := std_logic_vector(unsigned(v_PC) + to_unsigned(1, v_PC'length));
                        when "01" =>
                            -- write operand (from instruction operand)
                            v_PC := operand;
                        when "10" =>
                            -- write Ry (from register file)
                            v_PC := Ry;
                        when "11" =>
                            -- write DM_OUT (data memory output)
                            v_PC := DM_OUT;
                        when others =>
                            -- invalid
                    end case;
                end if;
            end if;

            PM_ADR <= v_PC;
        end if;
    end process main;

end architecture rtl;