----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.11.2018 10:26:54
-- Design Name: 
-- Module Name: trackingChannelInterface - Behavioral
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


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trackingChannelInterface is
    generic(    C_S_AXI_DATA_WIDTH	            : integer	:= REG_WIDTH_C;
                AXI_addr_width_all_chan_i_g     : integer   := AXI_ADDR_WIDTH_ALL_CHAN_I_C );
    Port (      
                sample_clk_b_in                 : in std_logic;
                data_FE_sync_u_in               : in data_FE_type;
                measurement_enable_b_in         : in std_logic;
                PP20ms_b_in                     : in std_logic;
                interrupt_a_u_out               : out trk_interrupt_type;
                snapshot_a_out                  : out trk_interrupt_type;
                -- measurement to DMA Nav
                meas_code_NCO_a_u_out           : out meas_output_reg_type;
                meas_chip_count_a_u_out         : out meas_output_reg_type;
                meas_epoch_count_a_u_out        : out meas_output_reg_type;
                meas_carr_NCO_a_u_out           : out meas_output_reg_type;
                meas_cycle_count_a_u_out        : out meas_output_reg_type;
                meas_bit_count_a_u_out          : out meas_output_reg_type;
                meas_sec_count_a_u_out          : out meas_output_reg_type;                      
                -- Ports of Axi Slave Bus Interface S_AXI
                s_axi_aclk          : in std_logic;
                s_axi_aresetn       : in std_logic;
                s_axi_awaddr        : in std_logic_vector(AXI_addr_width_all_chan_i_g-1 downto 0);
                s_axi_awprot        : in std_logic_vector(2 downto 0);
                s_axi_awvalid       : in std_logic;
                s_axi_awready       : out std_logic;
                s_axi_wdata         : in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
                s_axi_wstrb         : in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
                s_axi_wvalid        : in std_logic;
                s_axi_wready        : out std_logic;
                s_axi_bresp         : out std_logic_vector(1 downto 0);
                s_axi_bvalid_out    : out std_logic;
                s_axi_bready        : in std_logic;
                s_axi_araddr        : in std_logic_vector(AXI_addr_width_all_chan_i_g-1 downto 0);
                s_axi_arprot        : in std_logic_vector(2 downto 0);
                s_axi_arvalid       : in std_logic;
                s_axi_arready       : out std_logic;
                s_axi_rdata         : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
                s_axi_rresp         : out std_logic_vector(1 downto 0);
                s_axi_rvalid        : out std_logic;
                s_axi_rready        : in std_logic
            );
end trackingChannelInterface;

architecture Behavioral of trackingChannelInterface is

signal front_end_select_a_u         : front_end_select_type;
signal RAM_we_a_b                   : std_logic_vector((MAX_CHAN_I_C - 1) downto 0); 
signal RAM_en_b                     : std_logic;
signal RAM_addr_u                   : std_logic_vector((ADDR_LEN_WORDS_E5a_I_C - 1) downto 0);
signal RAM_di_u                     : std_logic_vector((REG_WIDTH_C -1) downto 0);
signal PPS_20ms_a_b                 : PPS_20ms_type;
signal start_enable_a_b             : start_enable_type;
signal SW_reset_a_b                 : SW_reset_type; 
signal signal_type_a_u              : signal_type_type;
signal start_chip_a_u               : start_chip_type;
signal start_epoch_a_u              : start_epoch_type;
signal code_len_chip_a_u            : code_len_chip_type;
signal code_len_chip_1ms_a_u        : code_len_chip_1ms_type;
signal carr_NCO_increment_a_u       : carr_NCO_increment_type;
signal code_NCO_increment_a_u       : code_NCO_increment_type;
signal code_NCO_start_a_u_in        : code_NCO_increment_type;
signal early_prompt_spacing_a_u         : early_prompt_spacing_type;
signal very_early_prompt_spacing_a_u    : very_early_prompt_spacing_type;
signal correlation_length_epochs_a_u    : correlation_length_epochs_type;
signal epoch_length_ms_a_u              : epoch_length_ms_type;
signal bit_length_a_u               : bit_length_type;

signal fast_nco_count_value_a_u       : fast_NCO_count_type;
signal arm_slave_start_a_b            : start_enable_type;
signal code_NCO_slave_input_a_u       : code_NCO_increment_type;
signal code_NCO_master_output_a_u     : code_NCO_increment_type;
signal code_epoch_master_a_b          : master_epoch_type;
signal code_epoch_slave_a_b           : master_epoch_type;

signal accumulation_P_I_reg_a_s         : accumulation_type;
signal accumulation_P_Q_reg_a_s         : accumulation_type;
signal accumulation_E_I_reg_a_s         : accumulation_type;
signal accumulation_E_Q_reg_a_s         : accumulation_type;
signal accumulation_L_I_reg_a_s         : accumulation_type;
signal accumulation_L_Q_reg_a_s         : accumulation_type;
signal accumulation_VE_I_reg_a_s        : accumulation_type;
signal accumulation_VE_Q_reg_a_s        : accumulation_type;
signal accumulation_VL_I_reg_a_s        : accumulation_type;
signal accumulation_VL_Q_reg_a_s        : accumulation_type;
signal accm_1ms_P_I_reg_a_s             : accm_1ms_type;
signal accm_1ms_P_Q_reg_a_s             : accm_1ms_type;
signal RAM_do_a_u                       : RAM_do_type;

