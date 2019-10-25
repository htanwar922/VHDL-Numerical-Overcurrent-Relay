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
--use ieee.std_logic_unsigned.all;
--use ieee.std_logic_signed.all;

--use std.textio.all;

use work.my_functions.all;

package my_types is	--take arrays as downto only

type unresolved_fixed is array (integer range <>) of std_ulogic;	--taken in sign-magnitude representation
	subtype fixed is unresolved_fixed;
	subtype ufixed is fixed;
	subtype sfixed is fixed;
	
type unresolved_float is array (integer range <>) of std_ulogic;	--float is signed only
	subtype float is unresolved_float;
	subtype float32 is float(8 downto -23);		-- 0 (8) 0111_1111 (7:0) 0000_0000_0000_0000_0000_000 (-1:-23)
	subtype float64 is float(11 downto -52);		-- s (11) 011_1111_1111 (10:0) 0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 (-1:-52)
--	subtype float128 is float (15 downto -112);	-- 128 : s (15) 011_1111_1111_1111 (14:0) 0xffff_ffff_ffff_ffff_ffff_ffff_ffff (-1:-112)

type choice is range 0 to 3;

function ufixed2float(arg : ufixed; exp_w : natural; fract_w : natural) return float;		--input exp_w as arg'high and fract_w as -arg'low
function sfixed2float(arg : sfixed; exp_w : natural; fract_w : natural) return float;
function ufixed2float32(arg : ufixed) return float32;
function sfixed2float32(arg : sfixed) return float32;
function ufixed2float64(arg : ufixed) return float64;
function sfixed2float64(arg : sfixed) return float64;


function float2sfixed(arg : float := "00111111100000000000000000000000") return sfixed;
function float32_2sfixed(arg : float32 := "00111111100000000000000000000000") return sfixed;
function float64_2sfixed(arg : float64) return sfixed;

function sfixed2ufixed(arg : sfixed; ch : choice := 0) return ufixed;	--choice 0: change sign bit to 0, choice 1: truncate sign bit choice 2: return as it is
function ufixed2sfixed(arg : ufixed) return sfixed;

function to_slv(arg : fixed) return std_logic_vector;
function to_slv(arg : float := "00111111100000000000000000000000") return std_logic_vector;
--function sfixed2signed(arg : sfixed) return ieee.numeric_std.signed;

function leftmost(arg : ufixed) return integer; --index of leftmost '1'
function sleftmost(arg : sfixed) return integer; --leftmost '1' other than sign bit

function rebound(arg : sfixed; high,low : integer) return sfixed;

--function join_fixed(l,r : ufixed) return ufixed;		--decimal point of r preserved
--function join_sl_fixed(l : std_logic; r : ufixed) return ufixed;
--function join_float(l,r : float) return float;
--function join_sl_float(l : std_logic; r : float) return float;

end my_types;

--============================================================================================================================================================================================

package body my_types is

constant one : std_logic_vector(0 downto 0) := "1";
constant zero : std_logic_vector(0 downto 0) := "0";

function join_fixed(l,r : fixed) return fixed is
	variable high : integer := l'length + r'high;
	variable low : integer := r'low;
	variable result : fixed(high downto low);
