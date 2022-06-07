library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;

entity DispPrimaryFrequency is
    port (
        clk     : in std_logic;
        rst     : in std_logic;

        -- inputs
        enable          : in std_logic;
        magnitudes      : in magnitudes_array;
        -- outputs
        seg0            : out std_logic_vector(6 downto 0);
		seg1            : out std_logic_vector(6 downto 0);
		seg2            : out std_logic_vector(6 downto 0);
		seg3            : out std_logic_vector(6 downto 0);
		seg4            : out std_logic_vector(6 downto 0);
		seg5            : out std_logic_vector(6 downto 0)
    );
end entity DispPrimaryFrequency;

architecture rtl of DispPrimaryFrequency is
    signal hex0            : std_logic_vector(3 downto 0) := (others => '0');
    signal hex1            : std_logic_vector(3 downto 0) := (others => '0');
    signal hex2            : std_logic_vector(3 downto 0) := (others => '0');
    signal hex3            : std_logic_vector(3 downto 0) := (others => '0');
    signal hex4            : std_logic_vector(3 downto 0) := (others => '0');
    signal hex5            : std_logic_vector(3 downto 0) := (others => '0');
begin
    
    UPDATE_SSG: process(clk)
        variable sig_max    : signal_word := (others => '0');
        variable i_max      : integer     := 0;
        variable f          : unsigned(natural(ceil(log2(real(K_LENGTH * K_STEP + SAMPLE_FREQ)))) downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hex0 <= (others => '0');
                hex1 <= (others => '0');
                hex2 <= (others => '0');
                hex3 <= (others => '0');
                hex4 <= (others => '0');
                hex5 <= (others => '0');
            else
                if enable = '1' then
                    sig_max := (others => '0');
                    i_max := 0;

                    for i in 0 to magnitudes'length-1 loop
                        -- f = i * step * (sample_freq/samples)
                        if magnitudes(i) > sig_max then
                            sig_max := magnitudes(i);
                            i_max := i;
                        end if;
                    end loop;

                    f := resize(to_unsigned(i_max, f'length) * to_unsigned(K_STEP, f'length), f'length);
                    f := resize((f * to_unsigned(SAMPLE_FREQ, f'length)) / to_unsigned(WINDOW_WIDTH, f'length), f'length);

                    -- unused
                    hex5 <= (others => '0');

                    -- tens of thousands
                    hex4 <= std_logic_vector(resize(f/10000, hex4'length));

                    -- thousands
                    f := f rem 10000;
                    hex3 <= std_logic_vector(resize(f/1000, hex3'length));

                    -- hundreds
                    f := f rem 1000;
                    hex2 <= std_logic_vector((resize(f/100, hex2'length)));

                    -- tens
                    f := f rem 100;
                    hex1 <= std_logic_vector(resize(f/10, hex1'length));

                    -- ones
                    f := f rem 10;
                    hex0 <= std_logic_vector(resize(f, hex0'length));
                    end if;
            end if;
        end if;
    end process UPDATE_SSG;


    hs0 : entity work.HexSeg
	port map (
		hex => hex0,
		seg => seg0
	);
    hs1 : entity work.HexSeg
	port map (
		hex => hex1,
		seg => seg1
	);
    hs2 : entity work.HexSeg
	port map (
		hex => hex2,
		seg => seg2
	);
    hs3 : entity work.HexSeg
	port map (
		hex => hex3,
		seg => seg3
	);
    hs4 : entity work.HexSeg
	port map (
		hex => hex4,
		seg => seg4
	);
    hs5 : entity work.HexSeg
	port map (
		hex => hex5,
		seg => seg5
	);
    
end architecture rtl;