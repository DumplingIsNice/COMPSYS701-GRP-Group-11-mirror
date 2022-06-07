library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type_package.all;

entity Pooling_Datapath is
	generic(
				dataInLength : integer;
				dataInWidth : integer;
				strideLength : integer;
				strideWidth : integer
		);
		port(clock : in std_logic;
				enable : in std_logic;
				dataIn : in data_array_16(dataInLength * dataInWidth - 1 downto 0);
				dataOut : out data_array_16(dataInLength*dataInWidth/(strideLength*strideWidth) - 1 downto 0);
				poolingFunction : in std_logic_vector(1 downto 0);
				finishedComputation : out std_logic 
		);
		
end entity;

architecture behaviour of Pooling_Datapath is

	constant dataOutWidth : integer := dataInWidth/strideWidth;
	begin
	
	process (clock, dataIn)
	 variable currentInIndex, currentOutIndex, currentInLength, currentInWidth, currentOutWidth, currentOutLength, currentOut, medianPoolingCounter : integer := 0;
	 variable medianPoolingList : data_array_16(0 to strideLength * strideWidth - 1);
	 variable maxLength, maxWidth : std_logic := '0';
	 variable tempMedian : std_logic_vector(15 downto 0);
	 begin
		if(rising_edge(clock)) then
			if(enable = '1') then
				currentInIndex := currentInLength * dataInWidth + currentInWidth;
				currentOutIndex := currentOutLength * dataOutWidth + currentOutWidth;
				
				--Do Max Pooling
				currentOut := to_integer(signed(dataIn(currentInIndex)));
				maxPoolingLengthLoop : for i in 0 to strideLength -1 loop
					maxPoolingWidthLoop : for j in 0 to strideWidth - 1 loop
						case poolingFunction is
							when "00" =>
								--Do Max Pooling
								if(to_integer(signed(dataIn(currentInIndex + i * dataInWidth + j))) > currentOut) then
									currentOut := to_integer(signed(dataIn(currentInIndex + i * dataInWidth + j)));
								end if;
							when "01" =>
								--Do Avg Pooling
								currentOut := (currentOut + to_integer(signed(dataIn(currentInIndex + i * dataInWidth + j))))/2;
							when "10" =>
								--Do Min Pooling
								if(to_integer(signed(dataIn(currentInIndex + i * dataInWidth + j))) < currentOut) then
									currentOut := to_integer(signed(dataIn(currentInIndex + i * dataInWidth + j)));
								end if;
							when "11" =>
								--Do Median Pooling
								medianPoolingList(medianPoolingCounter) := dataIn(currentInIndex + i * dataInWidth + j);
								medianPoolingCounter := medianPoolingCounter + 1;
							when others => 
								null;
						end case;
					end loop;
				end loop;
				--Sort Median. Could use better algorithm than bubble sort if data size increases but hard to implement in hardware.
				if(poolingFunction = "11") then
					outerSortingLoop : for i in 0 to strideLength * strideWidth - 1 loop
						innerSortingLoop : for j in 0 to strideLength * strideWidth - i - 2 loop
							if(medianPoolingList(j) > medianPoolingList(j + 1)) then
								tempMedian := medianPoolingList(j);
								medianPoolingList(j) := medianPoolingList(j+1);
								medianPoolingList(j+1) := tempMedian;
							end if;
						end loop;
					end loop;
					--Get middle (median) value from sorted list
					currentOut := to_integer(signed(medianPoolingList((strideLength * strideWidth - 1)/2)));
				end if;
				--Write Output
				dataOut(currentOutIndex) <= std_logic_vector(to_signed(currentOut, 16));
				
				--Set next index
				adjustMaxPoolingIndexWidth : for i in 1 to strideWidth loop
					if(currentInWidth + strideWidth + i > dataInWidth - 1) then
						if(i = 1) then
							currentInWidth := 0;
							currentOutWidth := 0;
							maxWidth := '1';
						else
							currentInWidth := currentInWidth + i - 1;
							currentOutWidth := currentOutWidth + 1;
							maxWidth := '0';
						end if;
					end if;
				end loop;
						
				adjustMaxPoolingIndexLength : for i in 1 to strideLength loop
					if(currentInLength + strideLength + i > dataInLength - 1 and maxWidth = '1') then
						if(i = 1) then
							currentInLength := 0;
							currentOutLength := 0;
							maxLength := '1';
							finishedComputation <= '1';
						else
							currentInLength := currentInLength + i - 1;
							currentOutLength := currentOutLength + 1;
							maxLength := '0';
						end if;
					end if;
				end loop;	
			end if;
		end if;
	 end process;
end architecture;
				