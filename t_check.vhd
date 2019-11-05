
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

use std.textio.all;

use work.my_types.all;
use work.my_fixed_package.all;
use work.my_float_package.all;

entity testbench is
end testbench;

architecture behavior of testbench is
	component check
		port( a : in float(1 downto -7);
--				y : out float(6 downto -7);
--				y2 : out sfixed(7 downto -7)
				sqr : out float(0 downto -14)
			);
	end component;

	signal t_a : float(1 downto -7) := "110000000"; --"11000111100110"; --:= "11";
--	signal t_y : float(6 downto -7);
--	signal t_y2 : sfixed(7 downto -7);
	signal sqr : float(0 downto -14);
	signal clk : bit;

begin
	t_check: check port map(a => t_a,
--									y => t_y,
--									y2 => t_y2
									sqr => sqr
									);
	
	clock : process
	begin
		clk <= '0';
		wait for 10 ns;
		clk <= '1';
		wait for 10 ns;
	end process;
	
	tb : process
	begin
--		t_a <= "100000000"; --"01001111100110";
		wait for 300 ns; -- wait until global set/reset completes

		t_a <= "010011000"; --"00111010100110";
		wait for 300 ns;
		
		t_a <= "010000001"; --"00111001100110";

		wait for 1000 ns;
	end process tb;
	
end;
