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

package my_types is

type unresolved_fixed is array (integer range <>) of std_ulogic;
alias fixed is unresolved_fixed;
	subtype ufixed is fixed;
	subtype sfixed is fixed;
	
type unresolved_float is array (integer range <>) of std_ulogic;	--float is signed only
alias float is unresolved_float;
	subtype float32 is float(8 downto -23);
	subtype float64 is float(11 downto -52);
	
type choices is range 0 to 3;

function ufixed2float32(arg : ufixed) return float32;
function sfixed2float32(arg : sfixed) return float32;
function ufixed2float64(arg : ufixed) return float64;
function sfixed2float64(arg : sfixed) return float64;

function float32_2sfixed(arg : float) return sfixed;
function float64_2sfixed(arg : float64) return sfixed;

function sfixed2ufixed(arg : sfixed; ch : choices) return ufixed;	--choice 0: change sign bit to 0, choice 1: truncate sign bit
function ufixed2sfixed(arg : ufixed) return sfixed;

function to_sulv(arg : fixed) return std_ulogic_vector;
function to_sulv(arg : float) return std_ulogic_vector;

function leftmost(arg : ufixed) return integer; --index of leftmost '1'
function leftmost(arg : sfixed) return integer; --leftmost '1' other than sign bit

end my_types;

--============================================================================================================================================================================================

package body my_types is

function ufixed2float32(arg : ufixed) return float32 is
	variable result : float32 := (8 => 0, 7 downto 0 => std_ulogic_vector(127+leftmost(arg)), others => '0');
begin
	

end my_types;
