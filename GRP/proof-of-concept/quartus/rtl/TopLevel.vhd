library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;
use work.TdmaMinTypes.all;

entity TopLevel is
    generic (
        ports   : positive := 8
    );
    port (
		CLOCK_50      : in    std_logic;
		CLOCK2_50     : in    std_logic;
		CLOCK3_50     : in    std_logic;
        RESET         : in    std_logic;

		FPGA_I2C_SCLK : out   std_logic;
		FPGA_I2C_SDAT : inout std_logic;
		AUD_ADCDAT    : in    std_logic;
		AUD_ADCLRCK   : inout std_logic;
		AUD_BCLK      : inout std_logic;
		AUD_DACDAT    : out   std_logic;
		AUD_DACLRCK   : inout std_logic;
		AUD_XCK       : out   std_logic;

		KEY           : in    std_logic_vector(3 downto 0);
		SW            : in    std_logic_vector(9 downto 0);
		LEDR          : out   std_logic_vector(9 downto 0);
		HEX0          : out   std_logic_vector(6 downto 0);
		HEX1          : out   std_logic_vector(6 downto 0);
		HEX2          : out   std_logic_vector(6 downto 0);
		HEX3          : out   std_logic_vector(6 downto 0);
		HEX4          : out   std_logic_vector(6 downto 0);
		HEX5          : out   std_logic_vector(6 downto 0);

        magnitudes          : out magnitudes_array;
        magnitudes_updated  : out std_logic
    );
end entity TopLevel;

architecture rtl of TopLevel is
    signal clk      : std_logic;
    signal rst      : std_logic;

    signal adc_empty : std_logic;
	signal adc_get   : std_logic;
	signal adc_data  : std_logic_vector(16 downto 0);
	signal dac_full  : std_logic;
	signal dac_put   : std_logic;
	signal dac_data  : std_logic_vector(16 downto 0);

    signal send_port : tdma_min_ports(0 to ports-1);
	signal recv_port : tdma_min_ports(0 to ports-1);
begin

    clk <= CLOCK_50;
    rst <= RESET;

	tdma_min : entity work.TdmaMin
	generic map (
		ports => ports
	)
	port map (
		clock => clk,
		sends => send_port,
		recvs => recv_port
	);

	adc_dac : entity work.Audio
	generic map (
		enable_adc => true	-- SET TRUE FOR ADC, not tone!
	)
	port map (
		ref_clock     => CLOCK3_50,
		fpga_i2c_sclk => FPGA_I2C_SCLK,
		fpga_i2c_sdat => FPGA_I2C_SDAT,
		aud_adcdat    => AUD_ADCDAT,
		aud_adclrck   => AUD_ADCLRCK,
		aud_bclk      => AUD_BCLK,
		aud_dacdat    => AUD_DACDAT,
		aud_daclrck   => AUD_DACLRCK,
		aud_xck       => AUD_XCK,

		clock         => clk,
		adc_empty     => adc_empty,
		adc_get       => adc_get,
		adc_data      => adc_data,
		dac_full      => dac_full,
		dac_put       => dac_put,
		dac_data      => dac_data
	);

    asp_adc : entity work.AspAdc
	port map (
		clock => clk,
		empty => adc_empty,
		get   => adc_get,
		data  => adc_data,

		send  => send_port(0),
		recv  => recv_port(0)
	);

	asp_dac : entity work.AspDac
	port map (
		clock => clk,
		full  => dac_full,
		put   => dac_put,
		data  => dac_data,

		send  => send_port(1),
		recv  => recv_port(1)
	);


    asp_dft: entity work.DataProcessingASP
    port map (
        clk => clk,
        rst	=> rst,

        -- inputs
        x_direct_ready => '0', -- unimplemented, NoC only
        x_direct => (others => '0'),
        -- outputs
        magnitudes => magnitudes,
        magnitudes_updated => magnitudes_updated,
        -- NoC
        noc_send => send_port(2),
        noc_recv => recv_port(2)
    );

	DispFrequency : entity work.DispPrimaryFrequency
	port map (
		clk => clk,
		rst => rst,
		-- inputs
		enable => magnitudes_updated,
		magnitudes => magnitudes,
		-- outputs
		seg0 => HEX0,
		seg1 => HEX1,
		seg2 => HEX2,
		seg3 => HEX3,
		seg4 => HEX4,
		seg5 => HEX5
	);

end architecture rtl;