signal meas_code_NCO_a_u                : meas_output_reg_type;
signal meas_chip_count_a_u              : meas_output_reg_type;
signal meas_epoch_count_a_u             : meas_output_reg_type;
signal meas_carr_NCO_a_u                : meas_output_reg_type;
signal meas_cycle_count_a_u             : meas_output_reg_type;
signal meas_bit_count_a_u               : meas_output_reg_type;
signal meas_sec_count_a_u               : meas_output_reg_type;

signal selectedChannelWrite_i           : integer range 0 to (MAX_CHAN_I_C - 1);
signal selectedChannelRead_i            : integer range 0 to (MAX_CHAN_I_C - 1);
signal selectedWriteReg_i               : integer range 0 to (NUM_ADDR_TRACK_I_C - 1);
signal selectedChannelWriteRAM_i        : integer range 0 to (MAX_CHAN_I_C - 1);

signal read_reg_a_u                     : track_chan_slv_read_reg_type;
signal write_reg_a_u                    : track_chan_slv_write_reg_type;

signal s_axi_bvalid                     : std_logic;
signal armTrackingChannel_b             : std_logic;
signal PRN_data_u                       : std_logic_vector((REG_WIDTH_C -1) downto 0);

signal interrupt_a_u                    : trk_interrupt_type;
signal clr_interrupt_a_u_toggle         : trk_interrupt_type;
signal clr_interrupt_a_u_reg            : trk_interrupt_type;
signal clr_interrupt_a_u                : trk_interrupt_type;

signal ena_bit_count_a_b                : trk_interrupt_type;
signal ena_bit_count_a_b_toggle         : trk_interrupt_type;
signal ena_bit_count_a_b_reg            : trk_interrupt_type;    

signal arm_channel_a_u_toggle   : trk_interrupt_type;
signal arm_channel_a_u_reg      : trk_interrupt_type;
signal arm_channel_a_u          : trk_interrupt_type;

attribute mark_debug : string;                            
attribute keep : string;    
--attribute mark_debug of selectedChannelRead_i       : signal is "true";
--attribute mark_debug of selectedChannelWrite_i      : signal is "true";
attribute mark_debug of selectedChannelWriteRAM_i   : signal is "true";
--attribute mark_debug of  s_axi_aresetn                  : signal is "true";
--attribute mark_debug of  s_axi_awaddr                   : signal is "true";
--attribute mark_debug of  s_axi_awprot                   : signal is "true";
--attribute mark_debug of  s_axi_awvalid                  : signal is "true";
--attribute mark_debug of  s_axi_awready                  : signal is "true";
--attribute mark_debug of  s_axi_wdata                    : signal is "true";
--attribute mark_debug of  s_axi_wstrb                    : signal is "true";
--attribute mark_debug of  s_axi_wvalid                   : signal is "true";
--attribute mark_debug of  s_axi_wready                   : signal is "true";
--attribute mark_debug of  s_axi_bresp                    : signal is "true";
--attribute mark_debug of  s_axi_bvalid_out               : signal is "true";
--attribute mark_debug of  s_axi_bready                   : signal is "true";
--attribute mark_debug of  s_axi_araddr                   : signal is "true";
--attribute mark_debug of  s_axi_arprot                   : signal is "true";
--attribute mark_debug of  s_axi_arvalid                  : signal is "true";
--attribute mark_debug of  s_axi_arready                  : signal is "true";
--attribute mark_debug of  s_axi_rdata                    : signal is "true";

attribute mark_debug of  measurement_enable_b_in        : signal is "true";


attribute mark_debug of RAM_en_b                    : signal is "true";
attribute mark_debug of RAM_we_a_b                  : signal is "true";
attribute mark_debug of RAM_addr_u                  : signal is "true";
signal slaveCount : integer range 0 to (MAX_CHAN_I_C - 1) := 0;

begin

-- connect PP20ms_b_in to the channel
PPS_20ms_a_b <= (others => PP20ms_b_in);

-- set the selected channel for the AXI read 
selectedChannelRead_i <= to_integer(unsigned(s_axi_araddr((AXI_CHAN_ADDR_SIZE_I_C + AXI_CHAN_OFFSET_BITS_I_C - 1) downto AXI_CHAN_OFFSET_BITS_I_C)));

-- PRN RAM
-- set the selected channel for the PRN RAM write, different to channel write as it needs to be combinatorial for AXI bus timing
selectedChannelWriteRAM_i <= to_integer(unsigned(s_axi_awaddr((AXI_CHAN_ADDR_SIZE_I_C + AXI_CHAN_OFFSET_BITS_I_C - 1) downto AXI_CHAN_OFFSET_BITS_I_C)));

-- use one bit of address to enable RAM, write or read
RAM_en_b <= (s_axi_araddr(AXI_PRN_OFFSET_BITS_I_C) and s_axi_arvalid) or (s_axi_awaddr(AXI_PRN_OFFSET_BITS_I_C) and s_axi_awvalid);
-- use one bit of address for the write enable
process (s_axi_wvalid, s_axi_awaddr, selectedChannelWriteRAM_i) is 
begin
    if ((s_axi_wvalid = '1') and (s_axi_awaddr(AXI_PRN_OFFSET_BITS_I_C) = '1')) then
        for i in 0 to RAM_we_a_b'left loop
            if (i = selectedChannelWriteRAM_i) then
                RAM_we_a_b(i) <= '1';
            else
                RAM_we_a_b(i) <= '0';
            end if;             
        end loop;
    else
        RAM_we_a_b <= (others => '0');    
    end if;
end process;

