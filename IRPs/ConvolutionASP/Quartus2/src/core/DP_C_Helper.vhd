library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;

library work;
use work.CommonTypes.all;
use work.TdmaMinTypes.all;

package DP_C_Helper IS

    constant  RECOP_RECV_ADDR_ID   : tdma_min_addr := "00000000";
    
    function construct_DP_C_config_msg_init(
        stride_i, a_func_i                      : in integer;
        target_i                                : in integer;
        en_i, listen_i, mode_i, pad_i           : in integer;
        img_h_i, img_w_i, krnl_h_i, krnl_w_i    : in integer) 
    return tdma_min_data;

    function construct_DP_C_config_msg_w(
        wi, ie                                  : in integer;
        cnt                                     : in integer;
        data0, data1, data2                     : in matrix_elem_8
        ) 
    return tdma_min_data;

end package;
package body DP_C_Helper IS
    function construct_DP_C_config_msg_init(
        stride_i, a_func_i                      : in integer;
        target_i                                : in integer;
        en_i, listen_i, mode_i, pad_i           : in integer;
        img_h_i, img_w_i, krnl_h_i, krnl_w_i    : in integer) 
    return tdma_min_data is 
        variable msg : tdma_min_data;

        variable var_stride, var_a_func                              : std_logic_vector(1 downto 0);
        variable var_target                                          : std_logic_vector(3 downto 0);
        variable var_en, var_listen, var_mode, var_pad               : std_logic;
        variable var_img_h, var_img_w, var_krnl_h, var_krnl_w        : std_logic_vector(1 downto 0);
    begin

        var_stride      := std_logic_vector(to_unsigned(stride_i, var_stride'length));
        var_a_func      := std_logic_vector(to_unsigned(a_func_i, var_a_func'length));
        var_target      := std_logic_vector(to_unsigned(target_i, var_target'length));
        if (en_i = 0)       then var_en := '0'; else var_en := '1'; end if;
        if (listen_i = 0)   then var_listen := '0'; else var_listen := '1'; end if;
        if (mode_i = 0)     then var_mode := '0'; else var_mode := '1'; end if;
        if (pad_i = 0)      then var_pad := '0'; else var_pad := '1'; end if;
        var_img_h       := std_logic_vector(to_unsigned(img_h_i, var_img_h'length));
        var_img_w       := std_logic_vector(to_unsigned(img_w_i, var_img_w'length));
        var_krnl_h      := std_logic_vector(to_unsigned(krnl_h_i, var_krnl_h'length));
        var_krnl_w      := std_logic_vector(to_unsigned(krnl_w_i, var_krnl_w'length));

        msg := DP_C_RECV_DATA_ID & var_stride & var_a_func & var_target 
        & var_en & var_listen & var_mode & var_pad
        & var_img_h & var_img_w & var_krnl_h & var_krnl_w & "00000000";

        return msg; 
    end;

    function construct_DP_C_config_msg_w(
        wi, ie                                  : in integer;
        cnt                                     : in integer;
        data0, data1, data2                     : in matrix_elem_8
        ) 
    return tdma_min_data is 
        variable msg : tdma_min_data;

        variable var_wi, var_ie                              : std_logic;
        variable var_cnt                                     : std_logic_vector(1 downto 0);
    begin
        var_cnt      := std_logic_vector(to_unsigned(cnt, var_cnt'length));
        if (wi = 0)   then var_wi := '0'; else var_wi := '1'; end if;
        if (ie = 0)   then var_ie := '0'; else var_ie := '1'; end if;

        msg := DP_C_RECV_DATA_ID & var_wi & var_ie & var_cnt 
                & data0 & data1 & data2;
        return msg; 
    end;
end package body DP_C_Helper;