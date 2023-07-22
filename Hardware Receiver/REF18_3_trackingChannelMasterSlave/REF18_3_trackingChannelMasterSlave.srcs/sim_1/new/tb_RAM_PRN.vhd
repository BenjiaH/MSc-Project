----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.07.2023 17:43:00
-- Design Name: 
-- Module Name: tb_RAM_PRN - tb
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

use work.receiverConfigurationPackage.all;

entity tb_RAM_PRN is
--  Port ( );
end tb_RAM_PRN;

architecture tb of tb_RAM_PRN is

--I/O signal
signal tb_clka_ab_in       : std_logic;
signal tb_clkb_b_in        : std_logic;
signal tb_wea_b_in         : std_logic;
signal tb_ena_b_in         : std_logic; 
signal tb_enb_b_in         : std_logic;
signal tb_addra_u_in       : std_logic_vector((ADDR_LEN_WORDS_E5a_I_C - 1) downto 0); 
signal tb_addrb_u_in       : std_logic_vector((ADDR_LEN_WORDS_E5a_I_C - 1) downto 0); 
--signal tb_addrb_u_in       : std_logic_vector(code_chip_count_u(code_chip_count_u'left downto WORD_ADDR_BITS_I_C)); 
signal tb_dia_u_in         : std_logic_vector((REG_WIDTH_C - 1) downto 0);
signal tb_doa_u_out        : std_logic_vector((REG_WIDTH_C - 1) downto 0);
signal tb_dob_u_out        : std_logic_vector((REG_WIDTH_C - 1) downto 0);

-- Internal signal
signal code_chip_count_u   : unsigned((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
signal code_len_chip_u_in  : std_logic_vector((MAX_CHIP_COUNT_LENGTH_C - 1) downto 0);
signal addrb_en_b           : std_logic;
signal addrb_rst_b          : std_logic;


constant half_period : time := 5031 ns;

begin

    uut: entity work.RAM_PRN
    port map ( clka_b_in    => tb_clka_ab_in,
               clkb_b_in    => tb_clka_ab_in,
               wea_b_in     => tb_wea_b_in,
               ena_b_in     => tb_ena_b_in,
               enb_b_in     => tb_enb_b_in,
               addra_u_in   => tb_addra_u_in,
               addrb_u_in   => tb_addrb_u_in,
--               addrb_u_in   => std_logic_vector(code_chip_count_u(code_chip_count_u'left downto WORD_ADDR_BITS_I_C)),
               dia_u_in     => tb_dia_u_in,
               doa_u_out    => tb_doa_u_out,
               dob_u_out    => tb_dob_u_out
           );
    
    code_len_chip_u_in <= std_logic_vector(to_unsigned(CODE_LENGTH_CA_C, MAX_CHIP_COUNT_LENGTH_C));       
    
    process (tb_clka_ab_in)
    begin
    if rising_edge(tb_clka_ab_in) then
--        if (code_chip_count_u = (unsigned(code_len_chip_u_in) - 1)) then
--            -- reset the chip counter
--            code_chip_count_u <= (others=>'0');
--        else
--            code_chip_count_u <= code_chip_count_u + 1;
--        end if;
        
        if (addrb_rst_b = '1') then
            tb_addrb_u_in <= (others=>'0');
        elsif (addrb_en_b = '1') then
            tb_addrb_u_in <= std_logic_vector(unsigned(tb_addrb_u_in) + 1);
        else
            tb_addrb_u_in <= tb_addrb_u_in;
        end if;
    end if;
    end process;   
     
    -- clock process for tb_clka_ab_in, 99.38382MHz
    clock_gen : PROCESS
        BEGIN
            CLOCK_LOOP : LOOP
            tb_clka_ab_in <= '1';
            WAIT FOR half_period;
            tb_clka_ab_in <= '0';
            WAIT FOR half_period;
            END LOOP CLOCK_LOOP;
    END PROCESS clock_gen;
    
    tb : PROCESS
    BEGIN
    addrb_rst_b <= '1';
    wait for 20 * half_period;
    -- asignments
    tb_wea_b_in <= '0';
    tb_ena_b_in <= '0';
    tb_enb_b_in <= '0';
    addrb_rst_b <= '0';
--    tb_addra_u_in <= (others => '0');
--    tb_dia_u_in <= (others => '0');
    addrb_en_b <= '0';
    
    wait for 2500 ns;
    tb_enb_b_in <= '1';
    addrb_en_b <= '1';

    wait; -- will wait forever
    end process;	

end tb;
