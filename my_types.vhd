
library ieee;
use ieee.std_logic_1164.all;

entity my_entity is
	port(a : in std_logic; y : out std_logic);
end entity;

architecture my_arch of my_entity is
begin
	y<=a when a='1' else 'X';
end architecture;

-----------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.my_functions.all;

package my_types is																										--take arrays as downto only

type unresolved_decimal is array (integer range <>) of std_ulogic;
alias decimal is unresolved_decimal;

subtype unresolved_fixed is decimal;											--taken in sign-magnitude representation --numbers with negative starting index treat as unsigned or positive
	subtype fixed is unresolved_fixed;
	subtype ufixed is fixed;
	subtype sfixed is fixed;
	
subtype unresolved_float is decimal;											--float is signed only
	subtype float is unresolved_float;
	subtype float32 is float(8 downto -23);																		-- 0 (8) 0111_1111 (7:0) 0000_0000_0000_0000_0000_000 (-1:-23)
	subtype float64 is float(11 downto -52);																		-- s (11) 011_1111_1111 (10:0) 0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 (-1:-52)
--	subtype float128 is float (15 downto -112);																	-- 128 : s (15) 011_1111_1111_1111 (14:0) 0xffff_ffff_ffff_ffff_ffff_ffff_ffff (-1:-112)

type choice is range 0 to 3;

-----------------------------------------------------------------------------------------------------------------------------------

function ufixed2float(arg : ufixed; exp_w : natural; fract_w : natural) return float;				--input exp_w as arg'high and fract_w as -arg'low
function sfixed2float(arg : sfixed; exp_w : natural; fract_w : natural) return float;
function ufixed2float32(arg : ufixed) return float32;
function sfixed2float32(arg : sfixed) return float32;
function ufixed2float64(arg : ufixed) return float64;
function sfixed2float64(arg : sfixed) return float64;																																								--checked

-----------------------------------------------------------------------------------------------------------------------------------

function float2sfixed(arg : float; high, low : integer; ch_round : choice := 0; ch_ovf : choice := 0) return sfixed;
function float32_2sfixed(arg : float32; high, low : integer;  ch_round : choice := 0; ch_ovf : choice := 0) return sfixed;
function float64_2sfixed(arg : float64; high, low : integer;  ch_round : choice := 0; ch_ovf : choice := 0) return sfixed;																																--checked

-----------------------------------------------------------------------------------------------------------------------------------

function to_slv(arg : decimal) return std_logic_vector;

-----------------------------------------------------------------------------------------------------------------------------------

function leftmost(arg : ufixed) return integer; --index of leftmost '1'
function sleftmost(arg : sfixed) return integer; --leftmost '1' other than sign bit																														--checked

-----------------------------------------------------------------------------------------------------------------------------------

function uresize(arg : fixed; high,low : integer; ch_round : choice := 0; ch_ovf : choice := 0) return fixed;		--round: choice 0: round-truncate, choice 1: round-fixed; ovf : choice 0: truncate, choice 1: saturate
function rebound(arg : sfixed; high,low : integer) return sfixed;											--higher bound have same bits, zeros appended to lower							--checked
--function join_sl_fixed(l : std_logic; r : ufixed) return ufixed;										--decimal point of r preserved
--function join_sl_float(l : std_logic; r : float) return float;
function and_reduce(arg : fixed) return std_logic;
function or_reduce(arg : fixed) return std_logic;
function round(arg : fixed; index : integer; ch : choice := 0) return fixed;							--fixed treated as unsigned; choice 0: round wrt index-1, choice 1: just add 1

end my_types;

--============================================================================================================================================================================================

package body my_types is

function join_sl_fixed(l : std_logic; r : fixed) return fixed is
	variable result : fixed(r'high+1 downto r'low);
