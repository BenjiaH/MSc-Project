LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY snapshot_module IS
Generic( missed_cnt_size_g : integer:= 8);
Port(
	clk_b_in		 : in std_logic;
	reset_b_in		 : in std_logic;	
	interrupt_b_in	 : in std_logic;
	clr_snap_b_in	 : in std_logic;
	
	snapshot_b_out	 		: out std_logic;
	missed_snap_cnt_u_out 	: out std_logic_vector(missed_cnt_size_g-1 downto 0)	
);
END entity ;

ARCHITECTURE behav OF snapshot_module IS

signal missed_snap_cnt_u		: unsigned(missed_cnt_size_g - 1 downto 0);
signal snapshot_b	 			: std_logic;
signal clr_snap_b_flag			: std_logic;

BEGIN

process(clk_b_in) is
begin
	if rising_edge(clk_b_in) then
		if reset_b_in = '1' then
			missed_snap_cnt_u <= (others => '0');
			snapshot_b    <= '0';
		else
			-- handle the interrupt
			-- it has an higher priority
			if interrupt_b_in = '1' then		
				-- increment the missed interrupt if necessary
				if snapshot_b = '0' then
					snapshot_b <= '1';
				else
					missed_snap_cnt_u <= missed_snap_cnt_u + 1;
				end if;
			end if;

			-- handle the interrupt clear
			if clr_snap_b_in = '1' then
				clr_snap_b_flag   <= '1';
			end if;

			if clr_snap_b_flag = '1' and interrupt_b_in = '0' then
				clr_snap_b_flag   <= '0';
				snapshot_b		  <= '0';
				missed_snap_cnt_u <= (others => '0');
			end if;			
			
		end if;
	end if;
end process;

snapshot_b_out			 <= snapshot_b;
missed_snap_cnt_u_out	 <= std_logic_vector(missed_snap_cnt_u);

END ARCHITECTURE;
