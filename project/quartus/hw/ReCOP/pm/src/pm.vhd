library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity ReCOP_pm is
    generic(
        ADDR_WIDTH : natural := 10;
        WORD_WIDTH : natural := 32
    );
    port(
        clk : in std_logic;
        -- re
    -- IF EEPROM:
        -- pm_i
        -- rwe
        addr : in std_logic_vector(9 downto 0);
        pm_o : out std_logic_vector(31 downto 0)
    );
end entity;

architecture rtl of ReCOP_pm is
    -- type rom is array (0 to ADDR_WIDTH-1) of std_logic_vector(0 to WORD_WIDTH-1);
    -- signal pm_rom : rom;
    -- attribute ramstyle : string;
    -- attribute ramstyle of my_ram : signal is "M4K";
begin
	-- instance of internal ROM			  
	int_rom: lpm_rom
		generic map (
			lpm_widthad => ADDR_WIDTH,
			lpm_width => WORD_WIDTH,
            lpm_outdata => "REGISTERED",
			lpm_address_control => "REGISTERED",
			lpm_file => "ReCOP_pm.mif"
			)
		port map (
            inclock => clk,
            outclock => clk,
			address => addr,
			q => pm_o
			);
end rtl;