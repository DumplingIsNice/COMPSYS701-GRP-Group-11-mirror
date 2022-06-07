library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package data_type_package is
	type data_array_16 is array(natural range <>) of std_logic_vector(15 downto 0);
end package;

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.TdmaMinTypes.all;
use work.data_type_package.all;

entity DP_B is
	generic(dataInLength : integer;
				dataInWidth :integer;
				strideLength : integer;
				strideWidth : integer;
				id : integer
	);
	port(clock : in std_logic;
			send : out tdma_min_port;
			recv : in tdma_min_port;
			bufferDataIn : in data_array_16(dataInLength * dataInWidth - 1 downto 0);
			dataInReady : in std_logic;
			bufferDataOut : out data_array_16(dataInLength*dataInWidth/(strideLength*strideWidth) - 1 downto 0);
			finishedComputation : out std_logic
			);
end entity DP_B;

architecture beh of DP_B is
	component DP_B_IRP is
	generic(dataInLength : integer := 32;
				dataInWidth :integer := 32;
				strideLength : integer := 4;
				strideWidth : integer := 4;
				id : integer := 2
				);
	port(clock : in std_logic;
			bufferDataIn : in data_array_16(dataInLength * dataInWidth - 1 downto 0);
			dataInReady : in std_logic;
			controlPacketIn : in std_logic_vector(31 downto 0);
			bufferDataOut : out data_array_16(dataInLength*dataInWidth/(strideLength*strideWidth) - 1 downto 0);
			finishedComputation : out std_logic
			);
			
	end component;
	
	begin
		

	ASP : DP_B_IRP generic map(dataInLength, dataInWidth, strideLength, strideWidth, id) 
		port map(clock, 
					bufferDataIn, 
					dataInReady, 
					recv.data, 
					bufferDataOut,
					finishedComputation);
end architecture;