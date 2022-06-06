library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package CommonTypes is
  constant word_size           : integer  := 32;
  constant true_rec_data_w     : integer  := 32;
  constant true_rec_data_h     : integer  := 32;

  constant krnl_w              : integer  := 3;  -- kernel width
  constant krnl_h              : integer  := 3;  -- kernel height
  constant pad_sz_w            : integer  := (krnl_w-1)/2;  -- pad_sz width
  constant pad_sz_h            : integer  := (krnl_h-1)/2;  -- pad_sz height
  constant img_w               : integer  := true_rec_data_w+2*pad_sz_w;  -- Image width
  constant img_h               : integer  := true_rec_data_h+2*pad_sz_h;  -- Image height 

  constant MAX_KERNEL_SIZE     : integer  := krnl_w*krnl_h;

  subtype stream_data is std_logic_vector(23 downto 0);
  subtype matrix_elem_32 is std_logic_vector(word_size-1 downto 0);
  subtype matrix_elem_16 is std_logic_vector(15 downto 0);
  subtype matrix_elem_8 is std_logic_vector(7 downto 0);

  type img_row  is array (0 to img_w-1)   of matrix_elem_32;
  type img_mem  is array (0 to img_h-1)   of img_row;
  type krnl_row  is array (0 to krnl_w-1) of matrix_elem_8;
  type krnl_mem is array (0 to krnl_h-1)  of krnl_row;

  type img_buff  is array (natural range <>) of img_row;

  type true_rec_data_row is array (0 to true_rec_data_w-1) of matrix_elem_32;
  type true_rec_data_mem is array (0 to true_rec_data_h-1) of true_rec_data_row;

  -- Vector representation of kernel and feature slice
  type krnl_weight_vec is array (0 to MAX_KERNEL_SIZE-1) of matrix_elem_8;
  type krnl_word_vec   is array (0 to MAX_KERNEL_SIZE-1) of matrix_elem_32;
  
  function int_to_matrix_elem_32 (
    int : in integer)
  return matrix_elem_32;

  function int_to_matrix_elem_16 (
    int : in integer)
  return matrix_elem_16;

  function int_to_matrix_elem_8 (
    int : in integer)
  return matrix_elem_8;

  constant ZEROS_16 : matrix_elem_16 := "0000000000000000";
  constant ONES_16  : matrix_elem_16 := "1111111111111111";

-------------------------------------------------
-- NoC msg protocol
-------------------------------------------------
  constant  DP_C_RECV_DATA_ID    : std_logic_vector(3 downto 0) := "1110";
end package CommonTypes;
  
-- Package Body Section
package body CommonTypes is

  function int_to_matrix_elem_32 (
    int : in integer)
  return matrix_elem_32 is 
  begin
    return std_logic_vector(to_signed(int, matrix_elem_32'length));
  end;

  function int_to_matrix_elem_16 (
    int : in integer)
  return matrix_elem_16 is 
  begin
    return std_logic_vector(to_signed(int, matrix_elem_16'length));
  end;  

  function int_to_matrix_elem_8 (
    int : in integer)
  return matrix_elem_8 is 
  begin
    return std_logic_vector(to_signed(int, matrix_elem_8'length));
  end;
end package body CommonTypes;