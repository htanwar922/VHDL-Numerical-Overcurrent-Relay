
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

use work.my_functions.all;


package my_types is																										--take arrays as downto only

type unresolved_decimal is array (integer range <>) of std_logic;
subtype decimal is unresolved_decimal;

subtype unresolved_fixed is decimal;											--taken in sign-magnitude representation --numbers with negative starting index treat as unsigned or positive
	subtype fixed is unresolved_fixed;
	subtype ufixed is fixed;
	subtype sfixed is fixed;
	
subtype unresolved_float is decimal;											--float is signed only
	subtype float is unresolved_float;
	subtype float32 is float(8 downto -23);																		-- 0 (8) 0111_1111 (7:0) 0000_0000_0000_0000_0000_000 (-1:-23)
	subtype float64 is float(11 downto -52);																		-- 0 (11) 011_1111_1111 (10:0) 0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000 (-1:-52)
	subtype float128 is float (15 downto -112);																	-- 128 : 0 (15) 011_1111_1111_1111 (14:0) 0xffff_ffff_ffff_ffff_ffff_ffff_ffff (-1:-112)

type float32_arr is array (integer range <>) of float32;
type float64_arr is array (integer range <>) of float64;
type choice is range 0 to 3;

subtype smg is signed;																--sign-magnitude

-- rtl_synthesis off
constant null_vec : std_logic_vector(0 downto 1) := "";
-- rtl_synthesis on

function to_decimal(arg : std_logic_vector) return decimal;
function to_decimal(arg : unsigned) return decimal;
function to_decimal(arg : signed) return decimal;
--function to_decimal(arg : smg) return decimal;

function to_slv(arg : decimal) return std_logic_vector;
function to_unsigned(arg : decimal) return unsigned;
function to_signed(arg : decimal) return signed;
function to_smg(arg : decimal) return smg;

function to_smg(arg : unsigned) return smg;
function to_slv(arg : unsigned) return std_logic_vector;
function to_smg(arg : signed) return smg;
function to_slv(arg : signed) return std_logic_vector;
function to_signed(arg : smg) return signed;
--function to_slv(arg : smg) return std_logic_vector;

function cleanvec(l,r : decimal) return boolean;

function add_unsigned (l,r : unsigned; cin: std_logic := '0') return unsigned;
function add_smg (l,r : smg; cin: std_logic := '0') return smg;
function add_decimal(l,r : decimal) return decimal;

function "&"(l,r : decimal) return decimal;
function "="(l,r : decimal) return boolean;

function check_uxz(arg : decimal) return boolean;
function and_reduce(arg : decimal) return std_logic;
function or_reduce(arg : decimal) return std_logic;

end my_types;

--============================================================================================================

package body my_types is

function cleanvec(l,r : unsigned) return boolean is
begin
	assert ((l'high=r'high) and (l'low=r'low)) report "unsigned operands size mismatch in:" severity error;
	return ((l'high=r'high) and (l'low=r'low));
end function cleanvec;

function cleanvec(l,r : smg) return boolean is
begin
	assert ((l'high=r'high) and (l'low=r'low)) report "smg operands size mismatch in:" severity error;
	return ((l'high=r'high) and (l'low=r'low));
end function cleanvec;

function cleanvec(l,r : decimal) return boolean is
begin
	assert ((l'high=r'high) and (l'low=r'low)) report "float operands size mismatch in:" severity error;
	return ((l'high=r'high) and (l'low=r'low));
end function cleanvec;

--------------------------------------------------------------------------------------------------------------

function add_unsigned (l,r : unsigned; cin: std_logic := '0') return unsigned is
	constant l_left: integer := l'length-1;
	alias xl: unsigned(l_left downto 0) is l;
	alias xr: unsigned(l_left downto 0) is r;
	variable result: unsigned(l_left+1 downto 0);
	variable c: std_logic := cin;
begin
	-- rtl_synthesis off
	if(not(cleanvec(l,r))) then return unsigned(null_vec); end if;
	-- rtl_synthesis on
	result := ('0' & xl) + ('0' & xr); --writeproc(to_slv(xl)); writeproc(to_slv(xr)); writeproc(to_slv(result));
	return result;
end add_unsigned;

