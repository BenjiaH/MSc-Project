----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.08.2019 16:08:15
-- Design Name: 
-- Module Name: TB_trackingChannelInterface - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;
use work.receiverConfigurationPackage.all;
use IEEE.NUMERIC_STD.ALL;

entity TB_trackingChannelInterface is
--  Port ( );
end TB_trackingChannelInterface;

architecture Behavioral of TB_trackingChannelInterface is

constant    C_S_AXI_DATA_WIDTH	            : integer	:= REG_WIDTH_C;
constant    AXI_addr_width_all_chan_i_g     : integer   := AXI_ADDR_WIDTH_ALL_CHAN_I_C;
signal      sample_clk_b_in                 : std_logic;
signal      data_FE_sync_u_in               : data_FE_type;
signal      measurement_enable_b_in         : std_logic;
signal      PP20ms_b_in                     : std_logic;
signal      interrupt_a_u_out               : trk_interrupt_type;
signal      snapshot_a_out                  : trk_interrupt_type;
                -- measurement to DMA Nav
signal      meas_code_NCO_a_u_out           : meas_output_reg_type;
signal      meas_chip_count_a_u_out         : meas_output_reg_type;
signal      meas_epoch_count_a_u_out        : meas_output_reg_type;
signal      meas_carr_NCO_a_u_out           : meas_output_reg_type;
signal      meas_cycle_count_a_u_out        : meas_output_reg_type;
signal      meas_bit_count_a_u_out          : meas_output_reg_type;
signal      meas_sec_count_a_u_out          : meas_output_reg_type;                      
                -- Ports of Axi Slave Bus Interface S_AXI
signal      s_axi_aclk          : std_logic;
signal      s_axi_aresetn       : std_logic;
signal      s_axi_awaddr        : std_logic_vector(AXI_addr_width_all_chan_i_g-1 downto 0);
signal      s_axi_awprot        : std_logic_vector(2 downto 0);
signal      s_axi_awvalid       : std_logic;
signal      s_axi_awready       : std_logic;
signal      s_axi_wdata         : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal      s_axi_wstrb         : std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
signal      s_axi_wvalid        : std_logic;
signal      s_axi_wready        : std_logic;
signal      s_axi_bresp         : std_logic_vector(1 downto 0);
signal      s_axi_bvalid_out    : std_logic;
signal      s_axi_bready        : std_logic;
signal      s_axi_araddr        : std_logic_vector(AXI_addr_width_all_chan_i_g-1 downto 0);
signal      s_axi_arprot        : std_logic_vector(2 downto 0);
signal      s_axi_arvalid       : std_logic;
signal      s_axi_arready       : std_logic;
signal      s_axi_rdata         : std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
signal      s_axi_rresp         : std_logic_vector(1 downto 0);
signal      s_axi_rvalid        : std_logic;
signal      s_axi_rready        : std_logic;

--constant AXI_ACLK_period : time := 10062 ps;        
constant AXI_ACLK_period : time := 10063 ps; 
begin

uut: entity work.trackingChannelInterface 

    generic map(    C_S_AXI_DATA_WIDTH	            => REG_WIDTH_C,
                AXI_addr_width_all_chan_i_g     => AXI_ADDR_WIDTH_ALL_CHAN_I_C)
    Port map (      
                sample_clk_b_in                 => sample_clk_b_in,
                data_FE_sync_u_in               => data_FE_sync_u_in,
                measurement_enable_b_in         => measurement_enable_b_in,
                PP20ms_b_in                     => PP20ms_b_in,
                interrupt_a_u_out               => interrupt_a_u_out,
                snapshot_a_out                  => snapshot_a_out,
                -- measurement to DMA Nav
                meas_code_NCO_a_u_out           => meas_code_NCO_a_u_out,
                meas_chip_count_a_u_out         => meas_chip_count_a_u_out,
                meas_epoch_count_a_u_out        => meas_epoch_count_a_u_out,
                meas_carr_NCO_a_u_out           => meas_carr_NCO_a_u_out,
                meas_cycle_count_a_u_out        => meas_cycle_count_a_u_out,
                meas_bit_count_a_u_out          => meas_bit_count_a_u_out,
                meas_sec_count_a_u_out          => meas_sec_count_a_u_out,                    
                -- Ports of Axi Slave Bus Interface S_AXI
                s_axi_aclk          => s_axi_aclk,
                s_axi_aresetn       => s_axi_aresetn,
                s_axi_awaddr        => s_axi_awaddr,
                s_axi_awprot        => s_axi_awprot,
                s_axi_awvalid       => s_axi_awvalid,
                s_axi_awready       => s_axi_awready,
                s_axi_wdata         => s_axi_wdata,
                s_axi_wstrb         => s_axi_wstrb,
                s_axi_wvalid        => s_axi_wvalid,
                s_axi_wready        => s_axi_wready,
                s_axi_bresp         => s_axi_bresp,
                s_axi_bvalid_out    => s_axi_bvalid_out,
                s_axi_bready        => s_axi_bready,
                s_axi_araddr        => s_axi_araddr,
                s_axi_arprot        => s_axi_arprot,
                s_axi_arvalid       => s_axi_arvalid,
                s_axi_arready       => s_axi_arready,
                s_axi_rdata         => s_axi_rdata,
                s_axi_rresp         => s_axi_rresp,
                s_axi_rvalid        => s_axi_rvalid,
                s_axi_rready        => s_axi_rready
            );


