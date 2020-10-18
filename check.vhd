
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.my_functions.all;
use work.my_types.all;
--use work.my_fixed_package.all;
use work.my_float_package.all;


entity check is
	port(	a : in float(7 downto -10) := b"0_1000001_0111000000";
			p : in sfixed(3 downto -3) := b"0_111_101";
			y1 : out float(7 downto -10)
		);
end check;

architecture behavioral of check is
begin
	process(a, p)
	begin
	   y1 <= pow(a,p);
	end process;
end behavioral;
