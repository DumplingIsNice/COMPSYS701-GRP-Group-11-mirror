library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.CommonTypes.all;
use work.DP_C_Helper.all;
use work.TdmaMinTypes.all;

entity DP_C is
    port(
        clk             : in  std_logic;
        reset           : in  std_logic;
        noc_recv        : in  tdma_min_port;
        noc_send        : out tdma_min_port;

        ext_mem_rd      : in   std_logic;
        ext_mem_in      : in   true_rec_data_row;
        ext_mem_wt      : out  std_logic;
        ext_mem_out     : out  true_rec_data_row;

        krnl_ld_o       : out  std_logic
        );
end DP_C;

architecture RTL of DP_C is
-------------------------------------------------
-- Primary Control Signals
-------------------------------------------------
    signal processor_configured : boolean := false;

    signal krnl_ld, img_ld          : std_logic := '0';

    -- Primary Control
    -------------------------------------------------
    type state_type is (S0, S1);
    -- S0 = normal operation (intial current_state with default parameters)
        -- Check for noc_recv config
        -- Loads current img from ext_mem_in port  
        -- Writes out current conv_data to ext_mem_out port + assert ext_mem_wt
    -- S1 = expecting weight config infomation
    -- S2 = custom-call (to be implemented for GRP)
    signal current_state   : state_type := S0;
    signal op_state        : state_type := S0;

-------------------------------------------------
-- Data Processing & Decode
-------------------------------------------------

    -- Config info control signals
    -------------------------------------------------
    signal en, CE_clk, CE_enable, conv_done, listen, mode  : std_logic := '0';
    signal a_func                        : std_logic_vector(1 downto 0) := (others => '0');
    signal noc_send_addr                 : tdma_min_addr := (others => '0');

    -- Kernel data processing intermediate signals
    -------------------------------------------------
    signal krnl_data                : krnl_mem := (others => (others => (others => '0')));

    -- Image data processing intermediate signals
    -------------------------------------------------
    constant IMG_DATA_ZEROS         : img_row := (others => (others => '0'));
    signal img_data, img_data_to_CE : img_row := (others => (others => '0'));
    signal row_cnt                  : integer := 32;

    constant INTER_IMAGE_DELAY      : integer := 2;

    -- In and out img data intermediate signals
     -------------------------------------------------
    signal conv_data    : true_rec_data_row := (others => (others => '0'));
    signal conv_wt      : std_logic := '0';

    signal krnl_rdy, pad    : boolean := false;
    signal krnl_index : integer := 0;
begin
    pad <= true; -- fixed for now, no reasonable case where pad is not going to be used with the HMPSoC

