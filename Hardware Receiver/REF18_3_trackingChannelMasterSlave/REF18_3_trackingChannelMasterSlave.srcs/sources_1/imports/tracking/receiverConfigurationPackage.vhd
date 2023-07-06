--***************************************************************************
--* Copyright - SYDERAL SA
--* Neuenburgstrasse 7
--* CH 3238 Gals
--* Switzerland
--* www.syderal.ch
--*
--***************************************************************************
--* Subsystem:  receiver configuration package 
--* Filename:  receiverConfigurationPackage.vhd   
--* Author: P. BLUNT      
--* Date Created: 30/08/18
--*
--***************************************************************************
--* DESCRIPTION
--*
--* Purpose           : This block contains constant and type definitions for receiver configuration
--*
--* Limitations       : 
--*
--* Dependencies      : 
--*
--* Generics/Constants:
--*
--* Inputs            : 
--*
--* Outputs           :  
--*
--* Functional timing :
--*
--* Errors            : 
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

package receiverConfigurationPackage is

-----------------------------------------------------------------------
-- General
-----------------------------------------------------------------------
-- number of front end inputs   
constant NUM_FE_INPUTS_C : integer := 4;
-- width in bits of front end inputs
constant NUM_FE_BITS_C : integer := 2;
-- number of levels and therefore counters required by front end monitor
constant NUM_LEVELS_C : integer := 2**NUM_FE_BITS_C; 
-- register width
constant REG_WIDTH_C : integer := 32;
-- frequency plan parameters
constant SAMPLE_FREQ_C : integer := 99375000;   --48906250; -- 99375000;
constant IF_CA_E1B_i_C : integer := 14580000;   --10420000; -- 14580000;
-- sample clock periods per measurement TIC

constant SAMPLES_PER_TIC : integer := SAMPLE_FREQ_C; -- 99375000;
-- Timing Unit parameters
constant PP_1MS_INC_C         : integer := 1    ;      -- 1     config 2, 4      config 7
constant PP_1MS_RANGE_C       : integer := 99375;      -- 99375 config 2, 195625 config 7

-- carrier NCO length
constant CARR_NCO_LENGTH_C  : integer := 32;
-- code NCO length
constant CODE_NCO_LENGTH_C  : integer := 32;
-- replica carrier maximum amplitude
constant MAX_CARR_AMP_C     : integer := 2;
-- input maximum amplitude
constant MAX_INPUT_AMP_C    : integer := 3;



constant CODE_FREQ_CA_E1B_i_C    : integer := 1023000;

constant CODE_LENGTH_CA_C        : integer := 1023;
constant CODE_LENGTH_E1B_C       : integer := 4*CODE_LENGTH_CA_C;
constant CODE_LENGTH_E5a_I_C     : integer := 10*CODE_LENGTH_CA_C;

constant SAMPLES_PER_EPOCH_1MS_C : integer := SAMPLE_FREQ_C/1000;
constant SAMPLES_PER_EPOCH_4MS_C : integer := SAMPLE_FREQ_C/250;

constant NT_CHANNEL_1_i_C   : integer := 0;
constant NT_CHANNEL_2_i_C   : integer := 1;
constant NT_CHANNEL_3_i_C   : integer := 2;
constant NT_CHANNEL_4_i_C   : integer := 3;

constant CA_SIGNAL          : integer := 0;
constant E1B_SIGNAL         : integer := 1;
constant E1C_SIGNAL         : integer := 2;
constant L5_I_SIGNAL        : integer := 3;
constant L5_Q_SIGNAL        : integer := 4;
constant E5a_I_SIGNAL       : integer := 5;
constant E5a_Q_SIGNAL       : integer := 6;

constant BYTE_LENGTH_C      : integer := 8;

constant MEAS_COUNT_SIZE_I_C : integer := integer(ceil(log2(real(SAMPLES_PER_TIC))));
 
-- carrier NCO increment to produce 14.58 MHz, increment = freq*(2^NCO_length)/sampling_freq
constant CARR_NCO_INCR_CA_E1B_U_C : unsigned((CARR_NCO_LENGTH_C -1) downto 0) := x"258F3E7B";
-- code NCO increment to produce 1.023 MHz, increment = freq*(2^NCO_length)/sampling_freq 
constant CODE_NCO_INCR_CA_E1B_U_C : unsigned((CODE_NCO_LENGTH_C -1) downto 0) := x"02A2A65C";
-- carrier NCO increment to produce 13.55 MHz, increment = freq*(2^NCO_length)/sampling_freq
constant CARR_NCO_INCR_E5_L5_U_C : unsigned((CARR_NCO_LENGTH_C -1) downto 0) := x"22E7FA55";
-- code NCO increment to produce 10.23 MHz, increment = freq*(2^NCO_length)/sampling_freq 
constant CODE_NCO_INCR_E5_L5_U_C : unsigned((CODE_NCO_LENGTH_C -1) downto 0) := x"1A5A7F98";

constant FE_SELECT_SIZE : integer := integer(ceil(log2(real(NUM_FE_INPUTS_C))));


-- number of master channels 
constant NUM_MASTER_CHAN_I_C :integer := 16;
-- number of slave channels (array, configurable per channel)
constant NUM_SLAVE_CHAN_I_C :integer := 6;
-- total number of tracking channels master + slave
constant MAX_CHAN_I_C :integer := NUM_MASTER_CHAN_I_C + NUM_SLAVE_CHAN_I_C; 
type slave_chan_type is array ((NUM_MASTER_CHAN_I_C - 1) downto 0) of integer range 0 to 3;
constant NUM_SLAVES_A_I_C : slave_chan_type :=(0,0,0,0,0,0,0,0,0,0,0,0,0,3,2,1);


-- front end data array type
type data_FE_type is array ((NUM_FE_INPUTS_C - 1) downto 0) of std_logic_vector((NUM_FE_BITS_C - 1) downto 0);
-- distribution monitor counters
type data_FE_count_type is array ((NUM_FE_INPUTS_C - 1) downto 0,(NUM_LEVELS_C - 1) downto 0) of unsigned((REG_WIDTH_C - 1) downto 0);

