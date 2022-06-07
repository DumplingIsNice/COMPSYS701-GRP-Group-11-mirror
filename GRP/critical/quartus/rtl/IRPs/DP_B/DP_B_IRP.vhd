library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type_package.all;

entity DP_B_IRP is
	generic(dataInLength : integer;
				--parallelDPs : integer := 1; -- No longer used as takes up too many LEs
				dataInWidth :integer;
				strideLength : integer;
				strideWidth : integer;
				id : integer
				);
	port(clock : in std_logic;
			bufferDataIn : in data_array_16(dataInLength * dataInWidth - 1 downto 0);
			dataInReady : in std_logic;
			controlPacketIn : in std_logic_vector(31 downto 0);
			bufferDataOut : out data_array_16(dataInLength*dataInWidth/(strideLength*strideWidth) - 1 downto 0);
			finishedComputation : out std_logic
			);
			
end entity;

architecture behaviour of DP_B_IRP is
	signal poolingFunction, poolingArchitecture : std_logic_vector(1 downto 0); 
	signal start, data_rq : std_logic;
	signal dataIn : data_array_16(dataInLength * dataInWidth - 1 downto 0);
	component Pooling_Datapath is
		generic(
				dataInLength : integer := 32;
				dataInWidth : integer := 32;
				strideLength : integer := 2;
				strideWidth : integer := 2
		);
		port(clock : in std_logic;
				enable : in std_logic;
				dataIn : in data_array_16(dataInLength * dataInWidth - 1 downto 0);
				dataOut : out data_array_16(dataInLength*dataInWidth/(strideLength*strideWidth) - 1 downto 0);
				poolingFunction : in std_logic_vector(1 downto 0);
				finishedComputation : out std_logic 
		);
	end component;
	begin
	
	--Load data in when ready
	
	
	--Control Unit
	control_unit : process (clock, controlPacketIn)
		begin
			if(rising_edge(clock)) then
				if(dataInReady = '1') then
					dataIn <= bufferDataIn;
				end if;
				if((controlPacketIn(31) = '1') and (controlPacketIn(30 downto 28) = std_logic_vector(to_unsigned(id,3)))) then
					poolingFunction <= controlPacketIn(1 downto 0);
					poolingArchitecture <= controlPacketIn(3 downto 2);
					start <= controlPacketIn(15);
					data_rq <= controlPacketIn(14);
				end if;
			end if;	
	end process;
	
	--Datapath
	
	--datapaths : for pooling_datapath_units in 0 to strideLength - 1 generate
		DP : Pooling_Datapath 
				
			generic map(
					dataInLength => dataInLength,
					dataInWidth => dataInWidth,
					strideLength => strideLength,
					strideWidth => strideWidth			
			)
			port map(clock => clock,
					enable => start,
					dataIn => dataIn,
					dataOut => bufferDataOut,
					poolingFunction => poolingFunction,
					finishedComputation => finishedComputation
			);
	--end generate

end architecture behaviour;