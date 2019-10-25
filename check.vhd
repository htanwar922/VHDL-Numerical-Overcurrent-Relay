
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;

use std.textio.all;

use work.my_types.all;
use work.my_fixed_package.all;

entity check is
	port(a : in ufixed(4 downto -4) := "001100011";
			y : out float(5 downto -3)
		);
end check;

architecture behavioral of check is

begin
	y <= ufixed2float(a,y'high,-y'low);

end behavioral;