-----------------------------------------------------------------------
-- Front End Monitor
-----------------------------------------------------------------------
--constant NOISE_CORR_EPOCHS_CA : integer := 20;
--constant NOISE_CORR_EPOCHS_E1B : integer := 5;
--constant NOISE_CORR_EPOCHS_E5A_I_C : integer := 20;
constant NOISE_CORR_EPOCHS_CA       : integer := 1;
constant NOISE_CORR_EPOCHS_E1B      : integer := 1;
constant NOISE_CORR_EPOCHS_E5A_I_C  : integer := 1;
-----------------------------------------------------------------------
---  AXI FE MON -------------------------------------------------------------
-----------------------------------------------------------------------
constant NUM_NOISE_CORRELATIONS_I_C :integer := 6;
constant NUM_FE_ADDR_I_C :integer := NUM_FE_INPUTS_C*NUM_LEVELS_C; 
constant FE_CONTROL_REGS_I_C : integer := 1;
constant NUM_ADDR_FE_MON_I_C : integer := NUM_FE_ADDR_i_C + NUM_NOISE_CORRELATIONS_i_C + FE_CONTROL_REGS_I_C;
constant AXI_ADDR_SIZE_FE_MON_I_C : integer := integer(ceil(log2(real(NUM_ADDR_FE_MON_i_C))));
constant AXI_ADDR_WIDTH_FE_MON_I_C : integer :=  AXI_ADDR_SIZE_FE_MON_i_C + 2;
constant AXI_NUM_READ_REG_FE_MON_I_C : integer := NUM_ADDR_FE_MON_i_C;
 
constant ADDR_CA_NOISE_I_I_C        : integer := NUM_FE_ADDR_i_C;
constant ADDR_CA_NOISE_Q_I_C        : integer := NUM_FE_ADDR_i_C + 1;
constant ADDR_E1B_NOISE_I_I_C       : integer := NUM_FE_ADDR_i_C + 2;
constant ADDR_E1B_NOISE_Q_I_C       : integer := NUM_FE_ADDR_i_C + 3;
constant ADDR_E5_L5_NOISE_I_I_C     : integer := NUM_FE_ADDR_i_C + 4;
constant ADDR_E5_L5_NOISE_Q_I_C     : integer := NUM_FE_ADDR_i_C + 5;
constant ADDR_INTERRUPT_I_C         : integer := NUM_FE_ADDR_i_C + 6;

type mon_FE_slv_reg_type is array (0 to (AXI_NUM_READ_REG_FE_MON_I_C - 1)) of std_logic_vector((REG_WIDTH_C - 1) downto 0);
-----------------------------------------------------------------------
-- Tracking Channels
-----------------------------------------------------------------------
constant ADDR_BYTES_E5a_I_C : integer := integer(ceil(real(CODE_LENGTH_E5a_I_C/BYTE_LENGTH_C)));
constant ADDR_WORDS_E5a_I_C : integer := integer(ceil(real(CODE_LENGTH_E5a_I_C/REG_WIDTH_C)));
constant ADDR_LEN_E5a_I_C : integer := integer(ceil(log2(real(ADDR_BYTES_E5a_I_C))));
constant ADDR_LEN_WORDS_E5a_I_C : integer := integer(ceil(log2(real(ADDR_WORDS_E5a_I_C))));

constant SIGNAL_TYPE_SIZE_I_C : integer := integer(ceil(log2(real(E5a_Q_SIGNAL))));

-- max_chip count length for correlator
constant MAX_CHIP_COUNT_LENGTH_C        : integer := integer(ceil(log2(real(CODE_LENGTH_E5a_I_C))));
constant MAX_CORR_LEN_MS_I_C : integer := 20;
constant MAX_CORR_LEN_SIZE_I_C : integer := integer(ceil(log2(real(MAX_CORR_LEN_MS_I_C))));
-- code delay size, VE to VL is 1 chip for BOC(1,1)  
constant CODE_DELAY_SIZE_I_C        : integer := integer(ceil(real(SAMPLE_FREQ_C/CODE_FREQ_CA_E1B_i_C)));
constant CODE_DELAY_MID_POINT_I_C   : integer := integer(ceil(real(CODE_DELAY_SIZE_I_C/2)));
constant CODE_DELAY_LEN_I_C         : integer := integer(ceil(log2(real(CODE_DELAY_MID_POINT_I_C))));

-- max_count value for fast NCO (ratio of fastest code rate to slowest) 
constant FAST_NCO_COUNT_MAX_C          : integer := 10;
constant MAX_NCO_COUNT_LENGTH_C        : integer := integer(ceil(log2(real(FAST_NCO_COUNT_MAX_C))));


-- maximum cycle count in measurement epoch
constant MAX_CYCLE_COUNT_I_C : integer := (SAMPLES_PER_TIC / 2);
constant CYCLE_COUNT_SIZE_I_C : integer := integer(ceil(log2(real(MAX_CYCLE_COUNT_I_C))));

constant DEF_CORR_EPOCHS_CA_I_C     : integer   := 20;
constant DEF_CORR_EPOCHS_E1B_I_C    : integer   := 1;
constant MAX_SEC_CODE_LENGTH        : integer   := 250; 
constant SEC_CODE_COUNT_SIZE_C      : integer   := integer(ceil(log2(real(MAX_SEC_CODE_LENGTH))));
constant SEC_COUNTER_WIDTH_C        : integer   := 32;

constant ONE_CHIP_SPACING_CA_E1B_I_C   : integer := integer(ceil(real(CODE_DELAY_MID_POINT_I_C/2)));
-- max value of the full correlation length accumulators
constant ACCUMULATOR_MAX_VALUE_I_C    : integer := MAX_CORR_LEN_MS_I_C * SAMPLES_PER_EPOCH_1MS_C * MAX_INPUT_AMP_C * MAX_CARR_AMP_C;
-- size is double the max value for signed
constant ACCUMULATOR_SIZE_I_C         : integer := integer(ceil(log2(real(2*ACCUMULATOR_MAX_VALUE_I_C))));
-- max value of the 1 ms length accumulators
constant ACCM_1MS_MAX_VALUE_I_C    : integer := MAX_CORR_LEN_MS_I_C * SAMPLES_PER_EPOCH_1MS_C * MAX_INPUT_AMP_C * MAX_CARR_AMP_C;
-- size is double the max value for signed
constant ACC_1MS_SIZE_I_C         : integer := integer(ceil(log2(real(2*ACCM_1MS_MAX_VALUE_I_C))));
constant WORD_ADDR_BITS_I_C : integer := integer(ceil(log2(real(REG_WIDTH_C))));

type accm_1ms_array_type is array ((MAX_CORR_LEN_MS_I_C - 1) downto 0) of std_logic_vector((REG_WIDTH_C - 1) downto 0);

