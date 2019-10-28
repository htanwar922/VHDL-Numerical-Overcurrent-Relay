
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;

use std.textio.all;

use work.my_types.all;
use work.my_functions.all;

package my_float_package is

--function float(sfixed)

function join_float(l,r : float) return float;


end my_float_package;

package body my_float_package is

function join_float(l,r : float) return float is
	variable high : integer := l'length + r'high;
	variable low : integer := r'low;
	variable result : float(high downto low);
begin
	result(high downto r'high+1) := l;
	result(r'high downto low) := r;
	return result;
end function join_float;

 
end my_float_package;
