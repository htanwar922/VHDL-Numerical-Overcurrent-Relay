
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

function sfixed2ufixed(arg : sfixed; ch : choice := 0) return ufixed;	--choice 0: change sign bit to 0, choice 1: truncate sign bit choice 2: return as it is
function ufixed2sfixed(arg : ufixed) return sfixed;																																								--checked

function sm2twoc(arg : sfixed) return sfixed_2c;		--sign-magnitude to two's complement
function twoc2sm(arg : sfixed_2c) return sfixed;		--increases vector length by 1 for sign-bit
--function sfixed2signed(arg : sfixed) return ieee.numeric_std.signed;

function "+"(l,r : sfixed) return sfixed;
--function "-"(l,r : sfixed) return sfixed;
--function "*"(l,r : sfixed) return sfixed;
--function "/"(l,r : sfixed) return sfixed;
--function "abs"(arg : sfixed) return sfixed;	--append '0' to left for sign bit = '1' and leftmost = integer'low

--function join_fixed(l,r : ufixed) return ufixed;																--decimal point of r preserved


end my_fixed_package;

--============================================================================================================================================================================================

package body my_fixed_package is

function join_fixed(l,r : fixed) return fixed is
	constant high : integer := l'length + r'high;
	constant low : integer := r'low;
	variable result : fixed(high downto low);
begin
	result(high downto r'high+1) := l;
	result(r'high downto low) := r;
	return result;
end function join_fixed;

function sfixed2ufixed(arg : sfixed; ch : choice := 0) return ufixed is
	variable result : ufixed(arg'high-1 downto arg'low) := arg(arg'high-1 downto arg'low);
begin
	if(ch=0) then return fixed('0' & to_slv(arg));														--choice 0: append 0			--join_sl_fixed('0',result);
	else return result;																							--choice 1: truncate s-bit
	end if;
end function sfixed2ufixed;

function ufixed2sfixed(arg : ufixed) return sfixed is
	variable result : sfixed(arg'high+1 downto arg'low);
begin
	result := fixed('0' & to_slv(arg)); 																	--join_sl_fixed('0',arg);
	return result;
end function ufixed2sfixed;


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
		c := (a_2c(i) and b_2c(i)) or (b_2c(i) and c) or (c and a_2c(i));
	end loop;
	result(high+1) := ( a_2c(high) and (a_2c(high) xor b_2c(high)) ) or ( result(high) and (a_2c(high) xnor b_2c(high)) );		--ovf handling
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
