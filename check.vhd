
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

use std.textio.all;

use work.my_types.all;
use work.my_fixed_package.all;
use work.my_float_package.all;

entity check is
	port(a : in float(6 downto -7); --:= "001100011";
			y : out float(6 downto -7);
			y2 : out sfixed(7 downto -7)
		);
end check;

architecture behavioral of check is
	signal yx : sfixed(7 downto -7);
begin
	yx <= float2sfixed(a,7,-7,0,0);
	y2 <= yx;
	y <= sfixed2float(yx,6,7);
end behavioral;