-- channel arrays
type front_end_select_type                  is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((FE_SELECT_SIZE - 1) downto 0);
type RAM_we_type                            is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic; 
type PPS_20ms_type                          is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic;
type start_enable_type                      is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic;
type SW_reset_type                          is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic; 
type signal_type_type                       is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((SIGNAL_TYPE_SIZE_I_C - 1) downto 0);
type start_chip_type                        is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
type start_epoch_type                       is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
type code_len_chip_type                     is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
type code_len_chip_1ms_type                 is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
type carr_NCO_increment_type                is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((CARR_NCO_LENGTH_C - 1) downto 0);
type code_NCO_increment_type                is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((CODE_NCO_LENGTH_C - 1) downto 0);
type early_prompt_spacing_type              is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((CODE_DELAY_LEN_I_C - 1) downto 0);
type very_early_prompt_spacing_type         is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((CODE_DELAY_LEN_I_C - 1) downto 0);
type correlation_length_epochs_type         is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
type epoch_length_ms_type                   is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
type bit_length_type                  is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((SEC_CODE_COUNT_SIZE_C - 1) downto 0);
type accumulation_type                      is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((REG_WIDTH_C -1) downto 0);
type accm_1ms_type                          is array ((MAX_CHAN_I_C - 1) downto 0) of accm_1ms_array_type;
type RAM_do_type                            is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((REG_WIDTH_C -1) downto 0);
type meas_output_reg_type                   is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((REG_WIDTH_C -1) downto 0);
type trk_interrupt_type                     is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic;
type fast_NCO_count_type                    is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector((MAX_NCO_COUNT_LENGTH_C - 1) downto 0);
type master_epoch_type                      is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic;

constant MISS_INT_CNT_SIZE_C  : integer  := 8; 
type miss_interrupt_type is array ((MAX_CHAN_I_C - 1) downto 0) of std_logic_vector(MISS_INT_CNT_SIZE_C - 1 downto 0);
-----------------------------------------------------------------------
---  AXI track channels -----------------------------------------------
-----------------------------------------------------------------------
constant NUM_ADDR_TRACK_I_C             : integer := 80; -- the number of registers
constant AXI_ADDR_SIZE_TRACK_I_C        : integer := integer(ceil(log2(real(NUM_ADDR_TRACK_I_C))));
constant AXI_ADDR_WIDTH_TRACK_I_C       : integer := AXI_ADDR_SIZE_TRACK_i_C + 2;
constant AXI_NUM_READ_REG_TRACK_I_C     : integer := 57;

constant AXI_ADDR_WIDTH_ALL_CHAN_I_C : integer :=  32;

-- offset for channel, minimum needs to be greater than ADDR_LEN_WORDS_E5a_I_C (min. 11 address bits) and greater than AXI_ADDR_WIDTH_TRACK_I_C
-- allow up to 256 registers (min. 10 address bits) 
constant AXI_CHAN_OFFSET_BITS_I_C : integer := 11; -- ADDR_LEN_WORDS_E5a_I_C -1 + 2 + 1
constant AXI_CHAN_ADDR_SIZE_I_C : integer := integer(ceil(log2(real(MAX_CHAN_I_C))));

-- offset for PRN RAM, minimum needs to be greater than ADDR_LEN_WORDS_E5a_I_C and greater than (AXI_CHAN_OFFSET_BITS_I_C + AXI_CHAN_ADDR_SIZE_I_C)
-- allow for up to 128 channels (AXI_CHAN_OFFSET_BITS_I_C + 7 bits)
constant AXI_PRN_OFFSET_BITS_I_C :integer := AXI_CHAN_OFFSET_BITS_I_C + 6;

type track_chan_slv_read_reg_type is array (0 to (NUM_ADDR_TRACK_I_C - 1)) of std_logic_vector((REG_WIDTH_C - 1) downto 0);
type track_chan_slv_write_reg_type is array (0 to (NUM_ADDR_TRACK_I_C - AXI_NUM_READ_REG_TRACK_I_C - 1)) of std_logic_vector((REG_WIDTH_C - 1) downto 0);

