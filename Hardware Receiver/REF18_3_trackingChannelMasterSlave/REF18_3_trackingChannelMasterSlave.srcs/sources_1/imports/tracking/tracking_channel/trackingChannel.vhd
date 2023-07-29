--***************************************************************************
--* Subsystem:  tracking channel 
--* Filename:  trackingChannel.vhd   
--* Author: P. BLUNT      
--* Date Created: 23/10/18
--*
--***************************************************************************
--* DESCRIPTION
--*
--* Purpose           : This block creates a tracking channel for a GNSS signal with BPSK or BOC(n,n) modulation
--*
--* Limitations       : Design assumes a single sampling clock input and assumes this clock for the signal defined
--*                     i.e. there is no sampling clock enable for a different rate
--*                     carrier replica generation is only 2-bit
--*
--* Dependencies      : receiverConfigurationPackage.vhd
--*
--* Generics/Constants: signal_type_g - BPSK = 0, BOC_n_n = 1
--*                     correlation_length_g - in ms (range 1 to 20)
--*
--* Inputs            : areset_n_b_in - asynchronous reset input  
--*                     sample_clk_b_in - sample clock input
--*                     data_FE_sync_u_in - input data array from front end synchronised to the sample clock  
--*                     
--* Outputs           :  
--*
--* Functional timing :
--*
--* Errors            : No known errors
--*
--* Related Documents : 
--*
--***************************************************************************
--* CONFIGURATION
--*
--* Synthesis         : Vivado 2018.2
--*
--* Simulator         : Vivado 2018.2
--*
--* Place and route   : Vivado 2018.2
--*
--***************************************************************************


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

use work.receiverConfigurationPackage.all;

