library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.CommonTypes.all;
use work.TdmaMinTypes.all;

entity DP_C_tb is
end DP_C_tb;

architecture tb of DP_C_tb is
-------------------------------------------------
-- Simulatiion Constants
-------------------------------------------------
    constant ports               : positive  := 2;
    constant clk_period          : Time      := 20 ns;

    -- TDMA-MIN NoC
    -------------------------------------------------
    signal send_port : tdma_min_ports(0 to ports-1);
	signal recv_port : tdma_min_ports(0 to ports-1);

    signal current_data : tdma_min_data := (others => '0');

    constant noc_data_array_length: integer := 2;

    type noc_data_array is array (0 to noc_data_array_length-1) of tdma_min_data;
    constant noc_data:      noc_data_array  := ("10000000000000000000000000000000",
                                                "00000000000000000000000000000011"
                                                );

-------------------------------------------------
-- Simulation Data (from TB-ASP) 
------------------------------------------------- 
    constant img_w               : integer  := 32;  -- Image width
    constant img_h               : integer  := 32;  -- Image height 
    constant krnl_w              : integer  := 3;  -- kernel width
    constant krnl_h              : integer  := 3;  -- kernel height

    -- type int_index is array (0 to 4) of std_logic_vector(7 downto 0);
    -- subtype stream_data is std_logic_vector(23 downto 0);
    -- subtype matrix_elem is integer;
    -- type img_row  is array (0 to img_w-1)   of matrix_elem;
    -- type img_mem  is array (0 to img_h-1)   of img_row;
    -- type krnl_row  is array (0 to krnl_w-1) of matrix_elem;
    -- type krnl_mem is array (0 to krnl_h-1)  of krnl_row;

    -- Intialise empty memory
    signal i_krnl   :       krnl_mem     := (others => (others => int_to_matrix_elem_8(0)));
    signal i_img    :       img_mem      := (others => (others => int_to_matrix_elem_32(0)));
    signal o_img    :       img_mem      := (others => (others => int_to_matrix_elem_32(0)));

-------------------------------------------------
-- DP-C Debug Ports, Intermediate Signals
-------------------------------------------------  
signal img_loaded   : Boolean  := false;
-- img_buf
signal krnl_loaded  : Boolean  := false;
-- krnl_buf
signal conv_done    : Boolean  := false;
signal conv_img     : img_mem  := (others => (others => int_to_matrix_elem_32(0)));

-------------------------------------------------
-- Intermediate Signals
-------------------------------------------------    
    signal clk      : std_logic := '0';
    signal reset    : Boolean   := false;

-------------------------------------------------
-- Psudo-random No. generator
-- 
-- By: Cheikh A.
-- Retrived from: https://github.com/klessydra/ConvE (Accessed 16/05/2022)
--
-- Modified by: Hao Lin
--     For the purpose of IRP research at UoA for course COMPSYS701
-------------------------------------------------    
-- use IEEE.MATH_REAL.ALL;

-- impure function rand_int(min_val, max_val : integer) return matrix_elem is
--    variable seed1, seed2 : integer := 999;
--    variable r : real;
-- begin
--    uniform(seed1, seed2, r);
--    return matrix_elem(round(r * real(max_val - min_val + 1) + real(min_val) - 0.5));
-- end function;

begin

    conv_done   <= true;
    reset       <= true after 100 ns, false after 120 ns;
    clk         <= not clk after clk_period/2;

    conf_gen: process(clk, conv_done)
        variable cnt : integer := 0;
        variable conf_ms : noc_data_array := noc_data;
    begin
        if (conv_done = true) then
            send_port(1).data <= conf_ms(cnt);
            cnt := cnt + 1;
            if (cnt > noc_data_array_length-1) then
                cnt := 0;
            end if;
        end if;       
    end process;
    
    img_gen: process(clk, reset, img_loaded)
        variable rand, x, y,  x0, x1, x2, y0, y1, y2, look_ahead  : integer                      := 0;
        variable img_sent, res             : Boolean                   := false;
        variable img_x_cnt, img_y_cnt      : integer       := 0;
        variable d0,d1,d2,d3    : stream_data               := (others =>'0');
        variable data : tdma_min_data := (others =>'0');
    begin
        if (reset = true) then
            res := true;
        end if;
        if (rising_edge(clk)) then
            if (res = true) then
                i_img(y)(x) <= int_to_matrix_elem_32(1); -- rand+1;
                -- rand := rand+1;
                x := x+1;
                if (x > img_w-1) then
                    x := 0;
                    y := y+1;
                    if (y > img_h-1) then
                        res := false;
                        img_sent := false;
                    end if;
                end if;
            else 
                -- image generated in img_gen process is partioned onto TDMA-MIN messages
                -- if (img_sent = false) then

                --     d0 := std_logic_vector(to_unsigned(i_img(img_x_cnt)(img_y_cnt), d0'length));

                --     look_ahead := img_w-img_x_cnt;
                --     case look_ahead is
                --     when 3 =>
                --         img_x_cnt := 0;
                --         img_y_cnt := img_y_cnt+1;
                --     when 2 =>
                --         img_x_cnt := 1;
                --         img_y_cnt := img_y_cnt+1;
                --         x1 := img_x_cnt-1;
                --         y1 := img_y_cnt;
                --     when 1 =>
                --         img_x_cnt := 2;
                --         img_y_cnt := img_y_cnt+1;

                --         x1 := img_x_cnt-2;
                --         y1 := img_y_cnt;
                --         x2 := img_x_cnt-1;
                --         y2 := img_y_cnt;
                --     when others =>
                --         x1 := img_x_cnt+1;
                --         y1 := img_y_cnt;
                --         x2 := img_x_cnt+2;
                --         y2 := img_y_cnt;

                --         img_x_cnt := img_x_cnt+3;
                --     end case;

                --     d1 := std_logic_vector(to_unsigned(i_img(y1)(x1), d1'length));
                --     d2 := std_logic_vector(to_unsigned(i_img(y2)(x2), d2'length));

                --     data := "1110" & "0000" & d0(7 downto 0) & d1(7 downto 0) & d2(7 downto 0);
                    
                --     if (img_y_cnt > img_h-1) then
                --         img_sent := true;
                --     end if;
                -- else
                --     data := (others => '0');
                -- end if;

            end if;
        end if;

        current_data <= data;
    end process;

    -- -- image generated in img_gen process is partioned onto TDMA-MIN messages
    -- data_gen: process(clk, img_loaded)

    -- begin
  
    -- end process;

    -- -- Mock TB-ASP as a process
    -- TB_ASP: process(clk, reset)
    -- begin
    --     if reset then
    --         if rising_edge(clk) then
                
    --         end if;  
    --     end if;      
    -- end process;

    
    tdma_min : entity work.TdmaMin
	generic map (
		ports => ports
	)
	port map (
		clock => clk,
		sends => send_port,
		recvs => recv_port
	);

end tb;