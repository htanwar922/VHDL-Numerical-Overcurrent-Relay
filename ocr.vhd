
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use work.my_types.all;
use work.my_float_package.all;
use work.my_functions.all;

entity ocr is
	port	(	I : in float32 := b"0_1000_0000_0000_0000_0000_0000_0000_000"; --"0011111111110000000000000000000000000000000000000000000000000000"; 
				tr : out float32;
				clk : in std_logic := '0'
			);
end ocr;

architecture ocr of ocr is
	signal one  : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	signal A    : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	signal B    : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	signal TDS  : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	signal Ip   : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	signal p    : sfixed(1 downto -20) := b"01_00110011001100110011";
begin
	process(I,clk, TDS)
	variable tmp  : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	variable tmp1 : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	variable tmp2 : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	variable tmp3 : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	variable M    : float32 := b"0_0111_1111_0000_0000_0000_0000_0000_000";
	begin
	    if (clk' event and clk = '1') then
	        M := I/Ip; --B + A / ( pow( I/Ip, p ) - one );
	        tmp3 := pow(M, p);
	        -- rtl_synthesis off
--            M := I/Ip;
--            tmp := pow(M,p);
--            tmp1 := tmp-one;
--            tmp2 := A/tmp;
--            tmp3 := tmp2 + B;
            
--            writeproc(to_slv(M)   ,"M   : ");
--            writeproc(to_slv(I)   ,"I   : ");
--            writeproc(to_slv(tmp) ,"tmp : ");
--            writeproc(to_slv(tmp1),"tmp1: ");
--            writeproc(to_slv(tmp2),"tmp2: ");
--            writeproc(to_slv(tmp3),"tmp3: ");
            -- rtl_synthesis on
		end if;
		tr <= TDS*tmp3;
	end process;

end architecture;