-- read registers
constant ADDR_OFFSET_P_I_I_C                    : integer := 0;
constant ADDR_OFFSET_P_Q_I_C                    : integer := 1;
constant ADDR_OFFSET_E_I_I_C                    : integer := 2;
constant ADDR_OFFSET_E_Q_I_C                    : integer := 3;
constant ADDR_OFFSET_L_I_I_C                    : integer := 4;
constant ADDR_OFFSET_L_Q_I_C                    : integer := 5;
constant ADDR_OFFSET_VE_I_I_C                   : integer := 6;
constant ADDR_OFFSET_VE_Q_I_C                   : integer := 7;
constant ADDR_OFFSET_VL_I_I_C                   : integer := 8;
constant ADDR_OFFSET_VL_Q_I_C                   : integer := 9;
constant ADDR_OFFSET_P_I_1ms_array_0_I_C        : integer := 10;
constant ADDR_OFFSET_P_I_1ms_array_1_I_C        : integer := 11;
constant ADDR_OFFSET_P_I_1ms_array_2_I_C        : integer := 12;
constant ADDR_OFFSET_P_I_1ms_array_3_I_C        : integer := 13;
constant ADDR_OFFSET_P_I_1ms_array_4_I_C        : integer := 14;
constant ADDR_OFFSET_P_I_1ms_array_5_I_C        : integer := 15;
constant ADDR_OFFSET_P_I_1ms_array_6_I_C        : integer := 16;
constant ADDR_OFFSET_P_I_1ms_array_7_I_C        : integer := 17;
constant ADDR_OFFSET_P_I_1ms_array_8_I_C        : integer := 18;
constant ADDR_OFFSET_P_I_1ms_array_9_I_C        : integer := 19;
constant ADDR_OFFSET_P_I_1ms_array_10_I_C       : integer := 20;
constant ADDR_OFFSET_P_I_1ms_array_11_I_C       : integer := 21;
constant ADDR_OFFSET_P_I_1ms_array_12_I_C       : integer := 22;
constant ADDR_OFFSET_P_I_1ms_array_13_I_C       : integer := 23;
constant ADDR_OFFSET_P_I_1ms_array_14_I_C       : integer := 24;
constant ADDR_OFFSET_P_I_1ms_array_15_I_C       : integer := 25;
constant ADDR_OFFSET_P_I_1ms_array_16_I_C       : integer := 26;
constant ADDR_OFFSET_P_I_1ms_array_17_I_C       : integer := 27;
constant ADDR_OFFSET_P_I_1ms_array_18_I_C       : integer := 28;
constant ADDR_OFFSET_P_I_1ms_array_19_I_C       : integer := 29;
constant ADDR_OFFSET_P_Q_1ms_array_0_I_C        : integer := 30;
constant ADDR_OFFSET_P_Q_1ms_array_1_I_C        : integer := 31;
constant ADDR_OFFSET_P_Q_1ms_array_2_I_C        : integer := 32;
constant ADDR_OFFSET_P_Q_1ms_array_3_I_C        : integer := 33;
constant ADDR_OFFSET_P_Q_1ms_array_4_I_C        : integer := 34;
constant ADDR_OFFSET_P_Q_1ms_array_5_I_C        : integer := 35;
constant ADDR_OFFSET_P_Q_1ms_array_6_I_C        : integer := 36;
constant ADDR_OFFSET_P_Q_1ms_array_7_I_C        : integer := 37;
constant ADDR_OFFSET_P_Q_1ms_array_8_I_C        : integer := 38;
constant ADDR_OFFSET_P_Q_1ms_array_9_I_C        : integer := 39;
constant ADDR_OFFSET_P_Q_1ms_array_10_I_C       : integer := 40;
constant ADDR_OFFSET_P_Q_1ms_array_11_I_C       : integer := 41;
constant ADDR_OFFSET_P_Q_1ms_array_12_I_C       : integer := 42;
constant ADDR_OFFSET_P_Q_1ms_array_13_I_C       : integer := 43;
constant ADDR_OFFSET_P_Q_1ms_array_14_I_C       : integer := 44;
constant ADDR_OFFSET_P_Q_1ms_array_15_I_C       : integer := 45;
constant ADDR_OFFSET_P_Q_1ms_array_16_I_C       : integer := 46;
constant ADDR_OFFSET_P_Q_1ms_array_17_I_C       : integer := 47;
constant ADDR_OFFSET_P_Q_1ms_array_18_I_C       : integer := 48;
constant ADDR_OFFSET_P_Q_1ms_array_19_I_C       : integer := 49;
constant ADDR_OFFSET_MEAS_CODE_NCO_I_C          : integer := 50;
constant ADDR_OFFSET_MEAS_COUNT_CHIP_I_C        : integer := 51;
constant ADDR_OFFSET_MEAS_EPOCH_COUNT_I_C       : integer := 52;
constant ADDR_OFFSET_MEAS_CARR_NCO_I_C          : integer := 53;
constant ADDR_OFFSET_MEAS_CYCLE_COUNT_I_C       : integer := 54;
constant ADDR_OFFSET_MEAS_BIT_COUNT_I_C         : integer := 55;
constant ADDR_OFFSET_MEAS_SEC_COUNT_I_C         : integer := 56;
-- read/write registers
-- address offset for arming the channel
constant AXI_ARM_CHAN_OFFSET                    : integer := AXI_NUM_READ_REG_TRACK_I_C;
constant ADDR_OFFSET_ARM_TRK_I_C                : integer := AXI_ARM_CHAN_OFFSET;
constant ADDR_OFFSET_FRONT_END_SELECT_I_C       : integer := AXI_NUM_READ_REG_TRACK_I_C + 1;
constant ADDR_OFFSET_RESET_I_C                  : integer := AXI_NUM_READ_REG_TRACK_I_C + 2;
constant ADDR_OFFSET_SIGNAL_TYPE_I_C            : integer := AXI_NUM_READ_REG_TRACK_I_C + 3;
constant ADDR_OFFSET_START_CHIP_I_C             : integer := AXI_NUM_READ_REG_TRACK_I_C + 4;
constant ADDR_OFFSET_START_EPOCH_I_C            : integer := AXI_NUM_READ_REG_TRACK_I_C + 5;
constant ADDR_OFFSET_CODE_LENGTH_I_C            : integer := AXI_NUM_READ_REG_TRACK_I_C + 6;
constant ADDR_OFFSET_CODE_CHIPS_1MS_I_C         : integer := AXI_NUM_READ_REG_TRACK_I_C + 7;
constant ADDR_OFFSET_CARR_NCO_INCR_I_C          : integer := AXI_NUM_READ_REG_TRACK_I_C + 8;
constant ADDR_OFFSET_CODE_NCO_INCR_I_C          : integer := AXI_NUM_READ_REG_TRACK_I_C + 9;
constant ADDR_OFFSET_EARLY_PROMPT_SPACING_I_C   : integer := AXI_NUM_READ_REG_TRACK_I_C + 10;
constant ADDR_OFFSET_VERY_EARLY_PROMPT_SPACING_I_C  : integer := AXI_NUM_READ_REG_TRACK_I_C + 11;
constant ADDR_OFFSET_CORR_LEN_EPOCHS_I_C        : integer := AXI_NUM_READ_REG_TRACK_I_C + 12;
constant ADDR_OFFSET_EPOCH_LEN_MS_I_C           : integer := AXI_NUM_READ_REG_TRACK_I_C + 13;
constant ADDR_OFFSET_CODE_NCO_START_I_C         : integer := AXI_NUM_READ_REG_TRACK_I_C + 14;
constant ADDR_OFFSET_CLR_INTERRUPT_I_C          : integer := AXI_NUM_READ_REG_TRACK_I_C + 15;
constant ADDR_OFFSET_BIT_CODE_LENGTH_I_C        : integer := AXI_NUM_READ_REG_TRACK_I_C + 16;   -- bit/secondary code length
constant ADDR_OFFSET_BIT_ENA_CNT_I_C            : integer := AXI_NUM_READ_REG_TRACK_I_C + 17;   -- clear the bit counter for initial synchrinization
--constant ADDR_OFFSET_SEC_CODE_LENGTH_I_C        : integer := AXI_NUM_READ_REG_TRACK_I_C + 16;   -- bit/secondary code length
constant ADDR_OFFSET_SEC_CODE_PART_1_I_C        : integer := AXI_NUM_READ_REG_TRACK_I_C + 18;
constant ADDR_OFFSET_SEC_CODE_PART_2_I_C        : integer := AXI_NUM_READ_REG_TRACK_I_C + 19;
constant ADDR_OFFSET_SEC_CODE_PART_3_I_C        : integer := AXI_NUM_READ_REG_TRACK_I_C + 20;
constant ADDR_ARM_SLAVE_I_C                     : integer := AXI_NUM_READ_REG_TRACK_I_C + 21;
constant ADDR_FAST_NCO_CNT_MAX_I_C              : integer := AXI_NUM_READ_REG_TRACK_I_C + 22;

-----------------------------------------------------------------------
-- Acquisition  -------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------
--- noise PRNs  -------------------------------------------------------
-----------------------------------------------------------------------
type ca_code_rom_type is array (0 to 127) of std_logic_vector(7 downto 0);
-- this PRN 37, g2 start 950
constant NOISE_CODE_ROM_CA_C : ca_code_rom_type :=(
x"0d",x"21",x"1b",x"f9",x"b6",x"a4",x"e7",x"f5",x"15",x"20",x"e6",x"22",
x"52",x"ce",x"3f",x"38",x"6c",x"1a",x"f1",x"fe",x"c5",x"22",x"8e",x"58",
x"cd",x"d1",x"38",x"d0",x"c1",x"1b",x"36",x"c7",x"39",x"75",x"27",x"11",
x"4d",x"c3",x"65",x"5c",x"0d",x"88",x"f2",x"ae",x"8c",x"9a",x"90",x"4b",
x"da",x"4a",x"fe",x"1c",x"68",x"d1",x"fd",x"d4",x"b8",x"eb",x"e5",x"58",
x"17",x"7e",x"a2",x"2b",x"30",x"de",x"7f",x"a4",x"51",x"89",x"fd",x"44",
x"14",x"85",x"42",x"cc",x"d7",x"f9",x"fc",x"4b",x"a9",x"32",x"6f",x"88",
x"49",x"e9",x"c3",x"dd",x"d5",x"10",x"08",x"14",x"55",x"4a",x"54",x"80",
x"f8",x"85",x"e9",x"b7",x"6e",x"ce",x"39",x"f8",x"75",x"5f",x"ee",x"da",
x"9a",x"31",x"a9",x"3d",x"84",x"25",x"99",x"96",x"64",x"27",x"c4",x"09",
x"f4",x"4e",x"d2",x"6f",x"3b",x"80",x"df",x"86");

