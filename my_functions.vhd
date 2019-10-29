
library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
use ieee.std_logic_textio.all;

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

procedure writeproc ( sig: in std_logic_vector) is
  variable li : line;
  file output : text open write_mode is "output";
  begin
    write(li, std_logic_vector(sig));
    writeline(output, li);
end procedure writeproc;
 
end my_functions;