function add_smg (l,r : smg; cin: std_logic := '0') return smg is
	constant l_left: integer := l'length-1;
	variable xl		: signed(l_left+1 downto 0) := l(l'high) & to_signed(l);
	variable xr		: signed(l_left+1 downto 0) := r(r'high) & to_signed(r);
	variable res	: signed(l_left+1 downto 0);
	variable c		: std_logic := cin;
begin
	-- rtl_synthesis off
	if(not(cleanvec(l,r))) then return smg(null_vec); end if;
	-- rtl_synthesis on
	res := xl+xr;
	return to_smg(res);
end add_smg;

function add_decimal(l,r : decimal) return decimal is
	variable l_unsg : unsigned(l'length-1 downto 0);
	variable r_unsg : unsigned(r'length-1 downto 0);
	variable res_un : unsigned(l'length downto 0);
	variable result : decimal(l'high+1 downto l'low);
begin
	-- rtl_synthesis off
	if(not(cleanvec(l,r))) then return decimal(null_vec); end if;
	-- rtl_synthesis on
	result := '0' & l;
	l_unsg := to_unsigned(l);
	r_unsg := to_unsigned(r);
	res_un := add_unsigned(l_unsg,r_unsg);
	result := to_decimal(res_un);
	return result;
end function add_decimal;

function "&"(l,r : decimal) return decimal is
	variable result : decimal(l'length+r'high downto r'low);
begin
	result(l'length+r'high downto r'high+1) := l;
	result(r'high downto r'low) := r;
	return result;
end function "&";

function "="(l,r : decimal) return boolean is
begin
	return (to_slv(l) = to_slv(r));
end function "=";

--------------------------------------------------------------------------------------------------------------

function to_decimal(arg : std_logic_vector) return decimal is
begin
	return decimal(arg);
end function to_decimal;

function to_decimal(arg : unsigned) return decimal is
begin
	return decimal(std_logic_vector(arg));
end function to_decimal;

function to_decimal(arg : signed) return decimal is
begin
	return decimal(std_logic_vector(arg));
end function to_decimal;

--function to_decimal(arg : smg) return decimal is
--begin
--	return decimal(std_logic_vector(arg));
--end function to_decimal;

function to_slv(arg : decimal) return std_logic_vector is
begin
	return std_logic_vector(arg);
end function to_slv;

function to_unsigned(arg : decimal) return unsigned is
begin
	return unsigned(to_slv(arg));
end function to_unsigned;

function to_signed(arg : decimal) return signed is
begin
	return signed(to_slv(arg));
end function to_signed;

function to_smg(arg : decimal) return smg is
begin
	return smg(to_slv(arg));
end function to_smg;

function to_smg(arg : unsigned) return smg is
begin
	return smg(to_slv(arg));
end function to_smg;

function to_slv(arg : unsigned) return std_logic_vector is
begin
	return std_logic_vector(arg);
end function to_slv;

function to_smg(arg : signed) return smg is
begin
	if(arg(arg'high)='0') then return smg(arg);
	else return smg('1' & (-arg(arg'high-1 downto 0)));
	end if;
end function to_smg;

function to_slv(arg : signed) return std_logic_vector is
begin
	return std_logic_vector(arg);
end function to_slv;

function to_signed(arg : smg) return signed is
begin
	if(arg(arg'high)='0') then return signed(arg);
	else return signed('1' & (-arg(arg'high-1 downto 0)));
	end if;
end function to_signed;

--function to_slv(arg : smg) return std_logic_vector is
--begin
--	return std_logic_vector(arg);
--end function to_slv;

--------------------------------------------------------------------------------------------------------------

function check_uxz(arg : decimal) return boolean is
begin
	for i in arg'high downto arg'low loop
		if(arg(i)/='0' and arg(i)/='1') then return true; end if;
	end loop;
	return false;
end function check_uxz;

function and_reduce(arg : decimal) return std_logic is
begin
	for i in arg'high downto arg'low loop
		if(arg(i)='0') then return '0'; end if;
	end loop;
	return '1';
end function and_reduce;

function or_reduce(arg : decimal) return std_logic is
begin
	for i in arg'high downto arg'low loop
		if(arg(i)='1') then return '1'; end if;
	end loop;
	return '0';
end function or_reduce;

end my_types;