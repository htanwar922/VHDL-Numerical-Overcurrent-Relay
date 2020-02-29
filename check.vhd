
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.my_functions.all;
use work.my_types.all;
use work.my_fixed_package.all;
use work.my_float_package.all;


entity check is
	port(	a : in float(7 downto -10) := b"0_1000001_0111000000";
--			b : in float(4 downto -5) := b"1_0000_00000";
			p : in sfixed(3 downto -3) := b"0_111_101";
			y1 : out float(7 downto -10);
--			y2 : out float(7 downto -10);
			z : out boolean := false
		);
end check;

architecture behavioral of check is
	signal p2 : sfixed(3 downto -3) := b"0_010_000";
--	signal sqrt3 : float(7 downto -10);
begin
--	process(b)
--	begin
--		if(check_float(abs(a))=zero) then  z <= true; end if;
--	end process;
	z <= check_float(abs(a))=nan;
	y1 <= pow(a,p); --a*a;
	print(a);
	print(pow(a,p2));
--	sqrt3 <= sqrt(sqrt(sqrt(a)));
--	y2 <= a*a*a*a*a*a*a*sq(sq(sqrt(sqrt(sqrt(a)))))*sqrt(sqrt(sqrt(a)));
--	writeproc(to_slv(y));
end behavioral;
