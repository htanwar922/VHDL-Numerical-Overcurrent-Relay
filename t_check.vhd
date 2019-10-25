
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

use std.textio.all;

use work.my_types.all;
use work.my_fixed_package.all;

entity testbench is
end testbench;

architecture behavior of testbench is
	component check
		port( a : in ufixed(4 downto -4);
				y : out float(5 downto -3)
			);
	end component;

	signal t_a : ufixed(4 downto -4) := "001100011";
	signal t_y : float(5 downto -3);
	signal clk : bit;

begin
	t_check: check port map(a => t_a, y => t_y);
	
	clock : process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;
	
	tb : process
	begin
		--t_a := "001100011";
		wait for 1000 ns; -- wait until global set/reset completes

		t_a <= "101101101";

		wait for 1000 us; -- will wait forever
	end process tb;
	
end;
