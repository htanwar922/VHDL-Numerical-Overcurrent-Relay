
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_signed.all;

use std.textio.all;

use work.my_types.all;
use work.my_functions.all;

entity ocr is
	generic (n	: integer := 64);
	port (	curr: in float(11 downto -52);
			clk	: in std_logic;
			tt	: out float(11 downto -52)
		);
end ocr;

architecture topmodule of ocr is
	component memory
		generic (n : integer := 64, mem : integer := 128)
		port (	curr : in float(11 downto -52);
				ind  : in std_logic_vector(
	end component memory;
	component rms
		generic (n : integer := 64);
		port (	curr: in float(11 downto -52);
				Irms: out float(11 downto -52);
			);
	end component rms;
	component trip_time
		generic (n	: integer := 64);
		port (	Irms: in float(11 downto -52);
				Ip	: in float(11 downto -52);
				A	: in float(11 downto -52);
				B	: in float(11 downto -52);
				C	: in float(11 downto -52);
				p	: in fixed(2 downto -20);
				tt	: out float(11 downto -52);
			);
	end component trip_time;
	
