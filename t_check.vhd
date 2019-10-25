
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
		port( a : in ufixed(4 downto -4) := "001100011";
				y : out float(5 downto -3)
			);
	end component;

	signal t_a : ufixed(4 downto -4) := "001100011";
	signal t_y : float(5 downto -3);

begin
	uut: check port map(a => t_a, y => t_y);

	tb : process
	begin

		wait for 1000 ns; -- wait until global set/reset completes

		t_a <= "101101101";

		wait; -- will wait forever
	end process tb;
	
end;