begin
	result(r'high+1) := l;
	result(r'high downto r'low) := r;
	return result;
end function join_sl_fixed;

function join_sl_float(l : std_logic; r : float) return float is
	variable result : float(r'high+1 downto r'low);
begin
	result(r'high+1) := l;
	result(r'high downto r'low) := r;
	return result;
end function join_sl_float;

function and_reduce(arg : fixed) return std_logic is
	variable res : std_logic := '1';
begin
--	report "and_reduce";
	if(arg'length < 0) then return '0'; end if;
	for i in arg'low to arg'high loop
		res := res and arg(i);
	end loop;
	return res;
end function and_reduce;

function or_reduce(arg : fixed) return std_logic is
	variable res : std_logic := '0';
begin
--	report "or_reduce";
	if(arg'length < 0) then return '1'; end if;
	for i in arg'low to arg'high loop
		res := res or arg(i);
	end loop;
	return res;
end function or_reduce;

-----------------------------------------------------------------------------------------------------------------------------------

function round(arg : fixed; index : integer; ch : choice := 0) return fixed is				--fixed treated as unsigned; choice 0: round wrt index-1, choice 1: just add 1
	variable result : fixed(arg'high downto index) := arg(arg'high downto index);
	function add_carry(ar : fixed; cin : std_logic) return fixed is
			variable res : fixed(ar'range) := ar;
			variable c : std_logic := cin;
		begin
			for i in ar'low to ar'high loop
				res(i) := ar(i) xor c;
				c := ar(i) and c;
			end loop;
			return res;
	end function add_carry;
begin
--	report "round fn";
	if(index > arg'low and ch = 0) then result := add_carry(result,arg(index-1));
	elsif(ch = 1) then result := add_carry(result,'1');
	end if;
	return result;
end function round;

function rebound(arg : sfixed; high,low : integer) return sfixed is
	variable result : sfixed(high downto low) := (others => '0');
	variable len : integer := minimum(high-low+1, arg'length);
begin
--	report "rebound";
	result(high) := arg(arg'high);
	result(high-1 downto high+1-len) := arg(arg'high-1 downto arg'high+1-len);
	return result;
end function rebound;

function urebound(arg : decimal; high,low : integer) return decimal is
	variable result : decimal(high downto low) := (others => '0');
	variable len : integer := minimum(high-low+1, arg'length);
begin
	result(high downto high+1-len) := arg(arg'high-1 downto arg'high+1-len);
	return result;
end function urebound;

-----------------------------------------------------------------------------------------------------------------------------------

function uresize(arg : fixed; high,low : integer; ch_round : choice := 0; ch_ovf : choice := 0) return fixed is	--round: choice 0: round-truncate, choice 1: round-fixed; ovf : choice 0: truncate, choice 1: saturate
	variable or_arg : std_logic := '0';
	constant h : integer := minimum(high, arg'high);
	constant l : integer := maximum(low, arg'low);
	constant h_b : natural := high-low+1;
	constant l_b : natural := 0;
	variable result : fixed(h_b downto l_b) := (others => '0');
begin
--	report "arg high in uresize is  " & integer'image(arg'high);
	if(h >= l) then result(h-low downto l-low) := arg(h downto l); end if;
	if(high < arg'high) then																									--check ovf
		if(ch_ovf = 0) then null; --report "ovf truncate";																--truncate
		else
			if(or_reduce(arg(arg'high downto high+1)) = '1') then
				result(high-low downto low-low) := (others => '1'); return result;	--report "saturate";				--saturate
			end if;
		end if;
		if(ch_round = 0) then null; --report "round truncate";														--round-truncate
		elsif(l /= arg'low) then result(h-low downto l-low) := round(arg(h downto arg'low),l); 						--round-fixed iff it is needed		--report "round fixed";
		else null;
		end if;
	else																																--no ovf
		if(ch_round = 0) then null; --report "round truncate 2";														--round-truncate
		elsif(l /= arg'low and and_reduce(arg(h downto l)) = '0') then result(high-low downto l-low) := round(arg(h downto l-1),l);
--			report "round fixed 2";																								--round-fixed iff it is needed and possible as well without ovf error (the exception is for all '1' case)
		else null;
		end if;
	end if;
	return result;
end function uresize;

-----------------------------------------------------------------------------------------------------------------------------------

function ufixed2float(arg : ufixed; exp_w : natural; fract_w : natural) return float is
begin
	return sfixed2float(fixed('0' & to_slv(arg)), exp_w, fract_w);																					--join_sl_fixed('0',arg)
end function ufixed2float;

function sfixed2float(arg : sfixed; exp_w : natural; fract_w : natural) return float is					--result may deviate from actual expected for "(0/1)11111..." type arg if it is being derived from its reverse conversion function
	variable left : integer := sleftmost(arg);
	variable lim : integer;
	variable ubase : unsigned(exp_w-1 downto 0) := (others => '1');
	variable exp_base : natural := 0;
	variable exp : integer;
	variable result : float(exp_w downto -fract_w) := (others => '0');
	variable exp_arg : std_logic_vector(exp_w-1 downto 0);
begin
	if(left=integer'low) then
		result := (others => '0');
		return result;
	end if;
	ubase(exp_w-1) := '0'; exp_base := to_integer(ubase); exp := exp_base+left;
	exp_arg := std_logic_vector(to_unsigned(exp, exp_w));
	result(exp_w) := arg(arg'high); result(exp_w-1 downto 0) := float(exp_arg(exp_w-1 downto 0));
	if(left > exp_base) then																											--return infinity
		result(-1 downto -fract_w)  := (others => '0');
      result(exp_w-1 downto 0) := (others => '1');
      return result;
	end if;
	lim := minimum(left-arg'low,fract_w);																							--1 less than actual length in former case to account for '1' preceeding the decimal in scientific notation; fract_w is already 1 less for the same purpose
	result(-1 downto -lim) := float(to_slv(urebound(uresize(arg(left-1 downto arg'low), left-1, left-lim, 1, 1),-1,-lim))); 	--float(arg_slv(-arg'low+left-1 downto -arg'low+left-lim)); float(to_slv(round(arg(left-1 downto arg'low), left-lim))); 
	if(arg'high < 0) then result(exp_w) := '0'; end if;																		--numbers with negative starting index treat as unsigned
	return result;
end function sfixed2float;

function ufixed2float32(arg : ufixed) return float32 is
begin
	return ufixed2float('0' & arg,8,23);
end function ufixed2float32;

function sfixed2float32(arg : sfixed) return float32 is
begin
	return float32(sfixed2float(arg, 8, 23));
end function sfixed2float32;

function ufixed2float64(arg : ufixed) return float64 is
begin
	return ufixed2float('0' & arg,11,52);
end function ufixed2float64;

function sfixed2float64(arg : sfixed) return float64 is
begin
	return sfixed2float(arg,11,52);
end function sfixed2float64;

-----------------------------------------------------------------------------------------------------------------------------------

function float2sfixed(arg : float; high, low : integer; ch_round : choice := 0; ch_ovf : choice := 0) return sfixed is
	variable ubase : std_logic_vector(arg'high-1 downto 0) := (others => '1');
	variable exp_base : natural;
	variable exp : integer;
	variable result : sfixed(high downto low) := (others => '0');
	variable arg_sfx : sfixed(arg'high downto arg'low) := sfixed(to_slv(arg));
begin
	ubase(arg'high-1) := '0';	exp_base := to_integer(ieee.numeric_std.unsigned(ubase));
	exp := to_integer(ieee.numeric_std.unsigned(to_slv(arg(arg'high-1 downto 0)))) - exp_base;
	result(high) := arg(arg'high);
	if(exp > high-1) then result(high-1 downto low) := (others => '1'); --report "saturate";				--saturate signed
	elsif(exp < low) then null; --report "zero";																			--all '0' signed
	else
		result(exp) := '1'; null; --report "rounding now";
		result(exp-1 downto low) := urebound(uresize(arg_sfx(-1 downto arg'low),-1,low-exp,ch_round,ch_ovf),exp-1,low);
	end if;
	return result;
end function float2sfixed;

function float32_2sfixed(arg : float32; high, low : integer;  ch_round : choice := 0; ch_ovf : choice := 0) return sfixed is
begin
	return float2sfixed(arg,high,low,ch_round,ch_ovf);
end function float32_2sfixed;

function float64_2sfixed(arg : float64; high, low : integer;  ch_round : choice := 0; ch_ovf : choice := 0) return sfixed is
begin
	return float2sfixed(arg,high,low,ch_round,ch_ovf);
end function float64_2sfixed;

-----------------------------------------------------------------------------------------------------------------------------------

function to_slv(arg : decimal) return std_logic_vector is
begin
	return std_logic_vector(arg);
end function to_slv;

-----------------------------------------------------------------------------------------------------------------------------------

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
	if(arg'high < 0) then left := arg'high; end if;																		--numbers with negative starting index treat as unsigned
	while left >= arg'low loop
		if(arg(left)='1') then return left;
		end if;
		left := left-1;
	end loop;
	return integer'low;
end function sleftmost;

end my_types;
