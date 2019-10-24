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

use std.textio.all;

package my_types is	--take arrays as downto only

type unresolved_fixed is array (integer range <>) of std_ulogic;
alias fixed is unresolved_fixed;
	subtype ufixed is fixed;
	subtype sfixed is fixed;
	
type unresolved_float is array (integer range <>) of std_ulogic;	--float is signed only
alias float is unresolved_float;
	subtype float32 is float(8 downto -23);		-- 0 (8) 0111_1111 (7:0) 0000_0000_0000_0000_0000_000 (-1:-23)
	subtype float64 is float(11 downto -52);		-- s (11) 011_1111_1111 (10:0) 0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 (-1:-52)
																-- 128 : s (15) 011_1111_1111_1111 (14:0) 0xffff_ffff_ffff_ffff_ffff_ffff_ffff (-1:-112)
type choices is range 0 to 3;

function ufixed2float32(arg : ufixed) return float32;
function sfixed2float32(arg : sfixed) return float32;
function ufixed2float64(arg : ufixed) return float64;
function sfixed2float64(arg : sfixed) return float64;

function float32_2sfixed(arg : float32) return sfixed;
function float64_2sfixed(arg : float64) return sfixed;

function sfixed2ufixed(arg : sfixed; ch : choice := 0) return ufixed;	--choice 0: change sign bit to 0, choice 1: truncate sign bit choice 2: return as it was
function ufixed2sfixed(arg : ufixed) return sfixed;

function to_sulv(arg : fixed) return std_ulogic_vector;
function to_sulv(arg : float) return std_ulogic_vector;

function leftmost(arg : ufixed) return integer; --index of leftmost '1'
function leftmost(arg : sfixed) return integer; --leftmost '1' other than sign bit

end my_types;

--============================================================================================================================================================================================

package body my_types is

function ufixed2float32(arg : ufixed) return float32 is
	variable left : integer := leftmost(arg);
	variable lim : integer;
	variable result : float32 := (8 => 0, 7 downto 0 => std_ulogic_vector(127+left), others => '0');
begin
	if(left=integer'low) then result := (others => '0');
	else
		lim := 23 when (left - arg'low > 23) else left-arg'low;
		result(-1 downto -lim) <= arg(left-1 downto left-lim);
	end if;
	return result;
end function ufixed2float32;

function sfixed2float32(arg : sfixed) return float32 is
	variable left : integer := leftmost(arg);
	variable lim : integer;
	variable result : float32 := (8 => arg(arg'high), 7 downto 0 => std_ulogic_vector(127+left), others => '0');
begin
	if(left=integer'low) then result := (others => '0');
	else
		lim := 23 when (left - arg'low > 23) else left-arg'low;
		result(-1 downto -lim) <= arg(left-1 downto left-lim);
	end if;
	return result;
end function ufixed2float32;

function ufixed2float64(arg : ufixed) return float64 is
	variable left : integer := leftmost(arg);
	variable lim : integer;
	variable result : float64 := (11 => 0, 10 downto 0 => std_ulogic_vector(1023+left), others => '0');
begin
	if(left=integer'low) then result := (others => '0');
	else
		lim := 52 when (left - arg'low > 52) else left-arg'low;
		result(-1 downto -lim) <= arg(left-1 downto left-lim);
	end if;
	return result;
end function ufixed2float64;

function sfixed2float64(arg : sfixed) return float64 is
	variable left : integer := leftmost(arg);
	variable lim : integer;
	variable result : float64 := (11 => arg(arg'high), 10 downto 0 => std_ulogic_vector(1023+left), others => '0');
begin
	if(left=integer'low) then result := (others => '0');
	else
		lim := 52 when (left - arg'low > 52) else left-arg'low;
		result(-1 downto -lim) <= arg(left-1 downto left-lim);
	end if;
	return result;
end function ufixed2float64;

function float32_2sfixed(arg : float32) return sfixed is
	variable exp : integer := to_integer(arg(7 downto 0)) - 127;
	variable result : sfixed(exp+1 downto exp-23) := (exp+1 => arg(arg'high), exp downto exp-23 => '1' & arg(-1 downto -23));
begin
	return result;
end function float32_2sfixed;

function float64_2sfixed(arg : float64) return sfixed is
	variable exp : integer := to_integer(arg(7 downto 0)) - 1023;
	variable result : sfixed(exp+1 downto exp-52) := (exp+1 => arg(arg'high), exp downto exp-52 => '1' & arg(-1 downto -52));
begin
	return result;
end function float64_2sfixed;
	
function sfixed2ufixed(arg : sfixed; ch : choice := 0) return ufixed is
	variable result : ufixed(arg'high-1 downto arg'low) := arg(arg'high-1 downto arg'low);
begin
	if(choice = 0) then return ('0' & result);
	elsif(choice=1) then return result;
	else return (arg(arg'high) & result);
	end if;
end function sfixed2ufixed;

function ufixed2sfixed(arg : ufixed) return sfixed is
	variable result : sfixed(arg'high+1 downto arg'low) := '0' & arg;
begin
	return result;
end function ufixed2sfixed;

function to_sulv(arg : fixed) return std_ulogic_vector is
begin
	return std_ulogic_vector(arg);
end function to_sulv;

function to_sulv(arg : float) return std_ulogic_vector is
begin
	return std_ulogic_vector(arg);
end function to_sulv;

function leftmost(arg : ufixed) return integer is
	variable left : integer := arg'high;
begin
	while left >= arg'low loop
		if(arg(left)='1') then return left;
		end if;
		left := left-1;
	end loop;
	return integer'low;
end function leftmost;

function leftmost(arg : sfixed) return integer is
	variable left : integer := arg'high-1;
begin
	while left >= arg'low loop
		if(arg(left)='1') then return left;
		end if;
		left := left-1;
	end loop;
	return integer'low;
end function leftmost;

end my_types;
