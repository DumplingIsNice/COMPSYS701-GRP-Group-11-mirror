library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

library work;
use work.DFTTypes.all;
-- use work.TdmaMinTypes.all;

entity DFTDataPath is
    port (
        clk					: in std_logic;
        rst					: in std_logic;

        -- control
        enable				: in std_logic; -- value of x must change each clk cycle - disable to stall operation
        rst_sinusoid		: in std_logic; -- reset sinusoid approximation and contents, but keep c_sum in pipeline
            -- redundant w/ combinatorial synthesis?
        -- inputs
        x					: in signal_word;
        -- outputs
        magnitudes			: out magnitudes_array

        -- NoC
        -- noc_send			: out tdma_min_port;
        -- noc_recv			: in tdma_min_port
    );
end entity DFTDataPath;

architecture rtl of DFTDataPath is

    -- each k is a harmonic to evaluate
    -- each k requires a pair of values: cos(-wk), sin(-wk)
    type LUT_array			is array (2*K_LENGTH-1 downto 0) of signed_fxp_sinusoid;
    type magnitudes_array	is array (k-1 downto 0) of signed_correlation_sum;

    signal sinusoid_LUT		: LUT_array;
    signal magnitudes		: magnitudes_array	:= (others => '0');
    
    -- <LUT>

    component DFTDataPathUnit is
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            
            -- inputs
            cos_w_LUT       : in signed_fxp_sinusoid;
            yn1_LUT         : in signed_fxp_sinusoid;
            yn2_LUT         : in signed_fxp_sinusoid;
            x               : in signal_word;
            -- outputs
            c_sum           : out signed_correlation_sum
        );
    end component DFTDataPathUnit;

    component DFTMagnitude is
        generic (
            word_length		: natural
        );
        port (
            clk				: in std_logic;
            rst				: in std_logic;
    
            -- inputs
            a				: in signed(word_length-1 downto 0);
            b				: in signed(word_length-1 downto 0);
            -- outputs
            magnitude		: out unsigned(word_length+1 -1 downto 0)
        );
    end component DFTMagnitude;

begin

    main: process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                
            else

            end if;
        end if;
    end process main;

    units: for k in 0 to K_LENGTH-1 generate
        signal c_sum_re         : signed_correlation_sum;
        signal c_sum_im         : signed_correlation_sum;
        signal magnitude        : unsigned(signed_correlation_sum'length downto 0);
    begin:

        ReCosUnit: DFTDataPathUnit
            port map (
                clk => clk and enable,
                rst => rst or rst_sinusoid,
                
                -- inputs
                cos_w_LUT => sinusoid_LUT(2*k),
                yn1_LUT => to_signed(1, yn1_LUT'length),
                yn2_LUT => sinusoid_LUT(2*k),
                x => x,
                -- outputs
                c_sum => c_sum_re
            );

        ImSinUnit: DFTDataPathUnit
            port map (
                clk => clk and enable,
                rst => rst or rst_sinusoid,
                
                -- inputs
                cos_w_LUT => sinusoid_LUT(2*k),
                yn1_LUT => to_signed(0, yn1_LUT'length),
                yn2_LUT => sinusoid_LUT(2*k+1),
                x => x,
                -- outputs
                c_sum => c_sum_im
            );

        ApproximateMagnitude : DFTMagnitude
            generic map (
                word_length => signal_word'length-1
            )
            port map (
                clk	=> clk and enable,
                rst	=> rst,

                -- inputs
                a => c_sum_re(c_sum_re'length-1 downto c_sum_re'length - signal_word'length), -- shift right by log2(WINDOW_WIDTH)
                b => c_sum_im(c_sum_im'length-1 downto c_sum_im'length - signal_word'length), -- shift right by log2(WINDOW_WIDTH)
                -- outputs
                magnitude => magnitude
            );
        
        -- divide to input size (NOTE: magnitude is now proportional ONLY, must be scaled to original value!)
        magnitudes(k) <= magnitude(magnitude'length-1 downto magnitude'length - signal_word'length);
    end generate;

end architecture rtl;