-------------------------------------------------
-- Control & Decode
-------------------------------------------------
    noc_send.addr <= noc_send_addr;
    noc_send.data <= (others => '0');

    state: process(clk, reset) is
    begin
        if (reset = '1') then
            current_state <= S0;
        elsif (rising_edge(clk)) then
            case (current_state) is
            when S0 =>
                if (listen = '1') then
                    current_state <= S1;
                end if;
            when S1 =>
                if (krnl_rdy = true) then
                    current_state <= S0;
                end if;
            end case;
        end if;
    end process;

    control_and_decode: process (clk, noc_recv) is
        variable img : img_row := (others => (others => '0'));

        variable var_krnl_rdy : boolean := false;
    begin
        if (rising_edge(clk)) then
            -- Normal operation
            case (current_state) is
                when (S0) =>
                    if (noc_recv.addr = RECOP_RECV_ADDR_ID) then
                        -- NoC message handling & decode
                        if (noc_recv.data(31 downto 28) = DP_C_RECV_DATA_ID) then

                            -- Handle subsequent weight infomation
                            listen <= noc_recv.data(18);

                            -- Handle mode
                            mode <= noc_recv.data(17);

                            -- stride              <= noc_recv.data(27 downto 26);
                            a_func              <= noc_recv.data(25 downto 24);
                            noc_send_addr       <= "0000" & noc_recv.data(23 downto 20);
                            en                  <= noc_recv.data(19);
                            -- pad                 <= noc_recv.data(16);
                            -- img_h               <= noc_recv.data(15 downto 14);
                            -- img_w               <= noc_recv.data(13 downto 12);
                            -- krnl_h              <= noc_recv.data(11 downto 10);
                            -- krnl_w              <= noc_recv.data(9 downto 8);
                            -- temp_krnl_data      <= noc_recv.data(7 downto 0);
                        end if;
                    end if;
                -- Receiving weights only
                when (S1) =>
                    listen <= '0';
                    -- if (noc_recv.addr = RECOP_RECV_ADDR_ID) then
                    --     if (noc_recv.data(31 downto 28) = DP_C_RECV_DATA_ID) then
                    --         if (noc_recv.data(27) = '1') then
                    --             krnl_index <= to_integer(unsigned((noc_recv.data(25 downto 24))));
                    --         end if;
                    --     end if;
                    -- end if;
                end case;
        end if;
    end process control_and_decode;

    krnl_index <= to_integer(unsigned((noc_recv.data(25 downto 24)))) when
                                noc_recv.addr = RECOP_RECV_ADDR_ID 
                                and noc_recv.data(31 downto 28) = DP_C_RECV_DATA_ID 
                                and noc_recv.data(27) = '1'
                            else
                                krnl_index;

    krnl_loading: process(clk, reset, krnl_index, noc_recv) is
    begin
        if (reset = '1') then
            krnl_data <= (others => (others => (others => '0')));
        elsif (rising_edge(clk)) then
            if (current_state = S1) then
                if (noc_recv.addr = RECOP_RECV_ADDR_ID) then
                    if (noc_recv.data(31 downto 28) = DP_C_RECV_DATA_ID) then
                            krnl_data(krnl_index)(0)	<= noc_recv.data(23 downto 16);
                            krnl_data(krnl_index)(1)	<= noc_recv.data(15 downto 8);
                            krnl_data(krnl_index)(2)	<= noc_recv.data(7 downto 0);
                    end if;
                end if;
            end if;
        end if;
    end process;

    krnl_rdy <= true when krnl_index = krnl_w-1 else false;

-------------------------------------------------
-- Data Processing
-------------------------------------------------

    -- Data Outputing
    -------------------------------------------------
    ext_mem_out <= conv_data when krnl_rdy = true and current_state = S0 else 
                   (others => (others => '0'));
    ext_mem_wt <= conv_wt;
    conv_wt <= conv_done and en when krnl_rdy = true and current_state = S0 else '0';
    
    -- Data Processing
    -------------------------------------------------
    -- Continuious streaming
    img_data_to_CE <= img_data;

    -- Padding rows between data slices, not relevent to HMPSoC.
    -- img_data_to_CE <= IMG_DATA_ZEROS when start_end = true else
    --                   img_data;

    -- Image data wiring read image into middle of vector,
    -- leaving one element padding one each end.
    img_data(0) <= int_to_matrix_elem_32(0);
    img_data(img_w-1) <= int_to_matrix_elem_32(0);

    img_data_wiring_gen: for i in 0 to true_rec_data_w-1 generate
    begin
        img_data(i+1) <= ext_mem_in(i);
    end generate img_data_wiring_gen;

-------------------------------------------------
-- conv_engine clk and loading signals
-------------------------------------------------

    -- Note, krnl-ld is similar to an enable signal
    krnl_ld_o <= krnl_ld;
    krnl_ld   <= '1' when (krnl_rdy = true and current_state = S0) else '0';

    -- -- Note, krnl-ld is similar to an clk signal for the tri_port_mem
    img_ld   <= '1' and conv_done when (krnl_rdy = true and current_state = S0) else '0';

    CE_clk <= clk and en when current_state = S0 else '0';
    CE_enable <= en when (krnl_rdy = true and current_state = S0) else '0';

    conv_engine : entity work.conv_engine
        port map(
            clk         => CE_clk,
            en          => CE_enable,
            krnl_ld     => krnl_ld,
            img_ld      => img_ld,
            krnl_data   => krnl_data,
            conv_done   => conv_done,
            img_data    => img_data_to_CE,
            conv_data   => conv_data
        );
end architecture rtl;