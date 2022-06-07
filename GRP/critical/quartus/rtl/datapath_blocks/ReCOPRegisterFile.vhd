library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

library work;
use work.ReCOPTypes.all;
use work.ReCOPConstants.all;

entity ReCOPRegisterFile is
	generic
	(
		DATA_WIDTH	: integer  :=	16
	);


	port
	(
		clk				: IN STD_LOGIC ;
		data				: IN STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
		wraddress		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		
		rdaddress_x		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		rdaddress_z		: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		
		wren				: IN STD_LOGIC  := '1';
		rden_x			: IN STD_LOGIC  := '1';
		rden_z			: IN STD_LOGIC  := '1';
		
		Rx					: OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0);
		Rz					: OUT STD_LOGIC_VECTOR (DATA_WIDTH-1 DOWNTO 0)
	);
	
end ReCOPRegisterFile;

architecture rtl of ReCOPRegisterFile is

	SIGNAL sub_wire0	: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL sub_wire1	: STD_LOGIC_VECTOR (15 DOWNTO 0);

	COMPONENT alt3pram
	GENERIC (
		width		: NATURAL;
		widthad		: NATURAL;
		indata_reg		: STRING;
		write_reg		: STRING;
		rdaddress_reg_a		: STRING;
		rdaddress_reg_b		: STRING;
		rdcontrol_reg_a		: STRING;
		rdcontrol_reg_b		: STRING;
		outdata_reg_a		: STRING;
		outdata_reg_b		: STRING;
		indata_aclr		: STRING;
		write_aclr		: STRING;
		rdaddress_aclr_a		: STRING;
		rdaddress_aclr_b		: STRING;
		rdcontrol_aclr_a		: STRING;
		rdcontrol_aclr_b		: STRING;
		outdata_aclr_a		: STRING;
		outdata_aclr_b		: STRING
	);
	PORT (
		qa					: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		qb					: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		wren				: IN STD_LOGIC ;
		inclock				: IN STD_LOGIC ;
		data				: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rden_a				: IN STD_LOGIC ;
		rdaddress_a			: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		wraddress			: IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		rden_b				: IN STD_LOGIC ;
		rdaddress_b			: IN STD_LOGIC_VECTOR (2 DOWNTO 0)
	);
	END COMPONENT;

begin

	Rx    <= sub_wire0(15 DOWNTO 0);
	Rz    <= sub_wire1(15 DOWNTO 0);

	alt3pram_component : alt3pram
	GENERIC MAP (
		width => DM_DATA_WIDTH,
		widthad => REG_FILE_DATA_WIDTH,
		indata_reg => "INCLOCK",
		write_reg => "INCLOCK",
		rdaddress_reg_a => "INCLOCK",
		rdaddress_reg_b => "INCLOCK",
		rdcontrol_reg_a => "INCLOCK",
		rdcontrol_reg_b => "INCLOCK",
		outdata_reg_a => "UNREGISTERED",
		outdata_reg_b => "UNREGISTERED",
		indata_aclr => "OFF",
		write_aclr => "OFF",
		rdaddress_aclr_a => "OFF",
		rdaddress_aclr_b => "OFF",
		rdcontrol_aclr_a => "OFF",
		rdcontrol_aclr_b => "OFF",
		outdata_aclr_a => "OFF",
		outdata_aclr_b => "OFF"
	)
	PORT MAP (
		wren => wren,
		inclock => clk,
		data => data,
		rden_a => rden_a,
		rdaddress_a => rdaddress_x,
		wraddress => wraddress,
		rden_b => rden_b,
		rdaddress_b => rdaddress_z,
		qa => sub_wire0,
		qb => sub_wire1
	);

end rtl;
