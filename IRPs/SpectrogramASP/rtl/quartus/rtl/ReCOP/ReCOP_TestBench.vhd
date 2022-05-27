library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.ReCOPTypes.all;

entity ReCOP_TestBench is
    port (
        placeholder : out std_logic
    );
end entity ReCOP_TestBench;

architecture test of ReCOP_TestBench is

    component ReCOPStackPointer_TestBench is
        port (
            placeholder     : out std_logic
        );
    end component ReCOPStackPointer_TestBench;

    component ReCOPAddressRegister_TestBench is
        port (
            placeholder     : out std_logic
        );
    end component ReCOPAddressRegister_TestBench;

    component ReCOPInstructionRegister_TestBench is
        port (
            placeholder     : out std_logic
        );
    end component ReCOPInstructionRegister_TestBench;
begin
    
    StackPointerTB: ReCOPStackPointer_TestBench
        port map (
            placeholder => open
        );

    AddressRegisterTB: ReCOPAddressRegister_TestBench
        port map (
            placeholder => open
        );

    InstructionRegisterTB: ReCOPInstructionRegister_TestBench
            port map (
                placeholder => open
            );

    placeholder <= '1';
end architecture test;