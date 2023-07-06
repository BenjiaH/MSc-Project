----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.11.2018 08:05:40
-- Design Name: 
-- Module Name: trackingChannelTB - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.receiverConfigurationPackage.all;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trackingChannelTB is
--  Port ( );
end trackingChannelTB;

architecture Behavioral of trackingChannelTB is

signal areset_n_b_in                   : STD_LOGIC;  
signal sample_clk_b_in                 : STD_LOGIC;
signal data_FE_sync_u_in               : data_FE_type;
signal front_end_select_u_in           : std_logic_vector((FE_SELECT_SIZE - 1) downto 0);
signal RAM_we_b_in                     : std_logic; 
signal RAM_en_b_in                     : std_logic;
signal RAM_addr_u_in                   : std_logic_vector((ADDR_LEN_WORDS_E5a_I_C - 1) downto 0); 
signal RAM_di_u_in                     : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  PPS_20ms_b_in                   : std_logic;
signal  start_enable_b_in               : std_logic;
signal  SW_reset_in                     : std_logic; 
signal  signal_type_u_in                : std_logic_vector((SIGNAL_TYPE_SIZE_I_C - 1) downto 0);
signal  start_chip_u_in                 : std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
signal start_epoch_u_in                : std_logic_vector((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
signal  code_len_chip_u_in              : std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
signal code_len_chip_1ms_u_in          : std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
signal  carr_NCO_increment_u_in         : std_logic_vector((CARR_NCO_LENGTH_C - 1) downto 0);
signal  code_NCO_increment_u_in         : std_logic_vector((CODE_NCO_LENGTH_C - 1) downto 0);
signal  early_prompt_spacing_u_in       : std_logic_vector((CODE_DELAY_LEN_I_C - 1) downto 0);
signal  very_early_prompt_spacing_u_in  : std_logic_vector((CODE_DELAY_LEN_I_C - 1) downto 0);
signal  correlation_length_epochs_u_in  : std_logic_vector((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
signal epoch_length_ms_u_in            : std_logic_vector((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
signal  accumulation_P_I_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  accumulation_P_Q_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  accumulation_E_I_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  accumulation_E_Q_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  accumulation_L_I_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  accumulation_L_Q_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  accumulation_VE_I_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  accumulation_VE_Q_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  accumulation_VL_I_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal  accumulation_VL_Q_reg_s_out        : std_logic_vector((REG_WIDTH_C -1) downto 0);  
signal accm_1ms_P_I_reg_a_s_out           : accm_1ms_array_type;
signal accm_1ms_P_Q_reg_a_s_out           : accm_1ms_array_type;
signal RAM_do_u_out                     : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal meas_code_NCO_u_out             : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal meas_chip_count_u_out           : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal meas_epoch_count_u_out          : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal meas_carr_NCO_u_out             : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal meas_cycle_count_u_out          : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal measurement_enable_b_in          : std_logic;
signal measurement_count_u              : unsigned((MEAS_COUNT_SIZE_I_C -1) downto 0);

begin

uut : entity work.trackingChannel
    generic map(    enable_BOC_bool_g => true)
    port map(       areset_n_b_in       => areset_n_b_in,
    
                    sample_clk_b_in     => sample_clk_b_in,
                    data_FE_sync_u_in   => data_FE_sync_u_in,
                    front_end_select_u_in => front_end_select_u_in,
                    RAM_we_b_in         => RAM_we_b_in,
                    RAM_en_b_in         => RAM_en_b_in,
                    RAM_addr_u_in       => RAM_addr_u_in,
                    RAM_di_u_in         => RAM_di_u_in,
                    PPS_20ms_b_in       => PPS_20ms_b_in,
                    start_enable_b_in               => start_enable_b_in,
                    SW_reset_in                     => SW_reset_in, 
                    signal_type_u_in                => signal_type_u_in,
                    start_epoch_u_in                => start_epoch_u_in,
                    start_chip_u_in                 => start_chip_u_in,
                    code_len_chip_u_in              => code_len_chip_u_in ,
                    code_len_chip_1ms_u_in          => code_len_chip_1ms_u_in,
                    carr_NCO_increment_u_in         => carr_NCO_increment_u_in,
                    code_NCO_increment_u_in         => code_NCO_increment_u_in,
                    early_prompt_spacing_u_in       => early_prompt_spacing_u_in ,
                    very_early_prompt_spacing_u_in  => very_early_prompt_spacing_u_in,
                    correlation_length_epochs_u_in  => correlation_length_epochs_u_in,
                    epoch_length_ms_u_in            => epoch_length_ms_u_in,
                    measurement_enable_b_in         => measurement_enable_b_in,
                    accumulation_P_I_reg_s_out      => accumulation_P_I_reg_s_out,
                    accumulation_P_Q_reg_s_out      => accumulation_P_Q_reg_s_out,
                    accumulation_E_I_reg_s_out      => accumulation_E_I_reg_s_out,
                    accumulation_E_Q_reg_s_out      => accumulation_E_Q_reg_s_out,
                    accumulation_L_I_reg_s_out      => accumulation_L_I_reg_s_out,
                    accumulation_L_Q_reg_s_out      => accumulation_L_Q_reg_s_out,
                    accumulation_VE_I_reg_s_out     => accumulation_VE_I_reg_s_out,
                    accumulation_VE_Q_reg_s_out     => accumulation_VE_Q_reg_s_out,
                    accumulation_VL_I_reg_s_out     => accumulation_VL_I_reg_s_out,
                    accumulation_VL_Q_reg_s_out     => accumulation_VL_Q_reg_s_out,
                    accm_1ms_P_I_reg_a_s_out        => accm_1ms_P_I_reg_a_s_out, 
                    accm_1ms_P_Q_reg_a_s_out        => accm_1ms_P_Q_reg_a_s_out,
                    RAM_do_u_out                    => RAM_do_u_out,
                    meas_code_NCO_u_out             => meas_code_NCO_u_out,
                    meas_chip_count_u_out           => meas_chip_count_u_out,
                    meas_epoch_count_u_out          => meas_epoch_count_u_out,
                    meas_carr_NCO_u_out             => meas_carr_NCO_u_out,
                    meas_cycle_count_u_out          => meas_cycle_count_u_out                                 
             );


clock_gen : PROCESS -- clock process for sample_clk_b_in,
	BEGIN
		CLOCK_LOOP : LOOP
		  sample_clk_b_in <= '1';
		WAIT FOR 5031 ps;
		  sample_clk_b_in <= '0';
		WAIT FOR 5031 ps;
		END LOOP CLOCK_LOOP;
END PROCESS clock_gen;

tb : PROCESS
BEGIN
    -- asignments		
    areset_n_b_in <= '0';
    front_end_select_u_in <= (others => '0');
    RAM_we_b_in <= '0';
    RAM_en_b_in <= '0';
    RAM_addr_u_in <= (others => '0');
    RAM_di_u_in <= (others => '0');
    PPS_20ms_b_in <= '0';
    start_enable_b_in <= '0';
    SW_reset_in <= '1';
    start_epoch_u_in <= (others => '0');
    signal_type_u_in <= std_logic_vector(to_unsigned(CA_SIGNAL,SIGNAL_TYPE_SIZE_I_C));
    start_chip_u_in <= (others => '0');
    -- C/A code settings 
    code_len_chip_1ms_u_in <= std_logic_vector(to_unsigned(CODE_LENGTH_CA_C, MAX_CHIP_COUNT_LENGTH_C));
    code_len_chip_u_in <= std_logic_vector(to_unsigned(CODE_LENGTH_CA_C, MAX_CHIP_COUNT_LENGTH_C));
    carr_NCO_increment_u_in <= std_logic_vector(CARR_NCO_INCR_CA_E1B_U_C);
    code_NCO_increment_u_in <= std_logic_vector(CODE_NCO_INCR_CA_E1B_U_C);
    early_prompt_spacing_u_in <= std_logic_vector(to_unsigned(ONE_CHIP_SPACING_CA_E1B_I_C, CODE_DELAY_LEN_I_C));
    very_early_prompt_spacing_u_in <= std_logic_vector(to_unsigned(ONE_CHIP_SPACING_CA_E1B_I_C, CODE_DELAY_LEN_I_C));
    correlation_length_epochs_u_in <= std_logic_vector(to_unsigned(DEF_CORR_EPOCHS_CA_I_C, MAX_CORR_LEN_SIZE_I_C));
    epoch_length_ms_u_in <= std_logic_vector(to_unsigned(DEF_CORR_EPOCHS_CA_I_C, MAX_CORR_LEN_SIZE_I_C));
    
    --global reset
    wait for 2500 ns;
    areset_n_b_in <= '1';
    wait for 2500 ns;
    SW_reset_in <= '0';
    wait for 2500 ns;
    start_enable_b_in <= '1';
    wait for 2500 ns;
    PPS_20ms_b_in <= '1';
    wait for 10062 ps; -- one clock
    PPS_20ms_b_in <= '0';
    
    wait for 21 ms;
    -- reset correlator to E1 
    SW_reset_in <= '1';
    signal_type_u_in <= std_logic_vector(to_unsigned(E1B_SIGNAL,SIGNAL_TYPE_SIZE_I_C));
    code_len_chip_1ms_u_in <= std_logic_vector(to_unsigned(CODE_LENGTH_CA_C, MAX_CHIP_COUNT_LENGTH_C));
    code_len_chip_u_in <= std_logic_vector(to_unsigned(CODE_LENGTH_E1B_C, MAX_CHIP_COUNT_LENGTH_C));
    correlation_length_epochs_u_in <= std_logic_vector(to_unsigned(DEF_CORR_EPOCHS_E1B_I_C, MAX_CORR_LEN_SIZE_I_C));
    epoch_length_ms_u_in <= std_logic_vector(to_unsigned(4, MAX_CORR_LEN_SIZE_I_C));
    wait for 2500 ns;
    SW_reset_in <= '0';
    wait for 2500 ns;
    start_enable_b_in <= '1';
    wait for 2500 ns;
    PPS_20ms_b_in <= '1';
    wait for 10062 ps; -- one clock
    PPS_20ms_b_in <= '0';
    
    wait for 9 ms;
    
    wait; -- will wait forever
end process;

  read_data_input :  process (sample_clk_b_in, areset_n_b_in) is
    use STD.TEXTIO.all;
--  file F: TEXT is in "quantised_noise_fs_99p375_MHz_0p1_s.txt";  -- VHDL'87
    file F: TEXT open READ_MODE is "quantised_noise_fs_99p375_MHz_0p1_s.txt";
    variable L: LINE;
    variable value: integer;
 begin
    if (areset_n_b_in = '0') then
        data_FE_sync_u_in <= (others => (others => '0'));
        measurement_enable_b_in <= '0';
        measurement_count_u <= (others => '0');
    elsif rising_edge(sample_clk_b_in) then
        READLINE (F, L);
        READ (L, value);
        for i in 0 to (NUM_FE_INPUTS_C-1) loop
            if value = 3 then
                data_FE_sync_u_in(i) <=  "01";
            elsif value = 1 then
                data_FE_sync_u_in(i) <=  "00";
            elsif value = -1 then
                data_FE_sync_u_in(i) <=  "10"; 
            else
                data_FE_sync_u_in(i) <=  "11";
            end if;
        end loop;
        -- create a faster measurement TIC than 0.1 s
        if (measurement_count_u = (SAMPLES_PER_EPOCH_1MS_C)) then
            measurement_count_u <= (others => '0');
            measurement_enable_b_in <= '1';
        else
            measurement_count_u <= measurement_count_u + 1;
            measurement_enable_b_in <= '0';
        end if;
    end if;
    
  end process read_data_input;
end Behavioral;
