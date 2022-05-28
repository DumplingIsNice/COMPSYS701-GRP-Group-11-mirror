library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.TdmaMinTypes.all;

entity DataProcessingASP is
	-- generic (
	-- );
	port (
		clock		: in std_logic;
		noc_send	: out tdma_min_port;
		noc_recv	: in tdma_min_port
	);
end entity;

architecture rtl of DataProcessingASP is
begin

end rtl;