type track_code_ram_type is array (0 to ADDR_WORDS_E5a_I_C) of std_logic_vector(0 to 31);
constant CODE_PRN1_ROM_CA_C : track_code_ram_type :=(
x"586D63EC",
x"5675A837",
x"13068665",
x"FF7BAD12",
x"0E84DDA9",
x"0AF90CC4",
x"9D4A9A83",
x"7FBE5750",
x"9D7E473E",
x"782D1B00",
x"E54B1A95",
x"D8E5F189",
x"B84B48F7",
x"AF80B4F9",
x"73305162",
x"89C9559C",
x"464CBFF9",
x"D68A2AFA",
x"4B5D6E30",
x"19E5A5AF",
x"EE9707B3",
x"5A6CC441",
x"13841E00",
x"5BF463CA",
x"181B4380",
x"7F063A09",
x"E5DDD3EA",
x"8EDC3B47",
x"C1986CCA",
x"920A69AC",
x"BDD5E01A",
x"FBAC78DB",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000");


-- this PRN 1, g2 start 5, 32 words then padded to the 320 words for 10230 chips
--constant CODE_PRN1_ROM_CA_C : track_code_ram_type :=(
--x"1bc7c166",x"9034d00b",x"4f774e1c",x"f98f71dc",x"587d2f2d",x"0f1f0723",x"3947f0e5",x"d1b9992c",
--x"fa1db573",x"f55f61f6",x"800454ab",x"ead55edc",x"debdac8f",x"c6ab23e1",x"13f774a3",x"2b66c482",
--x"9f6863d3",x"cb94fda2",x"75a45a4c",x"1f7752d7",x"1626dc14",x"109c5159",x"0cad143e",x"10485c19",
--x"21de94bc",x"334cf9ef",x"02982cc5",x"742f305f",x"61668234",x"96131869",x"19941096",x"b4bf5e67",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",
--x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000",x"00000000");

type e1b_code_rom_type is array (0 to 511) of std_logic_vector(7 downto 0);
-- this PRN 50
constant NOISE_CODE_ROM_E1B_C : e1b_code_rom_type := (
x"97",x"05",x"1F",x"C6",x"7A",x"CA",x"30",x"E8",x"AE",x"E7",x"3D",x"3A",
x"8C",x"F3",x"8B",x"B1",x"35",x"24",x"D4",x"E0",x"EB",x"D9",x"BE",x"68",
x"39",x"8C",x"7C",x"16",x"22",x"7C",x"AB",x"B1",x"D0",x"B0",x"A0",x"AB",
x"E7",x"B6",x"38",x"4A",x"BA",x"02",x"90",x"5B",x"A0",x"C3",x"C7",x"36",
x"35",x"99",x"D0",x"59",x"C7",x"B4",x"C9",x"9D",x"B1",x"65",x"CD",x"14",
x"FA",x"12",x"FA",x"79",x"12",x"44",x"9C",x"A7",x"DD",x"5E",x"34",x"6D",
x"80",x"10",x"C8",x"5A",x"75",x"73",x"82",x"27",x"0D",x"AD",x"15",x"BA",
x"3C",x"E3",x"6A",x"76",x"EF",x"55",x"F8",x"1A",x"1E",x"80",x"BF",x"36",
x"6B",x"37",x"FE",x"3A",x"88",x"EC",x"72",x"20",x"28",x"C2",x"5E",x"23",
x"4E",x"62",x"40",x"40",x"45",x"0A",x"99",x"CD",x"80",x"8F",x"94",x"25",
x"68",x"AA",x"71",x"33",x"98",x"1D",x"72",x"E7",x"F2",x"92",x"88",x"94",
x"67",x"0A",x"D5",x"39",x"94",x"82",x"DF",x"1B",x"90",x"E7",x"E6",x"40",
x"62",x"F8",x"30",x"B7",x"36",x"C7",x"9C",x"30",x"F3",x"62",x"81",x"49",
x"5C",x"76",x"69",x"9C",x"D4",x"84",x"04",x"67",x"3F",x"A3",x"34",x"F0",
x"42",x"F9",x"E0",x"E6",x"7D",x"D7",x"F3",x"85",x"3B",x"F7",x"1A",x"BE",
x"AF",x"6A",x"9A",x"55",x"46",x"85",x"5E",x"84",x"0C",x"E4",x"2B",x"22",
x"4D",x"8F",x"64",x"90",x"C6",x"CE",x"5F",x"C0",x"2E",x"BA",x"F4",x"FF",
x"C3",x"90",x"10",x"70",x"58",x"F5",x"4C",x"D6",x"35",x"D4",x"A7",x"F2",
x"87",x"80",x"99",x"C1",x"EF",x"49",x"57",x"50",x"E6",x"92",x"1B",x"E2",
x"F3",x"9A",x"D8",x"08",x"C4",x"21",x"0F",x"28",x"73",x"19",x"F8",x"11",
x"A2",x"54",x"CE",x"F8",x"CF",x"15",x"3F",x"C5",x"0A",x"B2",x"F3",x"D6",
x"94",x"A5",x"30",x"94",x"9E",x"5F",x"57",x"8D",x"07",x"5D",x"B9",x"6D",
x"DC",x"F2",x"BB",x"90",x"ED",x"3D",x"E0",x"9D",x"9C",x"A8",x"E0",x"86",
x"62",x"FD",x"89",x"82",x"74",x"1D",x"E1",x"CE",x"0A",x"6B",x"64",x"C3",
x"D3",x"D5",x"00",x"4B",x"5C",x"04",x"B2",x"B0",x"DF",x"D9",x"76",x"A2",
x"0F",x"AC",x"C9",x"4D",x"17",x"62",x"D4",x"1E",x"E0",x"3B",x"40",x"D2",
x"CF",x"36",x"76",x"12",x"81",x"2E",x"F4",x"CC",x"41",x"D1",x"BF",x"E9",
x"CE",x"B5",x"1A",x"E3",x"A2",x"2A",x"F1",x"BE",x"7B",x"85",x"A0",x"57",
x"D3",x"04",x"8D",x"0E",x"73",x"FA",x"0F",x"DA",x"F1",x"11",x"9E",x"FD",
x"76",x"F0",x"A4",x"1B",x"E6",x"31",x"28",x"B2",x"2D",x"64",x"A5",x"55",
x"3E",x"95",x"49",x"D4",x"11",x"48",x"3B",x"BC",x"A1",x"48",x"3E",x"F3",
x"0C",x"F6",x"A6",x"D3",x"17",x"AD",x"2C",x"79",x"73",x"EF",x"A6",x"D4",
x"C1",x"12",x"1F",x"70",x"3D",x"2F",x"48",x"FC",x"DA",x"31",x"77",x"AD",
x"45",x"0D",x"75",x"D2",x"A2",x"8D",x"2C",x"24",x"4A",x"EA",x"13",x"F0",
x"E6",x"0A",x"EE",x"D8",x"AC",x"BA",x"B4",x"44",x"D4",x"00",x"DF",x"5E",
x"28",x"0D",x"B7",x"99",x"B2",x"D9",x"A9",x"84",x"DF",x"1E",x"25",x"67",
x"D3",x"9D",x"1D",x"E5",x"8E",x"F7",x"8C",x"A6",x"B4",x"D8",x"BC",x"17",
x"2B",x"07",x"DC",x"B0",x"2D",x"15",x"6C",x"A9",x"6E",x"EF",x"AC",x"69",
x"E5",x"56",x"CF",x"CE",x"0A",x"AB",x"61",x"7C",x"7F",x"BB",x"8C",x"34",
x"87",x"1C",x"1D",x"35",x"E7",x"4B",x"7B",x"D3",x"07",x"D3",x"F2",x"E4",
x"24",x"C7",x"A9",x"AD",x"67",x"6A",x"1A",x"69",x"E0",x"FE",x"73",x"5E",
x"A5",x"08",x"87",x"A1",x"DF",x"AE",x"6C",x"A2",x"FE",x"44",x"60",x"FC",
x"7E",x"F3",x"23",x"AD",x"E4",x"93",x"02",x"00");

type e5_i_code_rom_type is array (0 to 1278) of std_logic_vector(7 downto 0);
-- this PRN 50
constant NOISE_CODE_ROM_E5_I_C : e5_i_code_rom_type := (
x"A5",x"02",x"9C",x"9E",x"B4",x"62",x"32",x"26",x"D3",x"21",x"FF",x"78",
x"D3",x"C4",x"EA",x"B1",x"F6",x"72",x"A8",x"B2",x"B2",x"4A",x"09",x"CA",
x"EF",x"21",x"F5",x"61",x"A8",x"51",x"32",x"3C",x"05",x"A3",x"C5",x"E1",
x"36",x"A2",x"DA",x"71",x"04",x"ED",x"19",x"FB",x"FF",x"CA",x"C3",x"FC",
x"49",x"B6",x"D5",x"98",x"F3",x"06",x"0E",x"93",x"55",x"2E",x"A6",x"C7",
x"00",x"B8",x"37",x"F7",x"CE",x"04",x"72",x"19",x"19",x"B9",x"C9",x"6A",
x"57",x"B4",x"2A",x"A1",x"D8",x"32",x"30",x"7C",x"7A",x"84",x"70",x"91",
x"84",x"80",x"66",x"CB",x"84",x"94",x"7B",x"E5",x"F6",x"B5",x"46",x"54",
x"47",x"9E",x"39",x"F6",x"54",x"81",x"9D",x"3E",x"F7",x"AF",x"49",x"39",
x"FB",x"9F",x"4C",x"9B",x"20",x"CA",x"7F",x"83",x"DA",x"0F",x"DA",x"2F",
x"17",x"1F",x"DB",x"72",x"45",x"5B",x"7E",x"D0",x"D4",x"32",x"06",x"99",
x"25",x"20",x"CD",x"D8",x"6B",x"29",x"C4",x"8B",x"CC",x"68",x"75",x"73",
x"AA",x"C4",x"21",x"7D",x"0B",x"7D",x"CF",x"85",x"28",x"11",x"AD",x"C3",
x"EC",x"AD",x"DB",x"2B",x"34",x"B4",x"57",x"26",x"75",x"CC",x"AE",x"FD",
x"AA",x"A0",x"1F",x"83",x"56",x"1E",x"6E",x"24",x"08",x"78",x"F2",x"29",
x"69",x"81",x"85",x"A8",x"0E",x"6F",x"EC",x"EE",x"89",x"45",x"5A",x"72",
x"A3",x"77",x"C2",x"4C",x"E3",x"FE",x"CA",x"EC",x"2A",x"34",x"B9",x"CA",
x"98",x"D2",x"88",x"59",x"6D",x"1C",x"76",x"9C",x"DE",x"AB",x"06",x"87",
x"13",x"16",x"CA",x"7D",x"1D",x"DC",x"58",x"62",x"E6",x"28",x"2D",x"EC",
x"E3",x"3F",x"36",x"2C",x"64",x"A7",x"3E",x"57",x"AB",x"26",x"67",x"15",
x"06",x"89",x"32",x"EC",x"C3",x"1E",x"62",x"AD",x"2E",x"CF",x"F7",x"C6",
x"FB",x"FE",x"21",x"33",x"84",x"DA",x"08",x"6A",x"DF",x"49",x"E3",x"0F",
x"43",x"2E",x"E2",x"C7",x"15",x"D9",x"AC",x"4D",x"EF",x"53",x"A7",x"B0",
x"9B",x"0D",x"72",x"2C",x"AC",x"56",x"0F",x"E8",x"CF",x"00",x"59",x"B8",
x"04",x"28",x"45",x"82",x"82",x"F7",x"E8",x"17",x"17",x"64",x"7D",x"72",
x"E3",x"21",x"A3",x"E4",x"BE",x"F1",x"6F",x"AE",x"F7",x"60",x"09",x"BD",
x"98",x"B8",x"D9",x"82",x"2B",x"77",x"1E",x"B6",x"2F",x"1D",x"07",x"48",
x"E4",x"62",x"FB",x"7F",x"3B",x"EE",x"9B",x"12",x"AA",x"86",x"D9",x"62",
x"90",x"85",x"AE",x"DF",x"8E",x"43",x"E1",x"25",x"2E",x"E5",x"99",x"70",
x"CF",x"F6",x"6A",x"6F",x"86",x"5C",x"76",x"51",x"EF",x"83",x"F8",x"FE",
x"10",x"EB",x"0E",x"26",x"15",x"BF",x"8F",x"5C",x"7F",x"12",x"FC",x"60",
x"1B",x"0C",x"F7",x"95",x"C0",x"D8",x"B7",x"05",x"7F",x"54",x"40",x"8B",
x"EF",x"F8",x"67",x"47",x"C0",x"F6",x"F2",x"3E",x"F2",x"12",x"A9",x"08",
x"6E",x"AD",x"D4",x"64",x"A2",x"53",x"41",x"AB",x"71",x"FB",x"A4",x"AD",
x"ED",x"8F",x"59",x"9C",x"38",x"FC",x"15",x"E7",x"90",x"A5",x"B8",x"6E",
x"64",x"97",x"7C",x"5A",x"C7",x"18",x"DD",x"0B",x"47",x"C1",x"A4",x"76",
x"AC",x"9D",x"73",x"69",x"39",x"61",x"44",x"F6",x"28",x"8E",x"84",x"F7",
x"FF",x"BD",x"E0",x"2E",x"C0",x"0E",x"EA",x"E8",x"ED",x"41",x"5C",x"84",
x"64",x"83",x"64",x"EC",x"BE",x"C4",x"21",x"64",x"51",x"4D",x"3E",x"26",
x"BF",x"D3",x"18",x"7E",x"06",x"41",x"C2",x"16",x"FF",x"C5",x"7E",x"00",
x"DD",x"75",x"2C",x"DA",x"58",x"16",x"86",x"91",x"62",x"21",x"DC",x"D1",
x"AF",x"07",x"58",x"23",x"91",x"C5",x"FB",x"EF",x"04",x"7F",x"D1",x"B7",
x"B9",x"56",x"B4",x"58",x"DE",x"92",x"5C",x"02",x"A7",x"56",x"FE",x"19",
x"72",x"33",x"E0",x"30",x"4D",x"0E",x"03",x"4F",x"F9",x"A1",x"76",x"B5",
x"B3",x"F5",x"FB",x"68",x"3A",x"B4",x"1D",x"26",x"91",x"E1",x"3F",x"97",
x"B3",x"F4",x"EB",x"33",x"23",x"88",x"51",x"33",x"11",x"97",x"C4",x"9C",
x"60",x"23",x"32",x"32",x"DA",x"0E",x"26",x"10",x"43",x"04",x"61",x"87",
x"6F",x"F6",x"F7",x"7F",x"F3",x"CC",x"AF",x"1B",x"B2",x"42",x"4B",x"8B",
x"34",x"75",x"88",x"66",x"7B",x"48",x"48",x"04",x"76",x"D4",x"0B",x"D9",
x"E4",x"87",x"46",x"8C",x"D5",x"AF",x"EB",x"59",x"7C",x"75",x"0A",x"5E",
x"66",x"5B",x"4E",x"7C",x"4C",x"16",x"9E",x"D0",x"8A",x"DF",x"C7",x"31",
x"FE",x"A9",x"28",x"05",x"2C",x"4F",x"B8",x"5B",x"30",x"64",x"EC",x"07",
x"B0",x"CB",x"98",x"8E",x"32",x"48",x"93",x"B3",x"F0",x"84",x"29",x"1D",
x"96",x"44",x"03",x"F0",x"35",x"0B",x"7E",x"1B",x"06",x"DF",x"B7",x"33",
x"62",x"C3",x"83",x"18",x"B7",x"62",x"A9",x"72",x"97",x"2B",x"FB",x"76",
x"CC",x"5C",x"08",x"B5",x"D4",x"7D",x"BA",x"0F",x"3A",x"24",x"73",x"D7",
x"74",x"9D",x"E9",x"F4",x"9F",x"50",x"C4",x"C1",x"62",x"0A",x"9E",x"E9",
x"FE",x"56",x"29",x"61",x"24",x"D7",x"29",x"06",x"49",x"74",x"11",x"DB",
x"87",x"D4",x"D8",x"EC",x"4E",x"1F",x"79",x"BE",x"F2",x"72",x"32",x"00",
x"8A",x"22",x"99",x"F5",x"31",x"7F",x"C1",x"A6",x"F4",x"55",x"F1",x"B8",
x"27",x"F1",x"71",x"2B",x"C0",x"18",x"14",x"F0",x"B9",x"D0",x"CC",x"16",
x"2B",x"25",x"B8",x"04",x"27",x"8B",x"9C",x"7B",x"C5",x"FC",x"56",x"16",
x"B3",x"17",x"F2",x"05",x"02",x"34",x"A7",x"AF",x"92",x"FE",x"35",x"A5",
x"9E",x"22",x"C9",x"59",x"C7",x"16",x"3D",x"FA",x"5F",x"14",x"20",x"22",
x"BE",x"5C",x"C4",x"D5",x"EF",x"16",x"D2",x"18",x"21",x"6C",x"57",x"C2",
x"E2",x"9D",x"A9",x"26",x"43",x"6C",x"00",x"DC",x"B8",x"2E",x"68",x"E1",
x"6C",x"A5",x"A0",x"71",x"58",x"D8",x"B8",x"86",x"4D",x"38",x"A7",x"65",
x"D1",x"4E",x"82",x"17",x"51",x"14",x"A2",x"8C",x"D9",x"7D",x"11",x"D5",
x"64",x"C8",x"C7",x"B8",x"74",x"11",x"58",x"9A",x"4F",x"BD",x"49",x"F9",
x"90",x"0D",x"08",x"93",x"9B",x"7A",x"73",x"B5",x"E6",x"46",x"6B",x"6F",
x"60",x"7F",x"8A",x"D2",x"21",x"20",x"A5",x"59",x"A0",x"2B",x"FC",x"EF",
x"64",x"56",x"E7",x"AE",x"CE",x"8C",x"9B",x"7C",x"9D",x"2B",x"32",x"2D",
x"21",x"97",x"12",x"4C",x"05",x"36",x"3B",x"2C",x"BF",x"A5",x"8B",x"74",
x"CD",x"88",x"87",x"7F",x"22",x"A5",x"E5",x"C2",x"02",x"FC",x"2C",x"33",
x"53",x"11",x"25",x"F1",x"51",x"8F",x"4F",x"0F",x"38",x"FA",x"78",x"8E",
x"5E",x"6B",x"33",x"07",x"A7",x"5E",x"C7",x"3E",x"54",x"53",x"91",x"CE",
x"A2",x"00",x"24",x"3D",x"D6",x"D2",x"5A",x"5B",x"86",x"54",x"A0",x"0B",
x"82",x"BA",x"57",x"43",x"7B",x"F0",x"AC",x"CB",x"0E",x"D3",x"7E",x"D2",
x"FE",x"D2",x"21",x"E5",x"4E",x"C1",x"2B",x"93",x"AF",x"A6",x"E3",x"93",
x"92",x"23",x"59",x"60",x"75",x"F4",x"C4",x"73",x"40",x"35",x"5D",x"72",
x"22",x"A8",x"23",x"4A",x"1F",x"65",x"ED",x"DA",x"42",x"FF",x"F5",x"D1",
x"9F",x"7F",x"AC",x"BF",x"09",x"AA",x"77",x"E7",x"96",x"2F",x"4C",x"FB",
x"F6",x"1A",x"0F",x"26",x"FB",x"18",x"E3",x"1A",x"50",x"4B",x"37",x"17",
x"14",x"04",x"88",x"74",x"BE",x"B2",x"86",x"AF",x"F7",x"1B",x"43",x"E4",
x"73",x"9A",x"17",x"E8",x"AC",x"25",x"FA",x"77",x"12",x"1A",x"BB",x"E6",
x"E9",x"97",x"54",x"AF",x"42",x"F1",x"D0",x"02",x"1E",x"A1",x"E3",x"FF",
x"08",x"8D",x"07",x"34",x"BB",x"19",x"1F",x"91",x"A5",x"20",x"C9",x"6E",
x"22",x"B4",x"A2",x"8F",x"9A",x"2B",x"D7",x"DF",x"81",x"E8",x"07",x"9E",
x"E5",x"D0",x"DD",x"CB",x"D5",x"17",x"04",x"6F",x"12",x"09",x"8F",x"AF",
x"69",x"20",x"E0",x"EB",x"A1",x"0D",x"E8",x"CF",x"B3",x"91",x"C6",x"3C",
x"60",x"D6",x"2C",x"1F",x"4B",x"B2",x"6B",x"F8",x"B6",x"E4",x"21",x"A8",
x"30",x"57",x"57",x"31",x"F6",x"7D",x"30",x"6C",x"EB",x"5D",x"6F",x"F0",
x"46",x"37",x"14",x"47",x"90",x"EC",x"4A",x"A2",x"F4",x"35",x"90",x"63",
x"20",x"11",x"4C",x"B8",x"1E",x"B4",x"0C",x"22",x"B2",x"71",x"FB",x"B0",
x"65",x"47",x"46",x"87",x"AA",x"58",x"80",x"F1",x"DB",x"AA",x"A1",x"74",
x"4A",x"B3",x"E9",x"B8",x"31",x"A9",x"32",x"A9",x"20",x"8B",x"EA",x"9F",
x"5D",x"52",x"6C",x"52",x"F5",x"FD",x"A5",x"63",x"20",x"E1",x"23",x"CF",
x"B5",x"53",x"E2",x"B7",x"1A",x"59",x"5D",x"DE",x"D2",x"EC",x"BB",x"D6",
x"E8",x"90",x"B0",x"42",x"1D",x"76",x"5D",x"2E",x"9F",x"D0",x"D3",x"99",
x"5D",x"F2",x"A9",x"52",x"3A",x"65",x"FE",x"20",x"40",x"71",x"0D",x"F1",
x"6F",x"2A",x"83",x"F5",x"10",x"DC",x"A0",x"84",x"93",x"DC",x"13",x"85",
x"41",x"E5",x"68",x"1B",x"51",x"EE",x"87",x"D8",x"4C",x"9A",x"C1",x"16",
x"12",x"EB",x"5C",x"06",x"F5",x"A6",x"3E",x"22",x"BD",x"62",x"75",x"E3",
x"52",x"16",x"76",x"6D",x"79",x"B2",x"15",x"DB",x"D0",x"87",x"E9",x"CA",
x"DA",x"0C",x"EB",x"09",x"BF",x"E4",x"35",x"DF",x"9B",x"78",x"09",x"A7",
x"6D",x"E3",x"23",x"B3",x"73",x"68",x"2B",x"8C",x"58",x"CB",x"4F",x"08",
x"D9",x"C7",x"08",x"EB",x"05",x"0D",x"EC");

-------------------------------------------
-- TIMING UNIT
-------------------------------------------
-- write registers 
constant TIMING_UNIT_RST_ADDR_C      : integer := 0;
constant TIMING_UNIT_CTRL_ADDR_C     : integer := 1;
-- read only registers
constant TIMING_UNIT_ELAP_ADDR_C     : integer := 2;
constant TIMING_UNIT_SEC_CNT_ADDR_C     : integer := 3;

-- size
constant NUMBER_WRITE_REG_C          : integer := 2;
constant NUMBER_READ_ONLY_REG_C      : integer := 2;       
       
constant TIMING_UNIT_REG_WIDTH_C     : integer := 32;
constant TIMING_UNIT_ADDR_WIDTH_C    : integer :=  4;

type tu_read_only_reg_type   is array (0 to (NUMBER_READ_ONLY_REG_C - 1)) of std_logic_vector((REG_WIDTH_C - 1) downto 0);
type tu_write_reg_type       is array (0 to (NUMBER_WRITE_REG_C - 1)) of std_logic_vector((REG_WIDTH_C - 1) downto 0);

------------------------------------------
-- DMA system
------------------------------------------
constant c_NUMBER_OF_TRACKERS    : integer range 1 to MAX_CHAN_I_C:= MAX_CHAN_I_C;
-- number of measurements to send to Nav RAM 1
constant c_VECTORS_PER_TRACKER   : integer range 1 to 16          := 7;--5;

constant c_spidma_start_addr     : std_logic_vector(31 downto 0)  := x"00000000";
constant c_cpudma_start_addr     : std_logic_vector(31 downto 0)  := x"00000000";

--type tracker_reg_array is array (c_NUMBER_OF_TRACKERS-1 downto 0) of std_logic_vector(REG_WIDTH_C-1 DOWNTO 0);
type vector_result_array is array (c_VECTORS_PER_TRACKER-1   downto 0) of std_logic_vector(REG_WIDTH_C-1 DOWNTO 0);
type meas_result_array   is array (c_NUMBER_OF_TRACKERS-1    downto 0) of vector_result_array;

constant tracker_acc_size : integer := 2*MAX_CORR_LEN_MS_I_C+10 ;     -- Number of 32-bit words of acculation data per single tracker
-- reminder type accm_1ms_array_type is array ((MAX_CORR_LEN_MS_I_C - 1) downto 0) of std_logic_vector((REG_WIDTH_C - 1) downto 0);
type accm_1ms_result_array  is array (c_NUMBER_OF_TRACKERS-1    downto 0)  of accm_1ms_array_type;
type vector_acc_array       is array (tracker_acc_size-1        downto 0)  of std_logic_vector(REG_WIDTH_C-1 DOWNTO 0);
type acc_result_array       is array (c_NUMBER_OF_TRACKERS-1    downto 0)  of vector_acc_array;


end;