-- set the address, PRN address is in words so ignore bottom two bits
RAM_addr_u <= s_axi_awaddr((ADDR_LEN_WORDS_E5a_I_C - 1 + 2) downto 2) when s_axi_awvalid = '1' else  s_axi_araddr((ADDR_LEN_WORDS_E5a_I_C - 1 + 2) downto 2) ;
-- data input
RAM_di_u <= s_axi_wdata;
-- data output
PRN_data_u <= RAM_do_a_u(selectedChannelRead_i);

-- loop through the channels
trackingChannelGen : for i in 0 to (MAX_CHAN_I_C - 1) generate
    trackingChannel_X : entity work.trackingChannel
        generic map(    enable_BOC_bool_g               => true )
        Port map (     
                        sample_clk_b_in                 => sample_clk_b_in,
                        data_FE_sync_u_in               => data_FE_sync_u_in,
                        front_end_select_u_in           => front_end_select_a_u(i),
                        RAM_we_b_in                     => RAM_we_a_b(i), 
                        RAM_en_b_in                     => RAM_en_b,
                        RAM_addr_u_in                   => RAM_addr_u,
                        RAM_di_u_in                     => RAM_di_u,
                        PPS_20ms_b_in                   => PPS_20ms_a_b(i),
                        start_enable_b_in               => start_enable_a_b(i),
                        SW_reset_in                     => SW_reset_a_b(i), 
                        signal_type_u_in                => signal_type_a_u(i),
                        start_chip_u_in                 => start_chip_a_u(i),
                        start_epoch_u_in                => start_epoch_a_u(i),
                        code_len_chip_u_in              => code_len_chip_a_u(i),
                        code_len_chip_1ms_u_in          => code_len_chip_1ms_a_u(i),
                        carr_NCO_increment_u_in         => carr_NCO_increment_a_u(i),
                        code_NCO_increment_u_in         => code_NCO_increment_a_u(i),
                        early_prompt_spacing_u_in       => early_prompt_spacing_a_u(i),
                        very_early_prompt_spacing_u_in  => very_early_prompt_spacing_a_u(i),
                        correlation_length_epochs_u_in  => correlation_length_epochs_a_u(i),
                        epoch_length_ms_u_in            => epoch_length_ms_a_u(i),
                        bit_length_u_in                 => bit_length_a_u(i),
                        fast_nco_count_value_u_in       => fast_nco_count_value_a_u(i),
                        arm_slave_start_b_in            => arm_slave_start_a_b(i),
                        code_epoch_slave_b_in           => code_epoch_slave_a_b(i),
                        code_NCO_master_u_in            => code_NCO_slave_input_a_u(i),
                        ena_bit_count_b_in              => ena_bit_count_a_b(i),
                        measurement_enable_b_in         => measurement_enable_b_in,
                        code_NCO_start_u_in             => code_NCO_start_a_u_in(i),
                        clr_interrupt_b_u_in            => clr_interrupt_a_u(i),
                        interrupt_b_out                 => interrupt_a_u(i),
                        accumulation_P_I_reg_s_out      => accumulation_P_I_reg_a_s(i),
                        accumulation_P_Q_reg_s_out      => accumulation_P_Q_reg_a_s(i),
                        accumulation_E_I_reg_s_out      => accumulation_E_I_reg_a_s(i),
                        accumulation_E_Q_reg_s_out      => accumulation_E_Q_reg_a_s(i),
                        accumulation_L_I_reg_s_out      => accumulation_L_I_reg_a_s(i),
                        accumulation_L_Q_reg_s_out      => accumulation_L_Q_reg_a_s(i),
                        accumulation_VE_I_reg_s_out     => accumulation_VE_I_reg_a_s(i),
                        accumulation_VE_Q_reg_s_out     => accumulation_VE_Q_reg_a_s(i),
                        accumulation_VL_I_reg_s_out     => accumulation_VL_I_reg_a_s(i),
                        accumulation_VL_Q_reg_s_out     => accumulation_VL_Q_reg_a_s(i),
                        accm_1ms_P_I_reg_a_s_out        => accm_1ms_P_I_reg_a_s(i),
                        accm_1ms_P_Q_reg_a_s_out        => accm_1ms_P_Q_reg_a_s(i),
                        RAM_do_u_out                    => RAM_do_a_u(i),
                        meas_code_NCO_u_out             => meas_code_NCO_a_u(i),
                        meas_chip_count_u_out           => meas_chip_count_a_u(i),
                        meas_epoch_count_u_out          => meas_epoch_count_a_u(i),
                        meas_carr_NCO_u_out             => meas_carr_NCO_a_u(i),
                        meas_cycle_count_u_out          => meas_cycle_count_a_u(i),
                        meas_bit_count_u_out            => meas_bit_count_a_u(i),
                        meas_sec_count_u_out            => meas_sec_count_a_u(i),
                        code_NCO_master_u_out           => code_NCO_master_output_a_u(i),
                        code_epoch_master_b_out         => code_epoch_master_a_b(i)
                                                          
                 );
                  
end generate trackingChannelGen;