begin
	result(high downto r'high+1) := l;
	result(r'high downto low) := r;
	return result;
end function join_fixed;

function join_sl_fixed(l : std_logic; r : fixed) return fixed is
	variable result : fixed(r'high+1 downto r'low);
begin
	result(r'high+1) := l;
	result(r'high downto r'low) := r;
	return result;
end function join_sl_fixed;

function join_float(l,r : float) return float is
	variable high : integer := l'length + r'high;
	variable low : integer := r'low;
	variable result : float(high downto low);
begin
	result(high downto r'high+1) := l;
	result(r'high downto low) := r;
	return result;
end function join_float;

function join_sl_float(l : std_logic; r : float) return float is
	variable result : float(r'high+1 downto r'low);
begin
	result(r'high+1) := l;
	result(r'high downto r'low) := r;
	return result;
end function join_sl_float;

--function conv_float2sulv(arg: integer; size: integer) return std_ulogic_vector is
--	variable result: std_ulogic_vector(size-1 downto 0);
--	variable temp: integer;
--	attribute synthesis_return of result:variable is "feed_through" ;
--begin
--	temp := arg;
--	for i in 0 to size-1 loop
--		if (temp mod 2) = 1 then
--			result(i) := '1';
--		else 
--			result(i) := '0';
--		end if;
--		if temp > 0 then
--			temp := temp / 2;
--		else
--			temp := (temp - 1) / 2;
--		end if;
--	end loop;
--	return result;
--end;

function rebound(arg : sfixed; high,low : integer) return sfixed is
	variable result : sfixed(high downto low) := (others => '0');
	variable len : integer := minimum(high-low+1, arg'length);
begin
	result(high) := arg(arg'high);
	result(high-1 downto high-1-len) := arg(arg'high-1 downto arg'high-1-len);
	return result;
end function rebound;

function ufixed2float(arg : ufixed; exp_w : natural; fract_w : natural) return float is
	variable result : float(exp_w downto -fract_w);
begin
	result := sfixed2float(join_sl_fixed('0',arg), exp_w, fract_w);
	return result;
end function ufixed2float;

function sfixed2float(arg : sfixed; exp_w : natural; fract_w : natural) return float is
	variable left : integer := sleftmost(arg);
	variable lim : integer;
	variable ubase : ieee.numeric_std.unsigned(exp_w-1 downto 0) := (others => '1');
	variable exp_base : natural;
	variable exp : integer;
	variable result : float(exp_w downto -fract_w) := (others => '0');
	variable exparg : std_logic_vector(exp_w-1 downto 0);
	variable argslv : std_logic_vector(arg'length-1 downto 0);
begin
	ubase(exp_w-1) := '0';
	exp_base := to_integer(ubase);
	exp := exp_base+left;
	exparg := conv_std_logic_vector(exp, exp_w);
	argslv := to_slv(arg);
	result(exp_w) := arg(arg'high);
	result(exp_w-1 downto 0) := float(exparg(exp_w-1 downto 0));
	if(left > exp_base) then
		result(-1 downto -fract_w)  := (others => '0');
      result(exp_w-1 downto 0) := (others => '1');
      return result;
	end if;
	if(left=integer'low) then
		result := (others => '0');
		return result;
	else
		if(left - arg'low > fract_w) then lim := fract_w;
		else lim := left-arg'low;
		end if;
		result(-1 downto -lim) := float(argslv(arg'length+left-1 downto arg'length+left-lim));
	end if;
	return result;
end function sfixed2float;	
	
function ufixed2float32(arg : ufixed) return float32 is
	variable result : float32;
begin
	result := ufixed2float(arg,8,23);
	return result;
end function ufixed2float32;

function sfixed2float32(arg : sfixed) return float32 is
	variable result : float32 := (others => '0');
begin
	result := sfixed2float(arg, 8, 23);
	return result;
end function sfixed2float32;

function ufixed2float64(arg : ufixed) return float64 is
	variable result : float64 := (others => '0');
begin
	result := ufixed2float(arg,12,52);
	return result;
end function ufixed2float64;

function sfixed2float64(arg : sfixed) return float64 is
	variable result : float64 := (others => '0');
begin
	result := sfixed2float(arg,12,52);
	return result;
end function sfixed2float64;

function float2sfixed(arg : float := "00111111100000000000000000000000") return sfixed is
	variable exp : integer := 0;
	variable ubase : ieee.numeric_std.unsigned(arg'high-1 downto 0) := ieee.numeric_std.unsigned(to_slv(arg(arg'high-1 downto 0)));
	variable exp_base : natural := to_integer(ubase);
	variable result : sfixed(exp+1 downto exp-23) := (others => '0');
	
begin
	result(exp+1) := arg(arg'high);
	result(exp downto exp+arg'low) := sfixed(to_slv(join_sl_float(std_logic'('1'), arg(-1 downto arg'low))));
	exp := to_integer(ieee.numeric_std.unsigned(to_slv(arg(arg'high-1 downto 0)))) - exp_base;
	result := rebound(result, exp+1, exp+arg'low);
	return result;
end function float2sfixed;

function float32_2sfixed(arg : float32 := "00111111100000000000000000000000") return sfixed is
	variable exp : integer := 0;
	variable result : sfixed(exp+1 downto exp-23) := (others => '0');
begin
	result := float2sfixed(arg);
	return result;
end function float32_2sfixed;

function float64_2sfixed(arg : float64) return sfixed is
	variable exp : integer := 0;
	variable result : sfixed(exp+1 downto exp-52) := (others => '0');
begin
	result(exp+1) := arg(arg'high);
	result(exp downto exp-52) := sfixed(to_slv(join_sl_float(std_logic'('1'), arg(-1 downto -52))));
	exp := to_integer(ieee.numeric_std.unsigned(to_slv(arg(10 downto 0)))) - 1023;
	result := rebound(result, exp+1, exp-52);
	return result;
end function float64_2sfixed;
	
function sfixed2ufixed(arg : sfixed; ch : choice := 0) return ufixed is
	variable result : ufixed(arg'high-1 downto arg'low) := arg(arg'high-1 downto arg'low);
begin
	if(ch=0) then return join_sl_fixed('0',result);		--append 0
	elsif(ch=1) then return result;				--truncate s-bit
	else return join_sl_fixed(arg(arg'high), result);		--return as it is
	end if;
end function sfixed2ufixed;

function ufixed2sfixed(arg : ufixed) return sfixed is
	variable result : sfixed(arg'high+1 downto arg'low);
begin
	result := join_sl_fixed('0',arg);
	return result;
end function ufixed2sfixed;

function to_slv(arg : fixed) return std_logic_vector is
		variable result : std_logic_vector(arg'length-1 downto 0);
begin
	result := std_logic_vector(arg);
	return result;
end function to_slv;

function to_slv(arg : float := "00111111100000000000000000000000") return std_logic_vector is
	variable result : std_logic_vector(arg'length-1 downto 0);
begin
	result := std_logic_vector(arg);
	return result;
end function to_slv;

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

function sleftmost(arg : sfixed) return integer is
	variable left : integer := arg'high-1;
begin
	while left >= arg'low loop
		if(arg(left)='1') then return left;
		end if;
		left := left-1;
	end loop;
	return integer'low;
end function sleftmost;

end my_types;