clock_gen : PROCESS -- clock process for sample_clk_b_in,
	BEGIN
		CLOCK_LOOP : LOOP
		  sample_clk_b_in <= '1';
		WAIT FOR AXI_ACLK_period/2;
		  sample_clk_b_in <= '0';
		WAIT FOR AXI_ACLK_period/2;
		END LOOP CLOCK_LOOP;
END PROCESS clock_gen;

-- set the axo clock
s_axi_aclk <= sample_clk_b_in;

tb : PROCESS
BEGIN
    -- asignments		
    s_axi_aresetn <= '0';
    data_FE_sync_u_in <= (others => (others => '0'));
    measurement_enable_b_in <= '0';
    PP20ms_b_in <= '0';
    
    s_axi_aresetn <= '0';
    -- set address to SW reset 59*4=236 (EC)
    s_axi_awaddr <= x"000000EC";
    s_axi_awprot <= (others => '0');
    s_axi_awvalid <= '1';
    s_axi_wdata <= (others => '0');
    s_axi_wstrb <= (others => '0');
    s_axi_wvalid <= '1';
    s_axi_bready <= '1';
    s_axi_araddr <= (others => '0');
    s_axi_arprot <= (others => '0');
    s_axi_arvalid <= '1';
    s_axi_rready <= '1';
        
    -- clear the AXI reset
    wait for 2*AXI_ACLK_period;
     s_axi_aresetn <= '1';
    
    -- clear the SW reset Channel 0 
    wait for 2*AXI_ACLK_period;
    s_axi_awaddr <= x"000000EC";
    s_axi_wdata <= (others => '0');
    s_axi_wstrb <= (others => '1');
    -- arm Channel 0 for start 57*4=228 (xE4)
    wait for 2*AXI_ACLK_period;
    s_axi_awaddr <= x"000000E4";
    s_axi_wdata <= (others => '0');
    s_axi_wstrb <= (others => '1'); 
    
    wait for 2*AXI_ACLK_period;
    s_axi_wstrb <= (others => '0');
    
    -- pulse the start signal
    wait for 10*AXI_ACLK_period;
        PP20ms_b_in <= '1';
    wait for AXI_ACLK_period;
        PP20ms_b_in <= '0';
        
    -- clear the SW reset Channel 1 (slave) 
        wait for 20*AXI_ACLK_period;
        s_axi_awaddr <= x"000008EC";
        s_axi_wdata <= (others => '0');
        s_axi_wstrb <= (others => '1');
        wait for 2*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0');
        
    -- arm Channel 1 for slave start 78*4=312 (x138)
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= x"00000938";
        s_axi_wdata <= (others => '1');
        s_axi_wstrb <= "0001"; 
        
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0');
        
    -- clear the SW reset Channel 2 (master) 
        wait for 20*AXI_ACLK_period;
        s_axi_awaddr <= x"000010EC";
        s_axi_wdata <= (others => '0');
        s_axi_wstrb <= (others => '1');
        wait for 2*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0');
        
        -- arm Channel 2 for start 57*4=228 (xE4)
        wait for 2*AXI_ACLK_period;
        s_axi_awaddr <= x"000010E4";
        s_axi_wdata <= (others => '0');
        s_axi_wstrb <= (others => '1'); 
        wait for 2*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0'); 
 
     -- pulse the start signal
        wait for 200*AXI_ACLK_period;
            PP20ms_b_in <= '1';
        wait for AXI_ACLK_period;
            PP20ms_b_in <= '0';
     
     -- clear the SW reset Channel 5 (master) 
        wait for 20*AXI_ACLK_period;
        s_axi_awaddr <= x"000028EC";
        s_axi_wdata <= (others => '0');
        s_axi_wstrb <= (others => '1');
        wait for 2*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0'); 
 
        -- arm Channel 5 for start 57*4=228 (xE4)
        wait for 2*AXI_ACLK_period;
        s_axi_awaddr <= x"000028E4";
        s_axi_wdata <= (others => '0');
        s_axi_wstrb <= (others => '1'); 
        wait for 2*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0'); 
        
     -- pulse the start signal
        wait for 200*AXI_ACLK_period;
            PP20ms_b_in <= '1';
        wait for AXI_ACLK_period;
            PP20ms_b_in <= '0';
                   
      -- clear the SW reset Channel 3 (slave) 
        wait for 20*AXI_ACLK_period;
        s_axi_awaddr <= x"000018EC";
        s_axi_wdata <= (others => '0');
        s_axi_wstrb <= (others => '1');
        wait for 2*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0');
      
      -- arm Channel 3 for slave start 78*4=312 (x138)
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= x"00001938";
        s_axi_wdata <= (others => '1');
        s_axi_wstrb <= "0001"; 
        
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0');  
 
       -- clear the SW reset Channel 4 (slave) 
          wait for 20*AXI_ACLK_period;
          s_axi_awaddr <= x"000020EC";
          s_axi_wdata <= (others => '0');
          s_axi_wstrb <= (others => '1');
          wait for 2*AXI_ACLK_period;
          s_axi_awaddr <= (others => '0');
          s_axi_wstrb <= (others => '0');
          s_axi_wdata <= (others => '0');
        
        -- arm Channel 4 for slave start 78*4=312 (x138)
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= x"00002138";
        s_axi_wdata <= (others => '1');
        s_axi_wstrb <= "0001"; 
        
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0');
 
       -- clear the SW reset Channel 6 (slave) 
            wait for 20*AXI_ACLK_period;
            s_axi_awaddr <= x"000030EC";
            s_axi_wdata <= (others => '0');
            s_axi_wstrb <= (others => '1');
            wait for 2*AXI_ACLK_period;
            s_axi_awaddr <= (others => '0');
            s_axi_wstrb <= (others => '0');
            s_axi_wdata <= (others => '0');
        
        -- arm Channel 6 for slave start 78*4=312 (x138)
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= x"00003138";
        s_axi_wdata <= (others => '1');
        s_axi_wstrb <= "0001"; 
        
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0');        
       
       -- clear the SW reset Channel 7 (slave) 
            wait for 20*AXI_ACLK_period;
            s_axi_awaddr <= x"000038EC";
            s_axi_wdata <= (others => '0');
            s_axi_wstrb <= (others => '1');
            wait for 2*AXI_ACLK_period;
            s_axi_awaddr <= (others => '0');
            s_axi_wstrb <= (others => '0');
            s_axi_wdata <= (others => '0');       
        -- arm Channel 7 for slave start 78*4=312 (x138)
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= x"00003938";
        s_axi_wdata <= (others => '1');
        s_axi_wstrb <= "0001"; 
        
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0');             
 
 -- clear the SW reset Channel 8 (slave) 
        wait for 20*AXI_ACLK_period;
        s_axi_awaddr <= x"000040EC";
        s_axi_wdata <= (others => '0');
        s_axi_wstrb <= (others => '1');
        wait for 2*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0'); 
         -- arm Channel 8 for slave start 78*4=312 (x138)
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= x"00004138";
        s_axi_wdata <= (others => '1');
        s_axi_wstrb <= "0001"; 
        
        wait for 4*AXI_ACLK_period;
        s_axi_awaddr <= (others => '0');
        s_axi_wstrb <= (others => '0');
        s_axi_wdata <= (others => '0');        
                   
    wait; -- will wait forever
    
   
end process;   

read_data_input :  process (sample_clk_b_in, s_axi_aresetn) is
    use STD.TEXTIO.all;
--  file F: TEXT is in "quantised_noise_fs_99p375_MHz_0p1_s.txt";  -- VHDL'87
--    file F: TEXT open READ_MODE is "quantised_noise_fs_99p375_MHz_0p1_s.txt";
    file F: TEXT open READ_MODE is "FE_fs_99p375_MHz_skip_46250_time_2001ms_int8.txt";
    variable L: LINE;
    variable value: integer;
 begin
    if (s_axi_aresetn = '0') then
        data_FE_sync_u_in <= (others => (others => '0'));
        measurement_enable_b_in <= '0';
--        measurement_count_u <= (others => '0');
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
--        -- create a faster measurement TIC than 0.1 s
--        if (measurement_count_u = (SAMPLES_PER_EPOCH_1MS_C)) then
--            measurement_count_u <= (others => '0');
--            measurement_enable_b_in <= '1';
--        else
--            measurement_count_u <= measurement_count_u + 1;
--            measurement_enable_b_in <= '0';
--        end if;
    end if;
    
end process read_data_input; 
    
end Behavioral;