---- loop through the master channels to do the slave connections 
process (code_NCO_master_output_a_u, code_epoch_master_a_b) is
variable slaveCount : integer range 0 to (MAX_CHAN_I_C - 1);
begin
    slaveCount := 0;
    slaveConnect: for masterCount in 0 to (NUM_MASTER_CHAN_I_C - 1) loop
        
       -- zero master channel input
       code_NCO_slave_input_a_u(masterCount + slaveCount) <= (others => '0');
       code_epoch_slave_a_b(masterCount + slaveCount) <= '0';
    
        case NUM_SLAVES_A_I_C(masterCount) is    
            when 1 =>          code_NCO_slave_input_a_u(masterCount + slaveCount + 1) <= code_NCO_master_output_a_u(masterCount + slaveCount);
                               code_epoch_slave_a_b(masterCount + slaveCount + 1) <= code_epoch_master_a_b(masterCount + slaveCount);
                               
            when 2 =>          code_NCO_slave_input_a_u(masterCount + slaveCount + 1) <= code_NCO_master_output_a_u(masterCount + slaveCount);
                               code_NCO_slave_input_a_u(masterCount + slaveCount + 2) <= code_NCO_master_output_a_u(masterCount + slaveCount);
                               code_epoch_slave_a_b(masterCount + slaveCount + 1) <= code_epoch_master_a_b(masterCount + slaveCount);
                               code_epoch_slave_a_b(masterCount + slaveCount + 2) <= code_epoch_master_a_b(masterCount + slaveCount);                  
                               
            when 3 =>          code_NCO_slave_input_a_u(masterCount + slaveCount + 1) <= code_NCO_master_output_a_u(masterCount + slaveCount);
                               code_NCO_slave_input_a_u(masterCount + slaveCount + 2) <= code_NCO_master_output_a_u(masterCount + slaveCount);   
                               code_NCO_slave_input_a_u(masterCount + slaveCount + 3) <= code_NCO_master_output_a_u(masterCount + slaveCount); 
                               code_epoch_slave_a_b(masterCount + slaveCount + 1) <= code_epoch_master_a_b(masterCount + slaveCount);
                               code_epoch_slave_a_b(masterCount + slaveCount + 2) <= code_epoch_master_a_b(masterCount + slaveCount); 
                               code_epoch_slave_a_b(masterCount + slaveCount + 3) <= code_epoch_master_a_b(masterCount + slaveCount);
            when others 	=> null; 
        end case;
        
        slaveCount := slaveCount + NUM_SLAVES_A_I_C(masterCount);
    end loop slaveConnect;
end process;



interrupt_a_u_out <= interrupt_a_u;
-----------------------------------------------------------------------
--- choose the read registers for the selected channel ----------------
-----------------------------------------------------------------------
-- read register can be assigned combinatorially
read_reg_a_u(ADDR_OFFSET_P_I_I_C)   <= accumulation_P_I_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_P_Q_I_C)   <= accumulation_P_Q_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_E_I_I_C)   <= accumulation_E_I_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_E_Q_I_C)   <= accumulation_E_Q_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_L_I_I_C)   <= accumulation_L_I_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_L_Q_I_C)   <= accumulation_L_Q_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_VE_I_I_C)  <= accumulation_VE_I_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_VE_Q_I_C)  <= accumulation_VE_Q_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_VL_I_I_C)  <= accumulation_VL_I_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_VL_Q_I_C)  <= accumulation_VL_Q_reg_a_s(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_0_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(0);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_1_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(1);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_2_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(2);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_3_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(3);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_4_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(4);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_5_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(5);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_6_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(6);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_7_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(7);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_8_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(8);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_9_I_C)   <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(9);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_10_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(10);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_11_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(11);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_12_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(12);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_13_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(13);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_14_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(14);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_15_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(15);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_16_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(16);
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_17_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(17);        
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_18_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(18);        
read_reg_a_u(ADDR_OFFSET_P_I_1ms_array_19_I_C)  <= accm_1ms_P_I_reg_a_s(selectedChannelRead_i)(19);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_0_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(0);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_1_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(1);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_2_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(2);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_3_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(3);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_4_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(4);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_5_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(5);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_6_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(6);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_7_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(7);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_8_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(8);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_9_I_C)   <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(9);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_10_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(10);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_11_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(11);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_12_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(12);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_13_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(13);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_14_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(14);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_15_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(15);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_16_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(16);
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_17_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(17);        
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_18_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(18);        
read_reg_a_u(ADDR_OFFSET_P_Q_1ms_array_19_I_C)  <= accm_1ms_P_Q_reg_a_s(selectedChannelRead_i)(19);

