
library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
use ieee.std_logic_textio.all;

package my_functions is

function minimum(l,r : integer) return integer;
function maximum(l,r : integer) return integer;
procedure writeproc(sig: in std_logic_vector; s : string := "");

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

procedure writeproc(sig : in std_logic_vector; s : string := "") is
	variable li : line;
	variable str : string(1 to sig'length);
	file f_in : text; -- open read_mode is "output";
	file f_out : text; -- open write_mode is "output";
begin
	file_open(f_out, "output", write_mode);
	write(li, std_logic_vector(sig));
   write(li, lf);	writeline(f_out, li);
	file_close(f_out);
	file_open(f_in, "output", read_mode);
	readline(f_in, li);
	read(li, str);
	file_close(f_in);
	report s & " " & str;
end procedure writeproc;

end my_functions;
