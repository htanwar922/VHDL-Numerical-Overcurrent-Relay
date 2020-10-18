
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
		port(
            a : in float(7 downto -10) := b"0_1000001_0111000000";
            p : in sfixed(3 downto -3) := b"0_111_101";
            y : out float(7 downto -10)
		);
	end component;

	signal t_a : float(7 downto -10) := b"0_1000001_0111000000";
	signal t_p : sfixed(3 downto -3) := b"0_111_101";
	signal t_y : float(7 downto -10);
	signal clk : std_logic;

begin
	t_check: check
	port map(
        a => t_a,
        p => t_p,
        y => t_y
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

		t_a <= b"0_1000010_0111000000"; --"00111010100110";
		wait for 300 ns;
		
		t_a <= b"0_1000011_0111000000"; --"00111001100110";

		wait for 1000 ns;
	end process tb;
	
end;
