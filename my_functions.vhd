--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package my_functions is

function minimum(l,r : integer) return integer;
function maximum(l,r : integer) return integer;

end my_functions;

package body my_functions is

function minimum(l,r : integer) return integer is
begin
	if l > r then return r;
   else return l;
   end if;
end function minimum;

function maximum(l,r : integer) return integer is
begin
	if l < r then return r;
   else return l;
   end if;
end function maximum;
 
end my_functions;
