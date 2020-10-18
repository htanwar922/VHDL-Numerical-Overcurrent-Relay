
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use work.my_types.all;
use work.my_float_package.all;
use work.my_functions.all;

entity dft is
	generic( N : natural := 40 );
	port (
			clk : in std_logic;
			x : in float64_arr(0 to N-1);
			X_1 : out float64
		);
end entity;

architecture dft of dft is
	signal C : float64_arr(0 to N-1+N/4) :=
		(
			"0000000000000000000000000000000000000000000000000000000000000000",
			"0011111111000100000001100000101101100111101010000101001101110000",
			"0011111111010011110001101110111100110111001011111110100101001100",
			"0011111111011101000011100010111000101011010001001101111000000000",
			"0011111111100010110011110010001100000100011101010101101001011110",
			"0011111111100110101000001001111001100110011111110011101111001100",
			"0011111111101001111000110111011110011011100101111111010010101000",
			"0011111111101100100000110010000000011101001111010010110001101100",
			"0011111111101110011011110000111000010011010001000101010011111110",
			"0011111111101111100110110010010010010100001011111110010001011100",
			"0011111111110000000000000000000000000000000000000000000000000000",
			"0011111111101111100110110010010010010100001011111110010001011100",
			"0011111111101110011011110000111000010011010001000101010100000000",
			"0011111111101100100000110010000000011101001111010010110001101100",
			"0011111111101001111000110111011110011011100101111111010010101000",
			"0011111111100110101000001001111001100110011111110011101111001100",
			"0011111111100010110011110010001100000100011101010101101001011110",
			"0011111111011101000011100010111000101011010001001101111000000000",
			"0011111111010011110001101110111100110111001011111110100101010000",
			"0011111111000100000001100000101101100111101010000101001101111000",
			"0000000000000000000000000000000000000000000000000000000000000000",
			"1011111111000100000001100000101101100111101010000101001101110000",
			"1011111111010011110001101110111100110111001011111110100101001100",
			"1011111111011101000011100010111000101011010001001101110111111100",
			"1011111111100010110011110010001100000100011101010101101001011100",
			"1011111111100110101000001001111001100110011111110011101111001100",
			"1011111111101001111000110111011110011011100101111111010010100110",
			"1011111111101100100000110010000000011101001111010010110001101100",
			"1011111111101110011011110000111000010011010001000101010011111110",
			"1011111111101111100110110010010010010100001011111110010001011010",
			"1011111111110000000000000000000000000000000000000000000000000000",
			"1011111111101111100110110010010010010100001011111110010001011100",
			"1011111111101110011011110000111000010011010001000101010100000000",
			"1011111111101100100000110010000000011101001111010010110001101110",
			"1011111111101001111000110111011110011011100101111111010010101000",
			"1011111111100110101000001001111001100110011111110011101111001110",
			"1011111111100010110011110010001100000100011101010101101001100000",
			"1011111111011101000011100010111000101011010001001101111000000100",
			"1011111111010011110001101110111100110111001011111110100101010000",
			"1011111111000100000001100000101101100111101010000101001101111000",
			"0000000000000000000000000000000000000000000000000000000000000000",
			"0011111111000100000001100000101101100111101010000101001101110000",
			"0011111111010011110001101110111100110111001011111110100101001100",
			"0011111111011101000011100010111000101011010001001101111000000000",
			"0011111111100010110011110010001100000100011101010101101001011110",
			"0011111111100110101000001001111001100110011111110011101111001100",
			"0011111111101001111000110111011110011011100101111111010010101000",
			"0011111111101100100000110010000000011101001111010010110001101100",
			"0011111111101110011011110000111000010011010001000101010011111110",
			"0011111111101111100110110010010010010100001011111110010001011100"
		);
	signal N_float 	: float64 := "0100000001000100000000000000000000000000000000000000000000000000";
	signal two_float 	: float64 := "0100000000000000000000000000000000000000000000000000000000000000";
begin
	process(clk)
	variable tmp_S 		: float64 := "0000000000000000000000000000000000000000000000000000000000000000";
	variable tmp_C 		: float64 := "0000000000000000000000000000000000000000000000000000000000000000";
	variable tmp 			: float64 := "0011111111110000000000000000000000000000000000000000000000000000";
	begin
		if(clk' event and  clk = '1') then
			for i in 0 to N-1 loop
				tmp_S := tmp_S + x(i) * C(i);
				tmp_C := tmp_C + x(i) * C(i + N/4);
			end loop;
		end if;
		tmp := sq(tmp_S) + sq(tmp_C);
		X_1 <= sqrt(tmp) * two_float / N_float;
	end process;
	
end architecture;