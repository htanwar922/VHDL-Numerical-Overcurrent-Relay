
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use work.my_types.all;
use work.my_float_package.all;
use work.my_functions.all;

entity two_kHz is
	generic( N : natural := 40 );
	port (
			clk_in	: in std_logic		:= '0';
			clk_out	: out std_logic	:= '0'
		);
end entity two_kHz;

architecture two_kHz of two_kHz is
	signal counter : integer	:= 0;
	signal tmp		: std_logic	:='0';
begin
	process(clk_in)
	begin
		if(clk_in' event and clk_in ='1') then
			counter <= counter +1;
			if(counter = 200000) then
				counter <= 0;
				tmp <= not tmp;
			end if;
		end if;
	end process;
	
	clk_out <= tmp;
end architecture two_kHz;