read_reg_a_u(ADDR_OFFSET_FRONT_END_SELECT_I_C)(read_reg_a_u'left downto FE_SELECT_SIZE) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_FRONT_END_SELECT_I_C)((FE_SELECT_SIZE - 1) downto 0) <= front_end_select_a_u(selectedChannelRead_i);

read_reg_a_u(ADDR_OFFSET_RESET_I_C)(read_reg_a_u'left downto 1) <= (others => '0'); 
read_reg_a_u(ADDR_OFFSET_RESET_I_C)(0) <= SW_reset_a_b(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_SIGNAL_TYPE_I_C)(read_reg_a_u'left downto SIGNAL_TYPE_SIZE_I_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_SIGNAL_TYPE_I_C)((SIGNAL_TYPE_SIZE_I_C - 1) downto 0) <= signal_type_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_START_CHIP_I_C)(read_reg_a_u'left downto MAX_CHIP_COUNT_LENGTH_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_START_CHIP_I_C)((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0) <= start_chip_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_START_EPOCH_I_C)(read_reg_a_u'left downto MAX_CORR_LEN_SIZE_I_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_START_EPOCH_I_C)((MAX_CORR_LEN_SIZE_I_C - 1) downto 0) <= start_epoch_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_CODE_LENGTH_I_C)(read_reg_a_u'left downto MAX_CHIP_COUNT_LENGTH_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_CODE_LENGTH_I_C)((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0) <= code_len_chip_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_CODE_CHIPS_1MS_I_C)(read_reg_a_u'left downto MAX_CHIP_COUNT_LENGTH_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_CODE_CHIPS_1MS_I_C)((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0) <= code_len_chip_1ms_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_CARR_NCO_INCR_I_C) <= carr_NCO_increment_a_u(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_CODE_NCO_INCR_I_C) <= code_NCO_increment_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_EARLY_PROMPT_SPACING_I_C)(read_reg_a_u'left downto CODE_DELAY_LEN_I_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_EARLY_PROMPT_SPACING_I_C)((CODE_DELAY_LEN_I_C - 1) downto 0) <= early_prompt_spacing_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_VERY_EARLY_PROMPT_SPACING_I_C)(read_reg_a_u'left downto CODE_DELAY_LEN_I_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_VERY_EARLY_PROMPT_SPACING_I_C)((CODE_DELAY_LEN_I_C - 1) downto 0) <= very_early_prompt_spacing_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_CORR_LEN_EPOCHS_I_C)(read_reg_a_u'left downto MAX_CORR_LEN_SIZE_I_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_CORR_LEN_EPOCHS_I_C)((MAX_CORR_LEN_SIZE_I_C - 1) downto 0) <= correlation_length_epochs_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_EPOCH_LEN_MS_I_C)(read_reg_a_u'left downto MAX_CORR_LEN_SIZE_I_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_EPOCH_LEN_MS_I_C)((MAX_CORR_LEN_SIZE_I_C - 1) downto 0) <= epoch_length_ms_a_u(selectedChannelRead_i); 

read_reg_a_u(ADDR_OFFSET_BIT_CODE_LENGTH_I_C)(read_reg_a_u'left downto SEC_CODE_COUNT_SIZE_C) <= (others => '0');
read_reg_a_u(ADDR_OFFSET_BIT_CODE_LENGTH_I_C)((SEC_CODE_COUNT_SIZE_C - 1) downto 0) <= bit_length_a_u(selectedChannelRead_i); 


read_reg_a_u(ADDR_OFFSET_CODE_NCO_START_I_C)    <= code_NCO_start_a_u_in(selectedChannelRead_i);

read_reg_a_u(ADDR_OFFSET_MEAS_CODE_NCO_I_C)     <= meas_code_NCO_a_u(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_MEAS_COUNT_CHIP_I_C)   <= meas_chip_count_a_u(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_MEAS_EPOCH_COUNT_I_C)  <= meas_epoch_count_a_u(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_MEAS_CARR_NCO_I_C)     <= meas_carr_NCO_a_u(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_MEAS_CYCLE_COUNT_I_C)  <= meas_cycle_count_a_u(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_MEAS_BIT_COUNT_I_C)    <= meas_bit_count_a_u(selectedChannelRead_i); 
read_reg_a_u(ADDR_OFFSET_MEAS_SEC_COUNT_I_C)    <= meas_sec_count_a_u(selectedChannelRead_i);

read_reg_a_u(ADDR_ARM_SLAVE_I_C)(read_reg_a_u'left downto 1) <= (others => '0'); 
read_reg_a_u(ADDR_ARM_SLAVE_I_C)(0) <= arm_slave_start_a_b(selectedChannelRead_i);

read_reg_a_u(ADDR_FAST_NCO_CNT_MAX_I_C)(read_reg_a_u'left downto MAX_NCO_COUNT_LENGTH_C) <= (others => '0');
read_reg_a_u(ADDR_FAST_NCO_CNT_MAX_I_C)((MAX_NCO_COUNT_LENGTH_C - 1) downto 0) <= fast_nco_count_value_a_u(selectedChannelRead_i); 



-- routing measurement to output for DMA connections
meas_code_NCO_a_u_out      <= meas_code_NCO_a_u;       
meas_chip_count_a_u_out    <= meas_chip_count_a_u;   
meas_epoch_count_a_u_out   <= meas_epoch_count_a_u; 
meas_carr_NCO_a_u_out      <= meas_carr_NCO_a_u;       
meas_cycle_count_a_u_out   <= meas_cycle_count_a_u; 
meas_bit_count_a_u_out     <= meas_bit_count_a_u; 
meas_sec_count_a_u_out     <= meas_sec_count_a_u;
-----------------------------------------------------------------------
--- choose the write registers for the selected channel ---------------
-----------------------------------------------------------------------         
-- write registers (input to channels) only updated once the transaction is valid
--process(s_axi_aresetn, s_axi_aclk) is
process(s_axi_aclk) is
begin
--    if (s_axi_aresetn = '0') then
--        selectedChannelWrite_i <= 0;
--        selectedWriteReg_i <= 0;
--        -- channel defaults
--        front_end_select_a_u <= (others => (others => '0'));
--        start_enable_a_b    <= (others => '0');
--        SW_reset_a_b        <= (others => '1');
--        signal_type_a_u     <= (others => std_logic_vector(to_unsigned(CA_SIGNAL, SIGNAL_TYPE_SIZE_I_C)));
--        start_chip_a_u      <= (others => (others => '0'));
--        start_epoch_a_u     <= (others => (others => '0'));
--        code_len_chip_a_u   <= (others => (others => '0'));         --(others => std_logic_vector(to_unsigned(CODE_LENGTH_CA_C, MAX_CHIP_COUNT_LENGTH_C)));
--        code_len_chip_1ms_a_u       <= (others => (others => '0')); --(others => std_logic_vector(to_unsigned(CODE_LENGTH_CA_C, MAX_CHIP_COUNT_LENGTH_C)));
--        carr_NCO_increment_a_u      <= (others => std_logic_vector(CARR_NCO_INCR_CA_E1B_U_C));
--        code_NCO_increment_a_u      <= (others => std_logic_vector(CODE_NCO_INCR_CA_E1B_U_C));
--        early_prompt_spacing_a_u    <= (others => std_logic_vector(to_unsigned(ONE_CHIP_SPACING_CA_E1B_I_C, CODE_DELAY_LEN_I_C)));
--        very_early_prompt_spacing_a_u <= (others => std_logic_vector(to_unsigned(ONE_CHIP_SPACING_CA_E1B_I_C, CODE_DELAY_LEN_I_C)));
--        correlation_length_epochs_a_u <= (others => std_logic_vector(to_unsigned(DEF_CORR_EPOCHS_CA_I_C, MAX_CORR_LEN_SIZE_I_C)));
--        epoch_length_ms_a_u     <= (others => (others => '0'));--(others => std_logic_vector(to_unsigned(DEF_CORR_EPOCHS_CA_I_C, MAX_CORR_LEN_SIZE_I_C)));
--        bit_length_a_u          <= (others => (others => '0'));
--        code_NCO_start_a_u_in   <= (others => (others => '0'));
--        clr_interrupt_a_u_toggle    <=(others => '0');
--        clr_interrupt_a_u_reg       <= (others => '0');
        
--        ena_bit_count_a_b_toggle  <= (others => '0');
--        ena_bit_count_a_b_reg     <= (others => '0');
                
--        arm_channel_a_u_toggle  <= (others => '0');
--        arm_channel_a_u_reg     <= (others => '0');
        
--        ena_bit_count_a_b       <= (others => '0');       
--    elsif rising_edge(s_axi_aclk) then
    if rising_edge(s_axi_aclk) then

        if s_axi_aresetn = '0' then    
            selectedChannelWrite_i <= 0;
            selectedWriteReg_i <= 0;
            -- channel defaults
            front_end_select_a_u <= (others => (others => '0'));
            start_enable_a_b    <= (others => '0');
            SW_reset_a_b        <= (others => '1');
            signal_type_a_u     <= (others => std_logic_vector(to_unsigned(CA_SIGNAL, SIGNAL_TYPE_SIZE_I_C)));
            start_chip_a_u      <= (others => (others => '0'));
            start_epoch_a_u     <= (others => (others => '0'));
            code_len_chip_a_u   <= (others => std_logic_vector(to_unsigned(CODE_LENGTH_CA_C, MAX_CHIP_COUNT_LENGTH_C)));
            code_len_chip_1ms_a_u       <= (others => std_logic_vector(to_unsigned(CODE_LENGTH_CA_C, MAX_CHIP_COUNT_LENGTH_C)));
            carr_NCO_increment_a_u      <= (others => std_logic_vector(CARR_NCO_INCR_CA_E1B_U_C));
            code_NCO_increment_a_u      <= (others => std_logic_vector(CODE_NCO_INCR_E5_L5_U_C));
            early_prompt_spacing_a_u    <= (others => std_logic_vector(to_unsigned(ONE_CHIP_SPACING_CA_E1B_I_C, CODE_DELAY_LEN_I_C)));
            very_early_prompt_spacing_a_u <= (others => std_logic_vector(to_unsigned(ONE_CHIP_SPACING_CA_E1B_I_C, CODE_DELAY_LEN_I_C)));
            correlation_length_epochs_a_u <= (others => std_logic_vector(to_unsigned(DEF_CORR_EPOCHS_CA_I_C, MAX_CORR_LEN_SIZE_I_C)));
            epoch_length_ms_a_u     <= (others => std_logic_vector(to_unsigned(DEF_CORR_EPOCHS_CA_I_C, MAX_CORR_LEN_SIZE_I_C)));
            bit_length_a_u          <= (others => (others => '0'));
            code_NCO_start_a_u_in   <= (others => (others => '0'));
            clr_interrupt_a_u_toggle    <=(others => '0');
            clr_interrupt_a_u_reg       <= (others => '0');
            
            ena_bit_count_a_b_toggle  <= (others => '0');
            ena_bit_count_a_b_reg     <= (others => '0');
                    
            arm_channel_a_u_toggle  <= (others => '0');
            arm_channel_a_u_reg     <= (others => '0');
            arm_slave_start_a_b     <= (others => '0');
            
            ena_bit_count_a_b       <= (others => '0'); 
            fast_nco_count_value_a_u <= (others => std_logic_vector(to_unsigned(FAST_NCO_COUNT_MAX_C, MAX_NCO_COUNT_LENGTH_C)));      
        else    
            -- if write address is valid update it
            if (s_axi_awvalid = '1') then 
                selectedChannelWrite_i <= to_integer(unsigned(s_axi_awaddr((AXI_CHAN_ADDR_SIZE_I_C + AXI_CHAN_OFFSET_BITS_I_C - 1) downto AXI_CHAN_OFFSET_BITS_I_C)));
                selectedWriteReg_i <= to_integer(unsigned(s_axi_awaddr(AXI_ADDR_WIDTH_TRACK_I_C - 1 downto 2)));
            end if;
    
            -- if write transaction is valid update the registers of selected channel
            if (s_axi_bvalid = '1') then
                case selectedWriteReg_i is
                    when (ADDR_OFFSET_FRONT_END_SELECT_I_C)  =>  front_end_select_a_u(selectedChannelWrite_i)   <= write_reg_a_u(ADDR_OFFSET_FRONT_END_SELECT_I_C - AXI_NUM_READ_REG_TRACK_I_C)((FE_SELECT_SIZE - 1) downto 0);
                    when (ADDR_OFFSET_RESET_I_C)             =>  SW_reset_a_b(selectedChannelWrite_i)           <= write_reg_a_u(ADDR_OFFSET_RESET_I_C - AXI_NUM_READ_REG_TRACK_I_C)(0);
                    when (ADDR_OFFSET_SIGNAL_TYPE_I_C)       =>  signal_type_a_u(selectedChannelWrite_i)        <= write_reg_a_u(ADDR_OFFSET_SIGNAL_TYPE_I_C - AXI_NUM_READ_REG_TRACK_I_C)((SIGNAL_TYPE_SIZE_I_C - 1) downto 0);
                    when (ADDR_OFFSET_START_CHIP_I_C)        =>  start_chip_a_u(selectedChannelWrite_i)         <= write_reg_a_u(ADDR_OFFSET_START_CHIP_I_C - AXI_NUM_READ_REG_TRACK_I_C)((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
                    when (ADDR_OFFSET_START_EPOCH_I_C)       =>  start_epoch_a_u(selectedChannelWrite_i)        <= write_reg_a_u(ADDR_OFFSET_START_EPOCH_I_C - AXI_NUM_READ_REG_TRACK_I_C)((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
                    when (ADDR_OFFSET_CODE_LENGTH_I_C)       =>  code_len_chip_a_u(selectedChannelWrite_i)      <= write_reg_a_u(ADDR_OFFSET_CODE_LENGTH_I_C - AXI_NUM_READ_REG_TRACK_I_C)((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
                    when (ADDR_OFFSET_CODE_CHIPS_1MS_I_C)    =>  code_len_chip_1ms_a_u(selectedChannelWrite_i)   <= write_reg_a_u(ADDR_OFFSET_CODE_CHIPS_1MS_I_C - AXI_NUM_READ_REG_TRACK_I_C)((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
                    when (ADDR_OFFSET_CARR_NCO_INCR_I_C)     =>  carr_NCO_increment_a_u(selectedChannelWrite_i)  <= write_reg_a_u(ADDR_OFFSET_CARR_NCO_INCR_I_C - AXI_NUM_READ_REG_TRACK_I_C)((CARR_NCO_LENGTH_C - 1) downto 0);
                    when (ADDR_OFFSET_CODE_NCO_INCR_I_C)     =>  code_NCO_increment_a_u(selectedChannelWrite_i)  <= write_reg_a_u(ADDR_OFFSET_CODE_NCO_INCR_I_C - AXI_NUM_READ_REG_TRACK_I_C)((CODE_NCO_LENGTH_C - 1) downto 0);
                    when (ADDR_OFFSET_EARLY_PROMPT_SPACING_I_C) =>  early_prompt_spacing_a_u(selectedChannelWrite_i) <= write_reg_a_u(ADDR_OFFSET_EARLY_PROMPT_SPACING_I_C - AXI_NUM_READ_REG_TRACK_I_C)((CODE_DELAY_LEN_I_C - 1) downto 0);
                    when (ADDR_OFFSET_VERY_EARLY_PROMPT_SPACING_I_C) => very_early_prompt_spacing_a_u(selectedChannelWrite_i) <= write_reg_a_u(ADDR_OFFSET_VERY_EARLY_PROMPT_SPACING_I_C - AXI_NUM_READ_REG_TRACK_I_C)((CODE_DELAY_LEN_I_C - 1) downto 0);
                    when (ADDR_OFFSET_CORR_LEN_EPOCHS_I_C)   =>  correlation_length_epochs_a_u(selectedChannelWrite_i)  <= write_reg_a_u(ADDR_OFFSET_CORR_LEN_EPOCHS_I_C - AXI_NUM_READ_REG_TRACK_I_C)((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
                    when (ADDR_OFFSET_EPOCH_LEN_MS_I_C)      =>  epoch_length_ms_a_u(selectedChannelWrite_i)            <= write_reg_a_u(ADDR_OFFSET_EPOCH_LEN_MS_I_C - AXI_NUM_READ_REG_TRACK_I_C)((MAX_CORR_LEN_SIZE_I_C - 1) downto 0);
                                    
                    when (ADDR_OFFSET_CODE_NCO_START_I_C)    =>  code_NCO_start_a_u_in(selectedChannelWrite_i)       <= write_reg_a_u(ADDR_OFFSET_CODE_NCO_START_I_C - AXI_NUM_READ_REG_TRACK_I_C)((CODE_NCO_LENGTH_C - 1) downto 0);
                    when (ADDR_OFFSET_CLR_INTERRUPT_I_C)     =>  clr_interrupt_a_u_toggle(selectedChannelWrite_i)       <= NOT clr_interrupt_a_u_toggle(selectedChannelWrite_i);-- write_reg_a_u(ADDR_OFFSET_CLR_INTERRUPT_I_C - AXI_NUM_READ_REG_TRACK_I_C)(0);                                                 
                    when(ADDR_OFFSET_ARM_TRK_I_C)            =>  arm_channel_a_u_toggle(selectedChannelWrite_i) <= NOT arm_channel_a_u_toggle(selectedChannelWrite_i);
                    
                    when (ADDR_OFFSET_BIT_CODE_LENGTH_I_C)   =>  bit_length_a_u(selectedChannelWrite_i)      <= write_reg_a_u(ADDR_OFFSET_BIT_CODE_LENGTH_I_C - AXI_NUM_READ_REG_TRACK_I_C)((SEC_CODE_COUNT_SIZE_C - 1) downto 0);
                    when (ADDR_OFFSET_BIT_ENA_CNT_I_C)       =>  ena_bit_count_a_b_toggle(selectedChannelWrite_i) <= NOT ena_bit_count_a_b_toggle(selectedChannelWrite_i);
                    when (ADDR_ARM_SLAVE_I_C)                => arm_slave_start_a_b(selectedChannelWrite_i)  <= write_reg_a_u(ADDR_ARM_SLAVE_I_C - AXI_NUM_READ_REG_TRACK_I_C)(0);
                    when (ADDR_FAST_NCO_CNT_MAX_I_C)         => fast_nco_count_value_a_u(selectedChannelWrite_i) <= write_reg_a_u(ADDR_FAST_NCO_CNT_MAX_I_C - AXI_NUM_READ_REG_TRACK_I_C)((MAX_NCO_COUNT_LENGTH_C - 1) downto 0);
                    when others 	=> 	null;
                end case;
            end if;
            -- handle the arm channel signal
            arm_channel_a_u_reg <= arm_channel_a_u_toggle;
            
            for i in start_enable_a_b'range loop
                if arm_channel_a_u_reg(i) /= arm_channel_a_u_toggle(i) then
                    start_enable_a_b(i) <= '1';
                else
                    start_enable_a_b(i) <= '0';
                end if;
            end loop;
               
    --        if (armTrackingChannel_b = '1') then
    --            start_enable_a_b(selectedChannelWrite_i) <= '1';
    --        else
    --            start_enable_a_b <= (others => '0');
    --        end if;
            
            -- register the toggle value
            clr_interrupt_a_u_reg <= clr_interrupt_a_u_toggle;
            
            for i in clr_interrupt_a_u'range loop
                if clr_interrupt_a_u_reg(i) /= clr_interrupt_a_u_toggle(i) then
                    clr_interrupt_a_u(i) <= '1';
                else
                    clr_interrupt_a_u(i) <= '0';
                end if;
            end loop;
            
            ena_bit_count_a_b_reg <= ena_bit_count_a_b_toggle;
            
            for i in ena_bit_count_a_b'range loop
                if ena_bit_count_a_b_reg(i) /= ena_bit_count_a_b_toggle(i) then
                    ena_bit_count_a_b(i) <= '1';
                else
                    ena_bit_count_a_b(i) <= '0';
                end if;
            end loop;        
            
        end if;        
    end if;
    
    
end process;


    -- Instantiation of tracking channel Axi Bus Interface
     trackChannel_X_AXI_inst : entity work.trackingChannelAXI
         generic map (
             C_S_AXI_DATA_WIDTH             => C_S_AXI_DATA_WIDTH,
             C_S_AXI_ADDR_WIDTH             => AXI_ADDR_WIDTH_TRACK_I_C,
             C_S_AXI_NUM_READ_ONLY_REGS     => AXI_NUM_READ_REG_TRACK_I_C,
             C_S_AXI_NUM_TOTAL_REGS         => NUM_ADDR_TRACK_I_C   
         )
         port map (
             S_AXI_ACLK         => s_axi_aclk,
             S_AXI_ARESETN      => s_axi_aresetn,
             S_AXI_AWADDR       => s_axi_awaddr((AXI_ADDR_WIDTH_TRACK_I_C - 1) downto 0),
             S_AXI_AWPROT       => s_axi_awprot,
             S_AXI_AWVALID      => s_axi_awvalid,
             S_AXI_AWREADY      => s_axi_awready,
             S_AXI_WDATA        => s_axi_wdata,
             S_AXI_WSTRB        => s_axi_wstrb,
             S_AXI_WVALID       => s_axi_wvalid,
             S_AXI_WREADY       => s_axi_wready,
             S_AXI_BRESP        => s_axi_bresp,
             S_AXI_BVALID       => s_axi_bvalid,
             S_AXI_BREADY       => s_axi_bready,
             S_AXI_ARADDR       => s_axi_araddr((AXI_ADDR_WIDTH_TRACK_I_C - 1) downto 0),
             S_AXI_ARPROT       => s_axi_arprot,
             S_AXI_ARVALID      => s_axi_arvalid,
             S_AXI_ARREADY      => s_axi_arready,
             S_AXI_RDATA        => s_axi_rdata,
             S_AXI_RRESP        => s_axi_rresp,
             S_AXI_RVALID       => s_axi_rvalid,
             S_AXI_RREADY       => s_axi_rready,
             PRN_data_u_in      => PRN_data_u,
             PRN_read_b_in      => RAM_en_b,
             read_reg_a_u_in    => read_reg_a_u,
             write_reg_a_u_out  => write_reg_a_u
             --armTrackingChannel_b_out => armTrackingChannel_b
         );                 
                 
 s_axi_bvalid_out <= s_axi_bvalid;                

-- a module that takes a snapshot of raised interrupts, for polled tracking loops
tracking_interrupt_sampler_i : entity work.trk_interrupt_snapshot
    Port map(
        clk_b_in		 	   => sample_clk_b_in,
        reset_b_in		 	   => SW_reset_a_b(0),
        trk_interrupt_a_in	   => interrupt_a_u,
        clr_snap_a_in	       => clr_interrupt_a_u,
        snapshot_a_out	 	   => snapshot_a_out,
        missed_snap_cnt_a_out  => open		
    );

end Behavioral;
