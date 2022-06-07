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
        --------------------------------------------------
        -- ALU
        ALU_Control         : in std_logic_vector(1 downto 0);
		z_out               : out std_logic;

        -- ALU_mux_A_select    : in std_logic_vector(1 downto 0);
        ALU_mux_B_select    : in std_logic;

        -- register file
        wren			    : in std_logic;
        rden_x			    : in std_logic;
        rden_z			    : in std_logic;
        RF_in_select        : in std_logic_vector(1 downto 0);

        -- data memory
        we                  : in std_logic;
        DM_mux_select       : in std_logic_vector(1 downto 0);

        -- program counter
        wr_PC               : in std_logic;
        PC_mux_select       : in std_logic_vector(1 downto 0);

        -- instruction register
        wr_IR               : in std_logic;

        -- -- stack pointer
        -- wr_SP               : in std_logic;
        -- SP_mux_select       : in std_logic_vector(1 downto 0);
        -- push_not_pull       : in std_logic;

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
    signal DM_IN           : recop_mem_addr;
    signal DM_OUT          : recop_mem_addr;
    signal Ry              : recop_reg;

    -- Internal Program Memory --
    component ReCOPProgramMemory is
            generic(
                ADDR_WIDTH : natural := 10;
                WORD_WIDTH : natural := 32
            );
            port(
                clk : in std_logic;
                addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
                pm_o : out std_logic_vector(WORD_WIDTH-1 downto 0)
            );
    end component ReCOPProgramMemory;

    signal PM_OUT     : std_logic_vector(PM_DATA_WIDTH-1 downto 0);

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
	COMPONENT ReCOPRegisterFile
		GENERIC ( DATA_WIDTH : INTEGER );
		PORT
		(
			clk				:	 IN STD_LOGIC;
			data				:	 IN STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
			wraddress		:	 IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			rdaddress_x		:	 IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			rdaddress_z		:	 IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			wren				:	 IN STD_LOGIC;
			rden_x			:	 IN STD_LOGIC;
			rden_z			:	 IN STD_LOGIC;
			Rx					:	 OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0);
			Rz					:	 OUT STD_LOGIC_VECTOR(data_width-1 DOWNTO 0)
		);
	END COMPONENT ReCOPRegisterFile;	

    signal rf_data_in, Rx, Rz   : STD_LOGIC_VECTOR(REG_FILE_DATA_WIDTH-1 DOWNTO 0);

    -- ALU --
    component ReCOPALU is
        generic (
            DATA_WIDTH : integer := 16
        );
        port(clock : in std_logic;
            ALU_Control : in std_logic_vector(1 downto 0);
            inputA : in std_logic_vector(DATA_WIDTH-1 downto 0);
            inputB : in std_logic_vector(DATA_WIDTH-1 downto 0);
            ALU_Out : out std_logic_vector(DATA_WIDTH-1 downto 0);
            z_out : out std_logic
            );
    end component ReCOPALU;

    signal inputA   : recop_data;
    signal inputB   : recop_data;
    signal ALU_Out  : recop_data;

    signal ALU_mux_A, ALU_mux_B : recop_data;


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
	component single_port_ram is
		generic 
		(
			DATA_WIDTH : natural;
			ADDR_WIDTH : natural
		);
		port 
		(
			clk		: in std_logic;
			addr		: in natural range 0 to 2**ADDR_WIDTH - 1;
			data		: in std_logic_vector((DATA_WIDTH-1) downto 0);
			we			: in std_logic := '1';
			q			: out std_logic_vector((DATA_WIDTH -1) downto 0)
		);
	end component single_port_ram;

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
    ProgramMemory: ReCOPProgramMemory
        generic map (
            ADDR_WIDTH => PM_ADDR_WIDTH,
            WORD_WIDTH => PM_DATA_WIDTH
        )
        port map (
            clk => clk,
            addr => PM_ADR,
            pm_o => PM_OUT
        );

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
	RegisterFile: ReCOPRegisterFile
		GENERIC MAP 
		( 
			DATA_WIDTH => REG_FILE_DATA_WIDTH
		)
		PORT MAP
		(
			clk				=> clk,
			data			=> rf_data_in,
			wraddress		=> PM_OUT(8 downto 6),
			rdaddress_x		=> IR_Rx,
			rdaddress_z		=> IR_Rz,
			wren			=> wren,
			rden_x			=> rden_x,
			rden_z			=> rden_z,
			Rx				=> Rx,
			Rz				=> Rz
		);

    rf_data_in <=   IR_Operand when RF_in_select = RF_IN_SEL_IR_OPERAND else
                    Rx when RF_in_select = RF_IN_SEL_RX else
                    ALU_OUT when RF_in_select = RF_IN_SEL_ALU_OUT else
                    ALU_OUT;

    -- StackPointer: ReCOPStackPointer
    --     generic map (
    --         SP_init => SP_BASE
    --     )
    --     port map (
    --         clk => clk,
    --         rst => rst,

    --         wr_SP => wr_SP,
    --         mux_select => SP_mux_select,
    --         push_not_pull => push_not_pull,

    --         DM_OUT => DM_OUT,
    --         operand => IR_Operand,

    --         SP => SP,
    --         SP_incremented => SP_incremented
    --     );
    
    
    AddressRegister: ReCOPAddressRegister
        generic map (
            AR_init => AR_INIT
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

        ALU: ReCOPALU
            port map
            (   
                clock           => clk,
                ALU_Control     => ALU_Control,
                inputA          => ALU_mux_A,
                inputB          => ALU_mux_B,
                ALU_Out         => ALU_OUT,
                z_out           => z_out
            );

        ALU_mux_A <=   Rx;

        -- ALU_mux_A <=    IR_Operand when ALU_mux_A_select = MUX_A_SEL_IR_OPERAND else
        --                 Rx when ALU_mux_A_select = MUX_A_SEL_RX else
        --                 std_logic_vector(to_unsigned(1, ALU_mux_A'length)) when ALU_mux_A_select = MUX_A_SEL_ONE else
        --                 std_logic_vector(to_unsigned(1, ALU_mux_A'length));

        ALU_mux_B <=    Rz when ALU_mux_B_select = MUX_B_SEL_RZ else
                        IR_Operand when ALU_mux_B_select = MUX_B_SEL_IR_OPERAND else
                        Rx;

        InternalDataMemory: single_port_ram
		generic map
		(
			DATA_WIDTH => DM_DATA_WIDTH,
			ADDR_WIDTH => DM_ADDR_WIDTH
		)
		port map
		(
			clk		    => clk,
			addr		=> to_integer(unsigned(DM_ADR)), -- single_port_ram intakes integer addr
			data		=> DM_IN,
			we			=> we,
			q			=> DM_OUT
		);

        DM_IN <=    PM_ADR when DM_mux_select = DM_MUX_SEL_PM_ADR else
                    Rx when DM_mux_select = DM_MUX_SEL_RX else
                    IR_Operand when DM_mux_select = DM_MUX_SEL_IR_OPERAND else
                    Rx;
    
end architecture rtl;