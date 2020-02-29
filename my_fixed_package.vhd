library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_signed.all;

use std.textio.all;

use work.my_types.all;
use work.my_functions.all;

package my_fixed_package is

function twoc(arg : sfixed) return sfixed;

function "+"(l,r : sfixed) return sfixed;	
function "-"(l,r : sfixed) return sfixed;
function "*"(l,r : sfixed) return sfixed;
function "/"(l,r : sfixed) return sfixed;

end my_fixed_package;

--============================================================================================================================================================================================

package body my_fixed_package is

function twoc(arg : sfixed) return sfixed is
	variable result : sfixed(arg'high downto arg'low) := arg;
	variable c : std_logic := '1';
	begin
		for i in arg'low to arg'high loop
			result(i) := (not arg(i)) xor c;
			c := (not arg(i)) and c;
		end loop;
	return result;
end function twoc;

function "+"(l,r : sfixed) return sfixed is
	variable hi : integer:=maximum(r'high,l'high);
	variable lo : integer:=minimum(r'low,l'low);
	variable c : std_logic := '0';
	variable result : sfixed(hi downto lo) :=(others=>'0');
	begin
		for i in lo to hi loop
			result(i) := l(i) xor r(i) xor c;
			c := (l(i) and c) or (r(i) and c) or (r(i) and l(i));
		end loop;
		if (c='1') then report "Overflow";end if;
	return result;
end function "+";

function "-"(l,r : sfixed) return sfixed is
	variable two_c_r : sfixed(r'high downto r'low);
	variable result : sfixed(l'high downto l'low);
	begin
		two_c_r :=twoc(r);
		result :=l+two_c_r;
		return result;
end function "-";
 
function "*"(l,r : sfixed) return sfixed is
	variable xr : signed(r'high-r'low downto 0) :=signed(to_slv(r(r'high downto r'low)));
	variable xl : signed(l'high-l'low downto 0) :=signed(to_slv(l(l'high downto l'low)));
	variable res: signed(xr'high+xl'high+1 downto 0);
	variable result : sfixed(r'high+l'high+1 downto r'low+l'low):=(others=>'0');
	begin
		res :=xl*xr;
		result(result'high downto result'low):=sfixed(std_logic_vector(res(res'high downto res'low)));
		return result;
end function "*";

function "/"(l,r : sfixed) return sfixed is
	variable xl : signed(l'high-l'low+10 downto 0) :=(others=>'0');
	variable xr : signed(r'high-r'low downto 0) :=signed(to_slv(r(r'high downto r'low)));
	variable res: signed(xr'high+xl'high+1 downto 0):=(others=>'0');
	variable result : sfixed(r'high+l'high+1 downto r'low+l'low):=(others=>'0');
	begin
		xl(l'high-l'low+10 downto 10):=signed(to_slv(l(l'high downto l'low)));
		res :=xl/xr;
		result(result'high downto result'low):=sfixed(std_logic_vector(res(res'high downto res'low)));
		return result;
end function "/";
 
end my_fixed_package;