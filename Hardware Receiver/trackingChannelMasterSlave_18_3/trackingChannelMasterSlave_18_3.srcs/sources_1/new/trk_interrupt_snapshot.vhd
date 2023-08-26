LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

use work.receiverConfigurationPackage.all;

ENTITY trk_interrupt_snapshot IS
Port(
	clk_b_in		 	   : in std_logic;
	reset_b_in		 	   : in std_logic;	
	trk_interrupt_a_in	   : in trk_interrupt_type;
	clr_snap_a_in	       : in trk_interrupt_type;
	snapshot_a_out	 	   : out trk_interrupt_type;
	missed_snap_cnt_a_out  : out miss_interrupt_type		
);
END trk_interrupt_snapshot;

Architecture struct of  trk_interrupt_snapshot is
begin

Snapshot_module_gen : for i in 0 to (c_NUMBER_OF_TRACKERS - 1) generate
		snapshot_i : entity  work.snapshot_module
			Generic map( missed_cnt_size_g => MISS_INT_CNT_SIZE_C)
			
			Port map(
				clk_b_in		 => clk_b_in,
				reset_b_in		 => reset_b_in,
				interrupt_b_in	 => trk_interrupt_a_in(i),
				clr_snap_b_in	 => clr_snap_a_in(i),
				
				snapshot_b_out	 		=> snapshot_a_out(i),
				missed_snap_cnt_u_out 	=> missed_snap_cnt_a_out(i)
			);
	end generate;

end architecture;