library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.CommonTypes.all;
use work.DP_C_Helper.all;
use work.TdmaMinTypes.all;

entity DP_C_tb is
end DP_C_tb;

architecture tb of DP_C_tb is
-------------------------------------------------
-- Simulatiion Constants
-------------------------------------------------
    constant ports               : positive  := 8;
    constant clk_period          : Time      := 20 ns;

    -- TDMA-MIN NoC
    -------------------------------------------------
    signal send_port : tdma_min_ports(0 to ports-1);
	signal recv_port : tdma_min_ports(0 to ports-1);

    signal current_data : tdma_min_data := (others => '0');

    -- Intermediate Signals
    -------------------------------------------------    
    signal clk, reset      : std_logic := '0';

-------------------------------------------------
-- Testing Data Constants
-------------------------------------------------

    constant noc_data_array_length: integer := 4;
    type noc_data_array is array (0 to noc_data_array_length-1) of tdma_min_data;

    -- Used to Test TDMA-MIN Behaviour
    -- constant NOC_DATA:      noc_data_array  := (construct_config_msg_1st(1, 1, 1, 1, 0, 0, 1, 32, 32, 3, 3),
    --                                             "10000000000000000000000000000001",
    --                                             "10000000000000000000000000000010",
    --                                             "10000000000000000000000000000100",
    --                                             "10000000000000000000000000001000",
    --                                             "10000000000000000000000000010000",
    --                                             "10000000000000000000000000100000",
    --                                             "10000000000000000000000001000000",
    --                                             "10000000000000000000000010000000",
    --                                             "10000000000000000000000100000000"
    --                                             );
    constant NOC_DATA:      noc_data_array  := (
        construct_DP_C_config_msg_init(1, 1, 1, 1, 1, 0, 1, 0, 0, 3, 3),
        construct_DP_C_config_msg_w(1, 0, 0, int_to_matrix_elem_8(1), int_to_matrix_elem_8(3), int_to_matrix_elem_8(2)),
        construct_DP_C_config_msg_w(1, 0, 1, int_to_matrix_elem_8(2), int_to_matrix_elem_8(1), int_to_matrix_elem_8(3)),
        construct_DP_C_config_msg_w(1, 0, 2, int_to_matrix_elem_8(3), int_to_matrix_elem_8(2), int_to_matrix_elem_8(1))
                                                );
    constant NOC_ADDR:  tdma_min_addr := std_logic_vector(to_unsigned(6, tdma_min_addr'length));

signal send_config, send_img : boolean := false;
-------------------------------------------------
-- DP-C Debug Ports, Intermediate Signals
-------------------------------------------------  
signal ext_mem_rd      : std_logic := '0';
signal ext_mem_in      : true_rec_data_row := (others => (others => '0'));
signal ext_mem_wt      : std_logic := '0';
signal ext_mem_out     : true_rec_data_row := (others => (others => '0'));

signal krnl_ld_o       : std_logic := '0';
signal conv_done       : std_logic := '0';
signal img_done        : std_logic := '0';

-- Validation Data (from TB-ASP) 
-------------------------------------------------
-- signal i_krnl           :krnl_mem     := (others => (others => int_to_matrix_elem_8(0)));
signal i_img            :true_rec_data_mem      := (others => (others => int_to_matrix_elem_32(-1)));
-- signal conv_img         :true_rec_data_mem      := (others => (others => int_to_matrix_elem_32(-1)));

begin

    send_config <= true, false after 160 ns;
    send_img    <= true when krnl_ld_o = '1' else false;

    reset       <= '1', '0' after 10 ns, '1' after 12000 ns, '0' after 12010 ns;
    clk         <= not clk after clk_period/2;

    conf_gen: process(clk, send_config)
        variable cnt : integer := 0;
        variable done   : boolean := false;
    begin
        if (rising_edge(clk)) then 
            if (rising_edge(clk)) then  
                if (done = false) then
                    send_port(0).addr <= NOC_ADDR;
                    send_port(0).data <= NOC_DATA(cnt);
                    cnt := cnt + 1;
                    if (cnt > noc_data_array_length-1) then
                        cnt := 0;
                        done := true;
                    end if;
                else 
                    send_port(0).addr <= "00000001";
                end if;
            end if;
        end if;    
    end process;

    -- image generated in img_gen process is partioned onto ext_data_port, simulating the scratchpad memory
    img_gen: process(clk, send_img) is
        variable cnt, delay_cnt    : integer := 0;
    begin
        if (rising_edge(clk)) then
            if (send_img = true) then
                if (ext_mem_wt = '1') then
                    ext_mem_in <= i_img(cnt);
                    ext_mem_rd <= '1';

                    if (cnt > true_rec_data_h-2) then
                        cnt := 0;
                    else
                        cnt := cnt + 1;
                    end if;
                end if;
            else
                ext_mem_rd <= '0';
            end if;
        end if;
    end process;

    init_mem: process(reset)
    begin
        for i in 0 to true_rec_data_w-1 loop
            for j in 0 to true_rec_data_h-1 loop
                i_img(i)(j) <= int_to_matrix_elem_32(i+1);
            end loop;
        end loop;
    end process;
    
    tdma_min : entity work.TdmaMin
	generic map (
		ports => ports
	)
	port map (
		clock => clk,
		sends => send_port,
		recvs => recv_port
	);

    DP_C : entity work.DP_C
	port map (
		clk             => clk,
        reset           => reset,
        noc_recv        => recv_port(6),
        noc_send        => send_port(6),

        ext_mem_rd      => ext_mem_rd,
        ext_mem_in      => ext_mem_in,
        ext_mem_wt      => ext_mem_wt,
        ext_mem_out     => ext_mem_out,

        krnl_ld_o     => krnl_ld_o
	);

end tb;