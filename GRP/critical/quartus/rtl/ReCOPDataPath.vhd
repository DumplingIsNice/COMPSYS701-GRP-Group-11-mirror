library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;
use work.ReCOPTypes.all;
use work.ReCOPConstants.all;

entity ReCOPDataPath is
    port (
        clk     : in std_logic;
        rst     : in std_logic;
        
        -- control

        -- program counter
        wr_PC               : in std_logic;
        PC_mux_select       : in std_logic_vector(1 downto 0);

        -- instruction register
        wr_IR               : in std_logic;

        -- stack pointer
        wr_SP               : in std_logic;
        SP_mux_select       : in std_logic_vector(1 downto 0);
        push_not_pull       : in std_logic;

        -- address register
        wr_AR               : in std_logic;
        AR_mux_select       : in std_logic_vector(1 downto 0)
    );
end entity ReCOPDataPath;


architecture rtl of ReCOPDataPath is
    

    -- Program Counter --
    component ReCOPProgramCounter is
        generic (
            PC_init         : recop_mem_addr
        );
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            -- control
            wr_PC           : in std_logic;
            mux_select      : in std_logic_vector(1 downto 0);
    
            -- inputs
            DM_OUT          : in recop_mem_addr;
            Ry              : in recop_reg;
            operand         : in recop_mem_addr;
            -- outputs
            PM_ADR          : out recop_mem_addr
        );
    end component ReCOPProgramCounter;
    
    signal PM_ADR          : recop_mem_addr;


    -- Internal Program Memory --
    -- INSERT HERE


    -- Instruction Register --
    component ReCOPInstructionRegister is
        generic (
            IR_init     : recop_instruction
        );
        port (
            clk         : in std_logic;
            rst         : in std_logic;
            -- control
            wr_IR       : in std_logic;
    
            -- inputs
            PM_OUT      : in recop_instruction;
            -- outputs
            IR_AM       : out std_logic_vector(1 downto 0);
            IR_Opcode   : out std_logic_vector(5 downto 0);
            IR_Rz       : out std_logic_vector(3 downto 0);
            IR_Rx       : out std_logic_vector(3 downto 0);
            IR_Operand  : out std_logic_vector(15 downto 0)
        );
    end component ReCOPInstructionRegister;

    signal IR_AM       : std_logic_vector(1 downto 0);
    signal IR_Opcode   : std_logic_vector(5 downto 0);
    signal IR_Rz       : std_logic_vector(3 downto 0);
    signal IR_Rx       : std_logic_vector(3 downto 0);
    signal IR_Operand  : std_logic_vector(15 downto 0);


    -- Register File --
    -- INSERT HERE


    -- ALU --
    -- INSERT HERE


    -- Stack Pointer --
    component ReCOPStackPointer is
        generic (
            SP_init         : recop_mem_addr
        );
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            -- control
            wr_SP           : in std_logic;
            mux_select      : in std_logic_vector(1 downto 0);
            push_not_pull   : in std_logic;
    
            -- inputs
            DM_OUT          : in recop_mem_addr;
            operand         : in recop_mem_addr;
            -- outputs
            SP              : out recop_mem_addr;
            SP_incremented  : out recop_mem_addr
        );
    end component ReCOPStackPointer;

    signal SP              : recop_mem_addr;
    signal SP_incremented  : recop_mem_addr;


    -- Address Register --
    component ReCOPAddressRegister is
        generic (
            AR_init             : in recop_mem_addr
        );
        port (
            clk                 : in std_logic;
            rst                 : in std_logic;
            -- control
            wr_AR               : in std_logic;
            mux_select          : in std_logic_vector(1 downto 0);
    
            -- inputs
            Ry                  : in recop_reg;
            SP_incremented      : in recop_mem_addr;
            SP                  : in recop_mem_addr;
            operand             : in recop_reg;
            -- outputs
            DM_ADR              : out recop_mem_addr
        );
    end component ReCOPAddressRegister;

    signal DM_ADR              : recop_mem_addr;


    -- Internal Data Memory --
    -- INSERT HERE

begin

    ProgramCounter: ReCOPProgramCounter
        generic map (
            PC_init => PC_BASE
        )
        port map (
            clk => clk,
            rst => rst,

            wr_PC => wr_PC,
            mux_select => PC_mux_select,

            DM_OUT => DM_OUT,
            Ry => Ry,
            operand => IR_Operand,

            PM_ADR => PM_ADR
        );

    -- InternalProgramMemory: ReCOPInternalProgramMemory
    --     port map ();

    InstructionRegister: ReCOPInstructionRegister
        generic map (
            IR_init => IR_INITIAL
        )
        port map (
            clk => clk,
            rst => rst,
            -- control
            wr_IR => wr_IR,

            -- inputs
            PM_OUT => PM_OUT,
            -- outputs
            IR_AM => IR_AM,
            IR_Opcode => IR_Opcode,
            IR_Rz => IR_Rz,
            IR_Rx => IR_Rx,
            IR_Operand => IR_Operand
        );

    -- RegisterFile: ReCOPRegisterFile
    

    StackPointer: ReCOPStackPointer
        generic map (
            SP_init => SP_BASE
        )
        port map (
            clk => clk,
            rst => rst,

            wr_SP => wr_SP,
            mux_select => SP_mux_select,
            push_not_pull => push_not_pull,

            DM_OUT => DM_OUT,
            operand => IR_Operand,

            SP => SP,
            SP_incremented => SP_incremented
        );
    
    
    AddressRegister: ReCOPAddressRegister
        generic map (
            AR_init => AR_init
        )
        port map (
            clk => clk,
            rst => rst,
            -- control
            wr_AR => wr_AR,
            mux_select => AR_mux_select,
            -- inputs
            Ry => Ry,
            SP_incremented => SP_incremented,
            SP => SP,
            operand => IR_Operand,
            -- outputs
            DM_ADR => DM_ADR
        );

    
end architecture rtl;