entity trackingChannel is
    generic(    enable_BOC_bool_g               : boolean := true );
    Port (      
                sample_clk_b_in                 : in STD_LOGIC;
                data_FE_sync_u_in               : in data_FE_type;
                front_end_select_u_in           : in std_logic_vector((FE_SELECT_SIZE - 1) downto 0);
                RAM_we_b_in                     : in std_logic; 
                RAM_en_b_in                     : in std_logic;
                RAM_addr_u_in                   : in std_logic_vector((ADDR_LEN_WORDS_E5a_I_C - 1) downto 0);
                RAM_di_u_in                     : in std_logic_vector((REG_WIDTH_C -1) downto 0);
                PPS_20ms_b_in                   : in std_logic;
                start_enable_b_in               : in std_logic;
                SW_reset_in                     : in std_logic;
                signal_type_u_in                : in std_logic_vector((SIGNAL_TYPE_SIZE_I_C - 1) downto 0);
                start_chip_u_in                 : in std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
                start_epoch_u_in                : in std_logic_vector((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
                code_len_chip_u_in              : in std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
                code_len_chip_1ms_u_in          : in std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
                carr_NCO_increment_u_in         : in std_logic_vector((CARR_NCO_LENGTH_C - 1) downto 0);
                code_NCO_increment_u_in         : in std_logic_vector((CODE_NCO_LENGTH_C - 1) downto 0);
                early_prompt_spacing_u_in       : in std_logic_vector((CODE_DELAY_LEN_I_C - 1) downto 0);
                very_early_prompt_spacing_u_in  : in std_logic_vector((CODE_DELAY_LEN_I_C - 1) downto 0);
                correlation_length_epochs_u_in  : in std_logic_vector((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
                epoch_length_ms_u_in            : in std_logic_vector((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
                bit_length_u_in                 : in std_logic_vector((SEC_CODE_COUNT_SIZE_C - 1) downto 0);
                fast_nco_count_value_u_in       : in std_logic_vector((MAX_NCO_COUNT_LENGTH_C - 1) downto 0);
                arm_slave_start_b_in            : in std_logic;
                code_epoch_slave_b_in           : in std_logic;
                code_NCO_master_u_in            : in std_logic_vector((CODE_NCO_LENGTH_C - 1) downto 0);

                measurement_enable_b_in         : in std_logic;
                code_NCO_start_u_in             : in std_logic_vector((CODE_NCO_LENGTH_C - 1) downto 0);
                ena_bit_count_b_in              : in std_logic;
                --clr_bit_count_b_in              : in std_logic;
                clr_interrupt_b_u_in            : in std_logic;
                interrupt_b_out                 : out std_logic;
                
                accumulation_P_I_reg_s_out      : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accumulation_P_Q_reg_s_out      : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accumulation_E_I_reg_s_out      : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accumulation_E_Q_reg_s_out      : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accumulation_L_I_reg_s_out      : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accumulation_L_Q_reg_s_out      : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accumulation_VE_I_reg_s_out     : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accumulation_VE_Q_reg_s_out     : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accumulation_VL_I_reg_s_out     : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accumulation_VL_Q_reg_s_out     : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                accm_1ms_P_I_reg_a_s_out        : out accm_1ms_array_type;
                accm_1ms_P_Q_reg_a_s_out        : out accm_1ms_array_type;
                RAM_do_u_out                    : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                meas_code_NCO_u_out             : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                meas_chip_count_u_out           : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                meas_epoch_count_u_out          : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                meas_carr_NCO_u_out             : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                meas_cycle_count_u_out          : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                meas_bit_count_u_out            : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                meas_sec_count_u_out            : out std_logic_vector((REG_WIDTH_C -1) downto 0);
                code_NCO_master_u_out           : out std_logic_vector((CODE_NCO_LENGTH_C - 1) downto 0);
                code_epoch_master_b_out         : out std_logic            
                                                               
             );
end trackingChannel;

architecture Behavioral of trackingChannel is

constant ALL_ONES_NCO_U_C           : unsigned ((CODE_NCO_LENGTH_C - 1) downto 0) := (others => '1');
signal carr_NCO_reg_u               : unsigned ((CARR_NCO_LENGTH_C - 1) downto 0);

signal carr_NCO_reg_use_u           : unsigned (2 downto 0);

signal code_NCO_reg_u               : unsigned ((CODE_NCO_LENGTH_C - 1) downto 0);

-- carrier replica 
signal carr_replica_sine_i          : integer range -MAX_CARR_AMP_C to MAX_CARR_AMP_C;
signal carr_replica_cosine_i        : integer range -MAX_CARR_AMP_C to MAX_CARR_AMP_C;

-- received signal integer 
signal rx_signal_i                  : integer range -MAX_INPUT_AMP_C to MAX_INPUT_AMP_C;

-- post carrier mixing signal
signal post_carr_mix_I_i            : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_mix_Q_i            : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);

-- post carrier and code mixing signal
signal post_carr_code_mix_P_I_i       : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_code_mix_P_Q_i       : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_code_mix_E_I_i       : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_code_mix_E_Q_i       : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_code_mix_L_I_i       : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_code_mix_L_Q_i       : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_code_mix_VE_I_i      : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_code_mix_VE_Q_i      : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_code_mix_VL_I_i      : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);
signal post_carr_code_mix_VL_Q_i      : integer range -(MAX_INPUT_AMP_C * MAX_CARR_AMP_C) to (MAX_INPUT_AMP_C * MAX_CARR_AMP_C);

signal code_RAM_word_u              : std_logic_vector((REG_WIDTH_C - 1) downto 0); 
signal code_replica_b               : std_logic;  
signal subcarrier_replica_b         : std_logic;
signal code_chip_count_u            : unsigned((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
signal code_chip_count_1ms_u        : unsigned((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
signal code_epoch_count_u           : unsigned((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
signal code_epoch_1ms_count_u       : unsigned((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
signal code_NCO_count_u             : unsigned((MAX_NCO_COUNT_LENGTH_C - 1) downto 0);

signal bit_count_u                  : unsigned((SEC_CODE_COUNT_SIZE_C - 1) downto 0);
signal sec_count_u                  : unsigned(SEC_COUNTER_WIDTH_C downto 0);


signal ena_bit_count_b              : std_logic;

signal accumulation_P_I_s           : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);      
signal accumulation_P_Q_s           : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);
signal accumulation_E_I_s           : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);
signal accumulation_E_Q_s           : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);
signal accumulation_L_I_s           : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);
signal accumulation_L_Q_s           : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);
signal accumulation_VE_I_s          : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);
signal accumulation_VE_Q_s          : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);
signal accumulation_VL_I_s          : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);
signal accumulation_VL_Q_s          : signed((ACCUMULATOR_SIZE_I_C - 1) downto 0);
signal accm_1ms_P_I_s               : signed((ACC_1MS_SIZE_I_C - 1) downto 0);
signal accm_1ms_P_Q_s               : signed((ACC_1MS_SIZE_I_C - 1) downto 0);

signal accumulation_P_I_reg_s       : signed((REG_WIDTH_C - 1) downto 0);
signal accumulation_P_Q_reg_s       : signed((REG_WIDTH_C - 1) downto 0);
signal accumulation_E_I_reg_s       : signed((REG_WIDTH_C - 1) downto 0);
signal accumulation_E_Q_reg_s       : signed((REG_WIDTH_C - 1) downto 0);
signal accumulation_L_I_reg_s       : signed((REG_WIDTH_C - 1) downto 0);
signal accumulation_L_Q_reg_s       : signed((REG_WIDTH_C - 1) downto 0);
signal accumulation_VE_I_reg_s      : signed((REG_WIDTH_C - 1) downto 0);
signal accumulation_VE_Q_reg_s      : signed((REG_WIDTH_C - 1) downto 0);
signal accumulation_VL_I_reg_s      : signed((REG_WIDTH_C - 1) downto 0);
signal accumulation_VL_Q_reg_s      : signed((REG_WIDTH_C - 1) downto 0);
signal accm_1ms_P_I_reg_a_s         : accm_1ms_array_type;
signal accm_1ms_P_Q_reg_a_s         : accm_1ms_array_type;

signal RAM_we_b                     : std_logic; 
signal RAM_en_b                     : std_logic; 
signal RAM_addr_u                   : std_logic_vector((ADDR_LEN_WORDS_E5a_I_C - 1) downto 0); 
signal arm_start_b                  : std_logic;
signal correlator_enable_b          : std_logic;
signal code_subcarr_delay_reg_u     : std_logic_vector((CODE_DELAY_SIZE_I_C - 1) downto 0);

signal carr_cycle_count_u           : unsigned((CYCLE_COUNT_SIZE_I_C - 1) downto 0);

signal interrupt_reg_b              : std_logic;

--attribute mark_debug : string;                            
--attribute keep : string;    

--attribute mark_debug of code_NCO_reg_u         : signal is "true";
--attribute mark_debug of code_chip_count_u      : signal is "true";
--attribute mark_debug of code_epoch_count_u     : signal is "true";
--attribute mark_debug of carr_NCO_reg_u         : signal is "true";
--attribute mark_debug of carr_cycle_count_u     : signal is "true";
--attribute mark_debug of bit_count_u            : signal is "true";

--attribute mark_debug of accm_1ms_P_I_reg_a_s signal is "true";
--attribute mark_debug of correlator_enable_b  : signal is "true";
--attribute mark_debug of interrupt_reg_b      : signal is "true";
--attribute mark_debug of correlation_length_epochs_u_in  : signal is "true";
--attribute mark_debug of very_early_prompt_spacing_u_in  : signal is "true";
--attribute mark_debug of early_prompt_spacing_u_in       : signal is "true";
--attribute mark_debug of post_carr_code_mix_P_I_i        : signal is "true";
--attribute mark_debug of code_subcarr_delay_reg_u        : signal is "true";

--attribute mark_debug of post_carr_code_mix_E_I_i        : signal is "true";
--attribute mark_debug of post_carr_code_mix_L_I_i        : signal is "true";
--attribute mark_debug of post_carr_code_mix_VE_I_i       : signal is "true";
--attribute mark_debug of post_carr_code_mix_VL_I_i       : signal is "true";
--attribute mark_debug of code_chip_count_u      : signal is "true";
--attribute mark_debug of code_chip_count_1ms_u  : signal is "true";
--attribute mark_debug of code_epoch_count_u     : signal is "true";
--attribute mark_debug of code_epoch_1ms_count_u : signal is "true";
--attribute mark_debug of code_len_chip_u_in      : signal is "true";
--attribute mark_debug of accumulation_P_I_reg_s_out      : signal is "true";
--attribute mark_debug of carr_NCO_increment_u_in         : signal is "true";
--attribute mark_debug of code_NCO_increment_u_in         : signal is "true";

--attribute mark_debug of code_len_chip_1ms_u_in      : signal is "true";
--attribute mark_debug of RAM_we_b_in   : signal is "true";
--attribute mark_debug of RAM_en_b_in   : signal is "true";
--attribute mark_debug of RAM_addr_u_in : signal is "true";
--attribute mark_debug of RAM_di_u_in   : signal is "true";
--attribute mark_debug of code_epoch_1ms_count_u   : signal is "true";
--attribute mark_debug of accumulation_P_I_reg_s_out : signal is "true";
--signal overflow_NCO_dbg : std_logic;
--attribute mark_debug of overflow_NCO_dbg        : signal is "true";
--attribute mark_debug of accm_1ms_P_I_s          : signal is "true";
--attribute mark_debug of code_chip_count_1ms_u   : signal is "true";
--attribute mark_debug of accm_1ms_P_I_reg_a_s    : signal is "true";
--attribute mark_debug of accm_1ms_P_Q_reg_a_s    : signal is "true";

begin

-- for debugging Narrow/Power only
--overflow_NCO_dbg <= '1' when code_NCO_reg_u > (ALL_ONES_NCO_U_C - unsigned(code_NCO_increment_u_in)) else '0';

-----------------------------------------------------------------------
---  code RAM connections  --------------------------------------------
-----------------------------------------------------------------------  
code_RAM : entity work.RAM_PRN 
        port map  (         clka_b_in   => sample_clk_b_in,
                            clkb_b_in   => sample_clk_b_in,
                            wea_b_in    => RAM_we_b_in,
                            ena_b_in    => RAM_en_b_in,
                            enb_b_in    => '1',
                            addra_u_in  => RAM_addr_u_in,
                            addrb_u_in  => std_logic_vector(code_chip_count_u(code_chip_count_u'left downto WORD_ADDR_BITS_I_C)),
                            dia_u_in    => RAM_di_u_in,
                            doa_u_out   => RAM_do_u_out,
                            dob_u_out   => code_RAM_word_u);

-- select the chip
code_replica_b <= code_RAM_word_u(to_integer(code_chip_count_u((WORD_ADDR_BITS_I_C - 1) downto 0)));

-----------------------------------------------------------------------
---  synchronous process  ---------------------------------------------
-----------------------------------------------------------------------

--process (areset_n_b_in, sample_clk_b_in)
process (sample_clk_b_in)
-- pragma translate_off
use STD.TEXTIO.all;
constant LOG_FILE_NAME : string := "Is_and_Qs_signal.log";
file LogFile : text open write_mode is LOG_FILE_NAME;
variable l : line;
-- pragma translate_on
begin
		
if rising_edge(sample_clk_b_in) then   
        -- software reset of the correlator
        if SW_reset_in = '1' then
            arm_start_b <= '0';
            correlator_enable_b <= '0';
            
            code_chip_count_1ms_u    <= unsigned(start_chip_u_in);
            code_epoch_count_u       <= unsigned(start_epoch_u_in);
            code_epoch_1ms_count_u   <= unsigned(start_epoch_u_in);     
            code_NCO_count_u         <= (others=>'0');            
            
            carr_NCO_reg_u           <= (others=>'0');
            
            carr_cycle_count_u       <= (others=>'0');
            accumulation_P_I_s       <= (others=>'0');
            accumulation_P_Q_s       <= (others=>'0');
            accumulation_E_I_s       <= (others=>'0');
            accumulation_E_Q_s       <= (others=>'0');
            accumulation_L_I_s       <= (others=>'0');
            accumulation_L_Q_s       <= (others=>'0');
            accumulation_VE_I_s      <= (others=>'0');
            accumulation_VE_Q_s      <= (others=>'0');
            accumulation_VL_I_s      <= (others=>'0');
            accumulation_VL_Q_s      <= (others=>'0');
            accm_1ms_P_I_s           <= (others=>'0');
            accm_1ms_P_Q_s           <= (others=>'0');
            accm_1ms_P_I_reg_a_s     <= (others => (others=>'0'));
            accm_1ms_P_Q_reg_a_s     <= (others => (others=>'0'));
            
            meas_code_NCO_u_out      <= (others => '0');
            meas_chip_count_u_out    <= (others => '0');
            meas_epoch_count_u_out   <= (others => '0');
            meas_carr_NCO_u_out      <= (others => '0');
            meas_cycle_count_u_out   <= (others => '0');
            meas_bit_count_u_out     <= (others => '0');
            meas_sec_count_u_out     <= (others => '0');
           
            ena_bit_count_b <= '0';
            
            bit_count_u              <= (others => '0');
            sec_count_u              <= (others => '0');
            
            interrupt_reg_b <= '0';
            
            
            code_NCO_reg_u           <= unsigned(code_NCO_start_u_in);
            code_chip_count_u        <= unsigned(start_chip_u_in);
          
        else    
            -- control the start of the correlation
            if (start_enable_b_in = '1') or (arm_slave_start_b_in = '1') then
                arm_start_b <= '1';
            end if;
            
            if (arm_start_b = '1') then   
                if (arm_slave_start_b_in = '0') then
                    if (PPS_20ms_b_in = '1')  then
                        correlator_enable_b <= '1';
                    end if;
                elsif (code_epoch_slave_b_in = '1') then
                    correlator_enable_b <= '1';
                end if;
            end if;
            
            ---- reset the bit counter
            --if clr_bit_count_b_in = '1' then
            --    bit_count_u <= (others => '0');
            --end if;
            if ena_bit_count_b_in = '1' then
                ena_bit_count_b <= '1';
            end if;
            
            
            -- reset the interrupt
            if clr_interrupt_b_u_in = '1' then
                interrupt_reg_b <= '0';            
            end if;
        
            if (correlator_enable_b = '1') then    
             
                -- update NCOs
                carr_NCO_reg_u <= carr_NCO_reg_u + unsigned(carr_NCO_increment_u_in);
                code_NCO_reg_u <= code_NCO_reg_u + unsigned(code_NCO_increment_u_in);
                
                if (enable_BOC_bool_g = true) then 
                    -- generate sine phased subcarrier for E1 signal
                    if (signal_type_u_in = std_logic_vector(to_unsigned(E1B_SIGNAL, SIGNAL_TYPE_SIZE_I_C))) then
                        subcarrier_replica_b <= code_NCO_reg_u(code_NCO_reg_u'left);
                    else
                        subcarrier_replica_b <= '0';
                    end if;
                end if;
                
                carr_NCO_reg_use_u <= carr_NCO_reg_u((CARR_NCO_LENGTH_C - 1) downto (CARR_NCO_LENGTH_C - 3));
                
                
                -- LUT
                -- carr_replica_sine_u/ cocarr_replica_sine_u mapping (2bit)
                case carr_NCO_reg_u((CARR_NCO_LENGTH_C - 1) downto (CARR_NCO_LENGTH_C - 3)) is           
                    when "000" 	=> 	    carr_replica_sine_i <= -1;
                                               carr_replica_cosine_i <= 2;
                    when "001" 	=> 	    carr_replica_sine_i <= 1;
                                               carr_replica_cosine_i <= 2;
                    when "010" 	=> 	    carr_replica_sine_i <= 2;
                                               carr_replica_cosine_i <= 1;
                    when "011" 	=> 	    carr_replica_sine_i <= 2;
                                               carr_replica_cosine_i <= -1;
                    when "100" 	=> 	    carr_replica_sine_i <= 1;
                                               carr_replica_cosine_i <= -2;
                    when "101" 	=> 	    carr_replica_sine_i <= -1;
                                               carr_replica_cosine_i <= -2;
                    when "110" 	=> 	    carr_replica_sine_i <= -2;
                                               carr_replica_cosine_i <= -1;
                    when others => 	    carr_replica_sine_i <= -2;
                                               carr_replica_cosine_i <= 1;
                end case;
                
                -- carrier mapping (2 bit input)
                case data_FE_sync_u_in(to_integer(unsigned(front_end_select_u_in))) is 
                    when "01"           =>     rx_signal_i <= -3;
                    when "00"           =>     rx_signal_i <= -1;
                    when "10"           =>     rx_signal_i <= 1;    
                    when others         =>     rx_signal_i <= 3;
                end case;
                
                -- carrier mixing
--                post_carr_mix_I_i <= rx_signal_i * carr_replica_sine_i;
--                post_carr_mix_Q_i <= rx_signal_i * carr_replica_cosine_i; 
                post_carr_mix_I_i <= rx_signal_i * carr_replica_cosine_i;
                post_carr_mix_Q_i <= rx_signal_i * carr_replica_sine_i;
                
                -- code and subcarrier mixing and delay shift register
                code_subcarr_delay_reg_u <= code_subcarr_delay_reg_u((code_subcarr_delay_reg_u'left - 1) downto 0) & (code_replica_b xor subcarrier_replica_b);
                
                -- prompt mixing
                if (code_subcarr_delay_reg_u(CODE_DELAY_MID_POINT_I_C) = '1') then
                    post_carr_code_mix_P_I_i <= post_carr_mix_I_i;
                    post_carr_code_mix_P_Q_i <= post_carr_mix_Q_i;
                else
                    post_carr_code_mix_P_I_i <= -post_carr_mix_I_i;
                    post_carr_code_mix_P_Q_i <= -post_carr_mix_Q_i;
                end if;	
                -- early mixing
                --if (code_subcarr_delay_reg_u(CODE_DELAY_MID_POINT_I_C + to_integer(unsigned(early_prompt_spacing_u_in))) = '1') then
                if (code_subcarr_delay_reg_u(CODE_DELAY_MID_POINT_I_C - to_integer(unsigned(early_prompt_spacing_u_in))) = '1') then
                    post_carr_code_mix_E_I_i <= post_carr_mix_I_i;
                    post_carr_code_mix_E_Q_i <= post_carr_mix_Q_i;
                else
                    post_carr_code_mix_E_I_i <= -post_carr_mix_I_i;
                    post_carr_code_mix_E_Q_i <= -post_carr_mix_Q_i;
                end if;
                -- late mixing
                if (code_subcarr_delay_reg_u(CODE_DELAY_MID_POINT_I_C + to_integer(unsigned(early_prompt_spacing_u_in))) = '1') then
                    post_carr_code_mix_L_I_i <= post_carr_mix_I_i;
                    post_carr_code_mix_L_Q_i <= post_carr_mix_Q_i;
                else
                    post_carr_code_mix_L_I_i <= -post_carr_mix_I_i;
                    post_carr_code_mix_L_Q_i <= -post_carr_mix_Q_i;
                end if;
                
                if (enable_BOC_bool_g = true) then 
                    -- very early mixing
                    --if (code_subcarr_delay_reg_u(CODE_DELAY_MID_POINT_I_C + to_integer(unsigned(very_early_prompt_spacing_u_in))) = '1') then
                    if (code_subcarr_delay_reg_u(CODE_DELAY_MID_POINT_I_C - to_integer(unsigned(very_early_prompt_spacing_u_in))) = '1') then
                        post_carr_code_mix_VE_I_i <= post_carr_mix_I_i;
                        post_carr_code_mix_VE_Q_i <= post_carr_mix_Q_i;
                    else
                        post_carr_code_mix_VE_I_i <= -post_carr_mix_I_i;
                        post_carr_code_mix_VE_Q_i <= -post_carr_mix_Q_i;
                    end if;
                    -- very late mixing
                    if (code_subcarr_delay_reg_u(CODE_DELAY_MID_POINT_I_C + to_integer(unsigned(very_early_prompt_spacing_u_in))) = '1') then
                        post_carr_code_mix_VL_I_i <= post_carr_mix_I_i;
                        post_carr_code_mix_VL_Q_i <= post_carr_mix_Q_i;
                    else
                        post_carr_code_mix_VL_I_i <= -post_carr_mix_I_i;
                        post_carr_code_mix_VL_Q_i <= -post_carr_mix_Q_i;
                    end if;
                end if;
                                    
                -- check for overflow of the code NCO MSB on next cycle
                -- ALL_ONES_NCO_U_C - unsigned(code_NCO_increment_u_in) = FD5D 59A3 4,250,753,443
                if code_NCO_reg_u > (ALL_ONES_NCO_U_C - unsigned(code_NCO_increment_u_in)) then                      
                    if (code_NCO_count_u = (unsigned(fast_nco_count_value_u_in) - 1)) then
--                    if (code_NCO_count_u = (unsigned(fast_nco_count_value_u_in) - 1)) then
                        
                        code_NCO_count_u <= (others=>'0');
                        
                        -- check for a 1 ms boundary
                        if (code_chip_count_1ms_u = (unsigned(code_len_chip_1ms_u_in) - 1) ) then
                            if (code_epoch_1ms_count_u = (unsigned (epoch_length_ms_u_in) - 1)) then
                                code_epoch_1ms_count_u <= (others => '0');
                            else
                                code_epoch_1ms_count_u <= code_epoch_1ms_count_u + 1;
                            end if;
                            -- fill up the 1ms accumulation array
                            accm_1ms_P_I_reg_a_s(to_integer(code_epoch_1ms_count_u)) <= std_logic_vector(resize(accm_1ms_P_I_s, REG_WIDTH_C));
                            accm_1ms_P_Q_reg_a_s(to_integer(code_epoch_1ms_count_u)) <= std_logic_vector(resize(accm_1ms_P_Q_s, REG_WIDTH_C));
                            
                            -- reset the 1 ms counter
                            code_chip_count_1ms_u <= (others=>'0');
                            accm_1ms_P_I_s <= (others=>'0');
                            accm_1ms_P_Q_s <= (others=>'0');
        --                        accm_1ms_P_I_s <= to_signed(post_carr_code_mix_P_I_i, ACC_1MS_SIZE_I_C);
        --                        accm_1ms_P_Q_s <= to_signed(post_carr_code_mix_P_Q_i, ACC_1MS_SIZE_I_C);
                                                     
                        else
                            -- 1ms 
                            code_chip_count_1ms_u <= code_chip_count_1ms_u + 1; 
                            accm_1ms_P_I_s <= accm_1ms_P_I_s + post_carr_code_mix_P_I_i;
                            accm_1ms_P_Q_s <= accm_1ms_P_Q_s + post_carr_code_mix_P_Q_i;                          
                        end if;
                               
                        if (code_chip_count_u = (unsigned(code_len_chip_u_in) - 1)) then
                            -- reset the chip counter
                            code_chip_count_u <= (others=>'0');
                            
                            if (code_epoch_count_u = (unsigned(correlation_length_epochs_u_in) - 1)) then
                                -- update the bit counter
                                if bit_count_u = (unsigned(bit_length_u_in) - 1) and ena_bit_count_b = '1' then                                
                                    bit_count_u <= (others => '0'); 
                                    
                                    sec_count_u <= sec_count_u + 1; -- count to overflow
                                                               
                                elsif ena_bit_count_b = '1' then                           
                                    bit_count_u <= bit_count_u + 1;                                
                                end if;                                                        
                                -- pragma translate_off
                                write(l, to_integer(accumulation_P_I_s));
                                write(l, string'(", "));
                                write(l, to_integer(accumulation_P_Q_s));
                
                                writeline(LogFile, l);
                                -- pragma translate_on
                                
                                -- reset the epoch count
                                code_epoch_count_u <= (others => '0');
                                -- register the accumulations
                                accumulation_P_I_reg_s <= resize(accumulation_P_I_s, REG_WIDTH_C);
                                accumulation_P_Q_reg_s <= resize(accumulation_P_Q_s, REG_WIDTH_C);
                                accumulation_E_I_reg_s <= resize(accumulation_E_I_s, REG_WIDTH_C);
                                accumulation_E_Q_reg_s <= resize(accumulation_E_Q_s, REG_WIDTH_C);
                                accumulation_L_I_reg_s <= resize(accumulation_L_I_s, REG_WIDTH_C);
                                accumulation_L_Q_reg_s <= resize(accumulation_L_Q_s, REG_WIDTH_C);
                                
                                -- reset the accumulators
                                accumulation_P_I_s <= (others=>'0');
                                accumulation_P_Q_s <= (others=>'0');
                                accumulation_E_I_s <= (others=>'0');
                                accumulation_E_Q_s <= (others=>'0');
                                accumulation_L_I_s <= (others=>'0');
                                accumulation_L_Q_s <= (others=>'0');
                                
                                -- use these signals conditions to trigger an interrupt and a missed accumulation counter
                                interrupt_reg_b <= '1';
                                
    --                            accumulation_P_I_s <= to_signed(post_carr_code_mix_P_I_i, ACCUMULATOR_SIZE_I_C);
    --                            accumulation_P_Q_s <= to_signed(post_carr_code_mix_P_Q_i, ACCUMULATOR_SIZE_I_C);
    --                            accumulation_E_I_s <= to_signed(post_carr_code_mix_E_I_i, ACCUMULATOR_SIZE_I_C);
    --                            accumulation_E_Q_s <= to_signed(post_carr_code_mix_E_Q_i, ACCUMULATOR_SIZE_I_C);
    --                            accumulation_L_I_s <= to_signed(post_carr_code_mix_L_I_i, ACCUMULATOR_SIZE_I_C);
    --                            accumulation_L_Q_s <= to_signed(post_carr_code_mix_L_Q_i, ACCUMULATOR_SIZE_I_C);
                                
                                -- register and reset BOC accumulations
                                if (enable_BOC_bool_g = true) then 
                                    accumulation_VE_I_reg_s <= resize(accumulation_VE_I_s, REG_WIDTH_C);
                                    accumulation_VE_Q_reg_s <= resize(accumulation_VE_Q_s, REG_WIDTH_C);
                                    accumulation_VL_I_reg_s <= resize(accumulation_VL_I_s, REG_WIDTH_C);
                                    accumulation_VL_Q_reg_s <= resize(accumulation_VL_Q_s, REG_WIDTH_C);
                                    accumulation_VE_I_s <= (others=>'0');
                                    accumulation_VE_Q_s <= (others=>'0');
                                    accumulation_VL_I_s <= (others=>'0');
                                    accumulation_VL_Q_s <= (others=>'0');
                                    
    --                                accumulation_VE_I_s <= to_signed(post_carr_code_mix_VE_I_i, ACCUMULATOR_SIZE_I_C);
    --                                accumulation_VE_Q_s <= to_signed(post_carr_code_mix_VE_Q_i, ACCUMULATOR_SIZE_I_C);
    --                                accumulation_VL_I_s <= to_signed(post_carr_code_mix_VL_I_i, ACCUMULATOR_SIZE_I_C);
    --                                accumulation_VL_Q_s <= to_signed(post_carr_code_mix_VL_Q_i, ACCUMULATOR_SIZE_I_C);
                                end if;                                                                                                                                                                
                            else
                                code_epoch_count_u <= code_epoch_count_u + 1;
                                accumulation_P_I_s <= accumulation_P_I_s + post_carr_code_mix_P_I_i;
                                accumulation_P_Q_s <= accumulation_P_Q_s + post_carr_code_mix_P_Q_i;
                                accumulation_E_I_s <= accumulation_E_I_s + post_carr_code_mix_E_I_i;
                                accumulation_E_Q_s <= accumulation_E_Q_s + post_carr_code_mix_E_Q_i;
                                accumulation_L_I_s <= accumulation_L_I_s + post_carr_code_mix_L_I_i;
                                accumulation_L_Q_s <= accumulation_L_Q_s + post_carr_code_mix_L_Q_i;
                                
                                if (enable_BOC_bool_g = true) then 
                                    accumulation_VE_I_s <= accumulation_VE_I_s + post_carr_code_mix_VE_I_i;
                                    accumulation_VE_Q_s <= accumulation_VE_Q_s + post_carr_code_mix_VE_Q_i;
                                    accumulation_VL_I_s <= accumulation_VL_I_s + post_carr_code_mix_VL_I_i;
                                    accumulation_VL_Q_s <= accumulation_VL_Q_s + post_carr_code_mix_VL_Q_i; 
                                end if; 
                            end if;
                        
                        else        
                            code_chip_count_u <= code_chip_count_u + 1;
                            accumulation_P_I_s <= accumulation_P_I_s + post_carr_code_mix_P_I_i;
                            accumulation_P_Q_s <= accumulation_P_Q_s + post_carr_code_mix_P_Q_i;
                            accumulation_E_I_s <= accumulation_E_I_s + post_carr_code_mix_E_I_i;
                            accumulation_E_Q_s <= accumulation_E_Q_s + post_carr_code_mix_E_Q_i;
                            accumulation_L_I_s <= accumulation_L_I_s + post_carr_code_mix_L_I_i;
                            accumulation_L_Q_s <= accumulation_L_Q_s + post_carr_code_mix_L_Q_i;
                            
                            if (enable_BOC_bool_g = true) then 
                                accumulation_VE_I_s <= accumulation_VE_I_s + post_carr_code_mix_VE_I_i;
                                accumulation_VE_Q_s <= accumulation_VE_Q_s + post_carr_code_mix_VE_Q_i;
                                accumulation_VL_I_s <= accumulation_VL_I_s + post_carr_code_mix_VL_I_i;
                                accumulation_VL_Q_s <= accumulation_VL_Q_s + post_carr_code_mix_VL_Q_i; 
                            end if;  
                            
                        end if;
                    else        
                        code_NCO_count_u <= code_NCO_count_u + 1;
                        accumulation_P_I_s <= accumulation_P_I_s + post_carr_code_mix_P_I_i;
                        accumulation_P_Q_s <= accumulation_P_Q_s + post_carr_code_mix_P_Q_i;
                        accumulation_E_I_s <= accumulation_E_I_s + post_carr_code_mix_E_I_i;
                        accumulation_E_Q_s <= accumulation_E_Q_s + post_carr_code_mix_E_Q_i;
                        accumulation_L_I_s <= accumulation_L_I_s + post_carr_code_mix_L_I_i;
                        accumulation_L_Q_s <= accumulation_L_Q_s + post_carr_code_mix_L_Q_i;
                        
                        if (enable_BOC_bool_g = true) then 
                            accumulation_VE_I_s <= accumulation_VE_I_s + post_carr_code_mix_VE_I_i;
                            accumulation_VE_Q_s <= accumulation_VE_Q_s + post_carr_code_mix_VE_Q_i;
                            accumulation_VL_I_s <= accumulation_VL_I_s + post_carr_code_mix_VL_I_i;
                            accumulation_VL_Q_s <= accumulation_VL_Q_s + post_carr_code_mix_VL_Q_i; 
                        end if;
                    end if;
                else
                    accumulation_P_I_s <= accumulation_P_I_s + post_carr_code_mix_P_I_i;
                    accumulation_P_Q_s <= accumulation_P_Q_s + post_carr_code_mix_P_Q_i;
                    accumulation_E_I_s <= accumulation_E_I_s + post_carr_code_mix_E_I_i;
                    accumulation_E_Q_s <= accumulation_E_Q_s + post_carr_code_mix_E_Q_i;
                    accumulation_L_I_s <= accumulation_L_I_s + post_carr_code_mix_L_I_i;
                    accumulation_L_Q_s <= accumulation_L_Q_s + post_carr_code_mix_L_Q_i;
                    accm_1ms_P_I_s <= accm_1ms_P_I_s + post_carr_code_mix_P_I_i;
                    accm_1ms_P_Q_s <= accm_1ms_P_Q_s + post_carr_code_mix_P_Q_i;
                    
                    if (enable_BOC_bool_g = true) then 
                        accumulation_VE_I_s <= accumulation_VE_I_s + post_carr_code_mix_VE_I_i;
                        accumulation_VE_Q_s <= accumulation_VE_Q_s + post_carr_code_mix_VE_Q_i;
                        accumulation_VL_I_s <= accumulation_VL_I_s + post_carr_code_mix_VL_I_i;
                        accumulation_VL_Q_s <= accumulation_VL_Q_s + post_carr_code_mix_VL_Q_i; 
                    end if;  
                end if;

                -- check for overflow of the carr NCO MSB on next cycle
                if carr_NCO_reg_u > (ALL_ONES_NCO_U_C - unsigned(carr_NCO_increment_u_in)) then
                    -- update free running cycle count
                    carr_cycle_count_u <= carr_cycle_count_u + 1;
                end if;  
                
                if measurement_enable_b_in = '1' then
                    meas_code_NCO_u_out      <= std_logic_vector(resize(code_NCO_reg_u      , REG_WIDTH_C));
                    meas_chip_count_u_out    <= std_logic_vector(resize(code_chip_count_u   , REG_WIDTH_C));
                    meas_epoch_count_u_out   <= std_logic_vector(resize(code_epoch_count_u  , REG_WIDTH_C));
                    meas_carr_NCO_u_out      <= std_logic_vector(resize(carr_NCO_reg_u      , REG_WIDTH_C));
                    meas_cycle_count_u_out   <= std_logic_vector(resize(carr_cycle_count_u  , REG_WIDTH_C));
                    meas_bit_count_u_out     <= std_logic_vector(resize(bit_count_u         , REG_WIDTH_C));
                    meas_sec_count_u_out     <= std_logic_vector(resize(sec_count_u         , REG_WIDTH_C));
                end if;
            
         else
            -- initialise the slave NCO and chip count on master epoch
            if (code_epoch_slave_b_in = '1') then
                -- add the master NCO input to any delay initialised, 
                -- add one increment to account for one sample delay in starting
                code_NCO_reg_u <= code_NCO_reg_u + unsigned(code_NCO_master_u_in)+ unsigned(code_NCO_increment_u_in);
                
                -- check for overflow (due to initialied offset, not from the additional increment) and if so add one to chip count
                if code_NCO_reg_u > (ALL_ONES_NCO_U_C - unsigned(code_NCO_master_u_in) - unsigned(code_NCO_increment_u_in)) then
                    code_chip_count_u <= unsigned(start_chip_u_in) + 1;
                else
                    code_chip_count_u <= unsigned(start_chip_u_in);
                end if; 
            end if;
         end if;   
     end if;
end if;
end process;



-- assign outputs
interrupt_b_out            <= interrupt_reg_b;
accumulation_P_I_reg_s_out <= std_logic_vector(accumulation_P_I_reg_s);
accumulation_P_Q_reg_s_out <= std_logic_vector(accumulation_P_Q_reg_s); 
accumulation_E_I_reg_s_out <= std_logic_vector(accumulation_E_I_reg_s);
accumulation_E_Q_reg_s_out <= std_logic_vector(accumulation_E_Q_reg_s);                    
accumulation_L_I_reg_s_out <= std_logic_vector(accumulation_L_I_reg_s);
accumulation_L_Q_reg_s_out <= std_logic_vector(accumulation_L_Q_reg_s);                    
accumulation_VE_I_reg_s_out <= std_logic_vector(accumulation_VE_I_reg_s);
accumulation_VE_Q_reg_s_out <= std_logic_vector(accumulation_VE_Q_reg_s);                    
accumulation_VL_I_reg_s_out <= std_logic_vector(accumulation_VL_I_reg_s);
accumulation_VL_Q_reg_s_out <= std_logic_vector(accumulation_VL_Q_reg_s);                                       
accm_1ms_P_I_reg_a_s_out <= accm_1ms_P_I_reg_a_s;
accm_1ms_P_Q_reg_a_s_out <= accm_1ms_P_Q_reg_a_s;
code_NCO_master_u_out <= std_logic_vector(code_NCO_reg_u);
code_epoch_master_b_out <= '1' when (code_NCO_reg_u > (ALL_ONES_NCO_U_C - unsigned(code_NCO_increment_u_in))) and                 
           (code_NCO_count_u = (unsigned(fast_nco_count_value_u_in) - 1)) and (code_chip_count_u = (unsigned(code_len_chip_u_in) - 1)) 
           else '0';
--code_NCO_count_master_u_out <= std_logic_vector(code_NCO_count_u);

end Behavioral;
