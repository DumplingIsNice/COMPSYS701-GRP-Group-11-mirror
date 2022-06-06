library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.data_type_package.all;

library work;
use work.TdmaMinTypes.all;
	
entity DP_D is
	generic( N 		: integer := 32; -- size of overall input vector
				M 		: integer := 8; -- size of output vector 
				row 	: integer := 32 -- size of row (each input chunk)
			);
	port(
			clock 		: in std_logic;
			data_read 	: in std_logic;
			data_write 	: out std_logic;
			data_in 		: in data_array(0 to row-1); -- matrix flattened into a 1D array
			data_out 	: out data_array(0 to M-1)
		);
end entity DP_D;

architecture behaviour of DP_D is 

	signal layer	: std_logic := '1';
	signal input 	: data_array(0 to N); -- 
	signal weight 	: data_array(0 to N*M); 	 
	signal exp		: data_array(0 to M); 
	signal output 	: data_array(0 to M); --
	
	begin 
	
		input_stream : process(clock, data_read)
		begin
			if(rising_edge(clock) and data_read = '1')	then	
				for index in 0 to N/row-1 loop
					input(index*row to index*row+row-1) <= data_in;
				end loop;
			end if;	
		end process input_stream;
				
		dense : process(clock)
		
		variable init_weight : integer := 1;
		variable multi			: integer;
		variable sum			: integer;
		variable dot   : integer;
		variable e_x			: integer;
		variable dot_k			: integer;
		variable softmax 		: integer;
		variable test   : std_logic_vector(15 downto 0);
		
		begin
--			initialises weight matrix values to init_weight			
			for index in 0 to N*M loop
				weight(index) <= std_logic_vector(to_signed(init_weight, 16));
			end loop;
		
--			performs dot product operation on input(N) and weight(N,M)
			for i in 0 to M-1 loop
				for j in 0 to N-1 loop
					multi :=  to_integer(signed(weight(j*M+i))) + to_integer(signed(input(j)));
					dot := dot + multi;
				end loop;
				output(i) <= std_logic_vector(to_signed(dot, 16));
			end loop;

--			activation functions
--			if last layer, then softmax function is selected
			if(layer = '1') then

				for k in 0 to M-1 loop -- calculates the e^x value for every unit in the dot product output vector using an approximation
					dot_k := to_integer(signed(output(k)));
					e_x := 1 + dot_k + ((dot_k **2)/2) + ((dot_k**3)/6) + ((dot_k**4)/24);
					exp(k) <= std_logic_vector(to_signed(e_x, 16));
					sum  := sum + e_x; --sum of all e^x values 
				end loop;
			
				
				for l in 0 to M-1 loop
					softmax := to_integer(signed(exp(l))) / sum;
					output(l) <= std_logic_vector(to_signed(softmax, 16));
				end loop;
				
				
--			if not last layer, then relu is selected
			else 
				for k in 0 to M-1 loop
					if(output(k) <= std_logic_vector(to_signed(0, 16))) then
						output(k) <= std_logic_vector(to_signed(0,16));
					end if;
				end loop;
			end if;
		
		end process dense;
		
		output_stream : process(clock)
		begin
			if(rising_edge(clock))	then
					data_write <= '1';
					data_out(0 to M-1) <= output(0 to M-1);
			end if;
		end process output_stream;
	
end architecture behaviour;
	