--***************************************************************************
--* Subsystem:  accumulators
--* Filename:  coh_accm_RAM.vhd   
--* Author: P. BLUNT      
--* Date Created: 04/09/18
--*
--***************************************************************************
--* DESCRIPTION
--*
--* Purpose           : This block infers a RAM block for the tracking channel
--*                     generated from the Xilinx design guide UG626 (v 13.1)
--* Limitations       : 
--*
--* Dependencies      : receiverConfigurationPackage.vhd
--*
--* Generics/Constants: 
--*
--* Inputs            : clka - clock input port a
--*                     clkb - clock input port b 
--*                     we - write enable
--*                     ena - RAM enable port a
--*                     enb - RAM enable port b
--*                     addra - address port a 
--*                     addrb - address port b 
--*                     dia - data input 
--*                     
--* Outputs           : doa - data output port a
--*                     dob - data output port b
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
use work.receiverConfigurationPackage.all;

entity RAM_PRN is
port (  clka_b_in        : in std_logic;
        clkb_b_in        : in std_logic;
        wea_b_in         : in std_logic;
        ena_b_in         : in std_logic; 
        enb_b_in         : in std_logic;
        addra_u_in       : in std_logic_vector((ADDR_LEN_WORDS_E5a_I_C - 1) downto 0); 
        addrb_u_in       : in std_logic_vector((ADDR_LEN_WORDS_E5a_I_C - 1) downto 0); 
        dia_u_in         : in std_logic_vector((REG_WIDTH_C - 1) downto 0);
        doa_u_out         : out std_logic_vector((REG_WIDTH_C - 1) downto 0);
        dob_u_out         : out std_logic_vector((REG_WIDTH_C - 1) downto 0));
end RAM_PRN;

architecture syn of RAM_PRN is

--signal RAM : track_code_ram_type := CODE_PRN1_ROM_CA_C;
signal RAM : track_code_ram_type := CODE_PRN2_ROM_CA_C;

begin

process (clka_b_in)
begin
    if clka_b_in'event and clka_b_in = '1' then
        if ena_b_in = '1' then
            if wea_b_in = '1' then
                RAM(to_integer(unsigned(addra_u_in))) <= dia_u_in;
            end if;
        doa_u_out <= RAM(to_integer(unsigned(addra_u_in))) ;
        end if;
    end if;
end process;

process (clkb_b_in)
begin
    if clkb_b_in'event and clkb_b_in = '1' then
        if enb_b_in = '1' then
            dob_u_out <= RAM(to_integer(unsigned(addrb_u_in))) ;
        end if;
    end if;
end process;
end syn;
