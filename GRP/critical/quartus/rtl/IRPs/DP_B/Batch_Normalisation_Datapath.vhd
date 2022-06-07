library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type_package.all;

--Normalise by subtracting the mean and dividing by std. deviation for each neuron

entity Batch_Normalisation_Datapath is
	generic (numNeurons : integer := 32);
	port(clock : in std_logic;
			batchSize : in std_logic_vector(7 downto 0);
			enable : in std_logic;
			read_data : in std_logic;
			dataIn : in data_array_16(numNeurons - 1 downto 0);
			dataOut : out data_array_16(numNeurons - 1 downto 0);
			dataReady : out std_logic
	);
end entity Batch_Normalisation_Datapath;

architecture beh of Batch_Normalisation_Datapath is
	type data_array_2D_16 is array(numNeurons - 1 downto 0, to_integer(unsigned(batchSize)) - 1 downto 0) of std_logic_vector(15 downto 0);
	signal stored_neurons : data_array_2D_16;
	
	begin
	
	--Dont use loop as will use many LEs
	
	process (clock)
	variable currentSampleNum : integer := 0;
	variable batchMean, batchStdDev, batchStdDevSqrt : data_array_16(numNeurons - 1 downto 0);
	--variable batchStdDevSqrt : integer;
	begin
		if(rising_edge(clock)) then
			if(enable = '1' and read_data = '1') then
				for i in numNeurons downto 0 loop
					stored_neurons(i, currentSampleNum) <= dataIn(i);
				end loop;
			end if;
			else if(enable = '1' and read_data = '0') then
				for i in numNeurons - 1 downto 0 loop
				
					batchMean(i) := stored_neurons(0,0);
					for j in to_integer(unsigned(batchSize)) - 1 downto 1 loop
						batchMean(i) := std_logic_vector(to_signed(to_integer(signed(batchMean(i))) + to_integer(signed(stored_neurons(i, j))),16));
					end loop;
					batchMean(i) := std_logic_vector(to_signed(to_integer(signed(batchMean(i))) / to_integer(signed(batchSize)),16));
				end loop;
				for i in numNeurons - 1 downto 0 loop
					for j in to_integer(unsigned(batchSize)) - 1 downto 0 loop
						batchStdDev(i) := std_logic_vector(to_signed(to_integer(signed(batchStdDev(i))) + to_integer(signed(shift_left(to_signed(to_integer(signed(stored_neurons(i, j))) - to_integer(signed(batchMean(i))),16),1))),16));
					end loop;
					batchStdDev(i) := std_logic_vector(to_signed(to_integer(signed(batchStdDev(i))) / to_integer(signed(batchSize)), 16));
				end loop;
				for i in numNeurons downto 0 loop
					for j in 0 to 32768 loop --16 bit values, maximum sqrt has to be 2^16/2
						if(to_integer(signed(batchStdDev(i))) / j = j) then
							batchStdDevSqrt(i) := std_logic_vector(to_signed(j,16));
						end if;
					end loop;
					dataOut(i) <= std_logic_vector(to_signed(100 * (to_integer(signed(dataIn(i))) - to_integer(signed(batchMean(i))))/to_integer(signed(batchStdDevSqrt(i))),16)); --multiplied by 100 for fixed point calculations
				end loop;
			end if;
		end if;
	end process;
end architecture; 
			