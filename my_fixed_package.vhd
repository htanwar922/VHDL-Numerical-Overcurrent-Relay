--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;

use std.textio.all;

use work.my_types.all;
use work.my_functions.all;

package my_fixed_package is

subtype sfixed_2c is fixed;

function sm2twoc(arg : sfixed) return sfixed_2c;		--sign-magnitude to two's complement
function twoc2sm(arg : sfixed_2c) return sfixed;		--increases vector length by 1 for sign-bit

function "+"(l,r : sfixed) return sfixed;
--function "-"(l,r : sfixed) return sfixed;
--function "*"(l,r : sfixed) return sfixed;
--function "/"(l,r : sfixed) return sfixed;
--function "abs"(arg : sfixed) return sfixed;	--append '0' to left for sign bit = '1' and leftmost = integer'low

end my_fixed_package;

--============================================================================================================================================================================================

package body my_fixed_package is

function sm2twoc(arg : sfixed) return sfixed_2c is
	variable result : sfixed(arg'high downto arg'low) := arg;
	variable c : std_logic := '1';
begin
	if(arg(arg'high)='1') then
		result(arg'high) := '0';
		for i in arg'low to arg'high loop
			result(i) := (not arg(i)) xor c;
			c := (not arg(i)) and c;
		end loop;
	end if;
	return result;
end function sm2twoc;

function twoc2sm(arg : sfixed_2c) return sfixed is
	variable result : sfixed(arg'high downto arg'low) := arg;
	variable c : std_logic := '1';
begin
	if(arg(arg'high)='1') then
		result(arg'high) := '0';
		for i in arg'low to arg'high loop
			result(i) := (not arg(i)) xor c;
			c := (not arg(i)) and c;
		end loop;
	end if;
	return (arg(arg'high) & result);
end function twoc2sm;

function add_sfixed(a,b : sfixed; cin : std_logic :='0') return sfixed is
	variable high : integer := maximum(a'high,b'high)+1;
	variable low : integer := minimum(a'low,b'low);
	variable result : sfixed(high+1 downto low);
	variable a_2c : sfixed_2c(high downto low) := sm2twoc(a);
	variable b_2c : sfixed_2c(high downto low) := sm2twoc(b);
	variable c : std_logic := cin;
--	variable ovf_adjust : boolean := a(a'high) xnor b(b'high);
begin
	for i in low to high loop
		result(i) := a(i) xor b(i) xor c;
		c := (a(i) and b(i)) or (b(i) and c) or (c and a(i));
	end loop;
	result(high+1) := c;
	result := twoc2sm(result);
	return result;
end function add_sfixed;

--function "abs"(arg : sfixed) return sfixed is
--	constant left_index  : integer := arg'high;
--	constant right_index : integer := minimum(arg'low, arg'low);
--	variable ressns      : ieee.numeric_std.signed (arg'length downto 0);
--	variable result      : sfixed (left_index+1 downto right_index);
--begin
--	ressns (arg'length-1 downto 0) := to_s (cleanvec (arg));
--	ressns (arg'length)            := ressns (arg'length-1);  -- expand sign bit
--	result                         := to_fixed (abs(ressns), left_index+1, right_index);
--	return result;
--end function "abs";

function "+"(l,r : sfixed) return sfixed is
	variable high : integer := maximum(l'high,r'high)+1;
	variable low : integer := minimum(l'low,r'low);
	variable result : sfixed(high+1 downto low);
begin
	result := add_sfixed(l,r);
	return result;
end function "+";
 
end my_fixed_package;
