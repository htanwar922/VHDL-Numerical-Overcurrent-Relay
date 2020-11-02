
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use work.my_types.all;
use work.my_float_package.all;
use work.my_functions.all;

entity trip_generator is
	port	(	I 				: in float32 := "01000000000000000000000000000000"; --"0011111111110000000000000000000000000000000000000000000000000000"; 
				trip_signal : out std_logic 	:= '0';
				clk 			: in std_logic 	:= '0'
			);
end entity;

architecture trip_generator of trip_generator is
	constant one	: float32 := "00111111100000000000000000000000";
	constant dt		: float32 := "00111010000000110001000000000000";
	constant A		: float32 := "00111111100000000000000000000000";
	constant B		: float32 := "00111110000000000000000000000000";--"00111110000000000000000000000000";
	constant TDS	: float32 := "00111111100000000000000000000000";
	constant Ip		: float32 := "01000000110000000000000000000000";
	constant p		: sfixed(1 downto -20) :="0100110011001100110011";
	signal tmp		: float32 := "00000000000000000000000000000000";
	signal tmp1		: float32 := "00000000000000000000000000000000";
	signal tr		: float32 := "00000000000000000000000000000000";
	signal o_by_tr	: float32 := "00000000000000000000000000000000";
	signal thres	: float32 := "10000000000000000000000000000000";
begin

	process(I)
	begin
		tr <= tds * ( A / ( pow((I/Ip), p) - one) + B );
		tmp <= dt / tr;
	end process;
	
	process(clk)
	begin
		if (clk' event and clk = '1') then
			tmp1 <= o_by_tr + tmp;
		end if;
	end process;
	
	process(tmp1)
	begin
		if(tmp1(tmp1'high)='1') then
		  o_by_tr <=  "00000000000000000000000000000000";
		else
		  o_by_tr <= tmp1;
		end if;
	end process;
	
	thres <= o_by_tr - one;
	trip_signal <= not thres(thres'high);
	
end architecture;
