
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use work.my_types.all;
use work.my_float_package.all;
use work.my_functions.all;

entity overcurrent_relay is
	port	(	adc 		: in float32    := "00000000000000000000000000000000"; 
				trip_signal : out std_logic := '0';
				clk_in		: in std_logic 	:= '0'
			);
end entity;

architecture ocr of overcurrent_relay is
	signal Irms		: float32 := (others => '0');
	signal adc_clk	: std_logic := '0';
	
	component two_kHz
	port(
				clk_in	: in std_logic	:= '0';
				clk_out	: out std_logic	:= '0'
			);
	end component;
	
	component dft32
	port(
				clk	: in std_logic;
				adc	: in float32;
				Irms	: out float32
			);
	end component;
	
	component trip_generator
	port(
				I 				: in float32; 
				trip_signal : out std_logic;
				clk 			: in std_logic
			);
	end component;
	
begin
    
	clk_gen : two_kHz
	port map(
		clk_in => clk_in,								
		clk_out	=> adc_clk
	);
								
	fourier : dft32
	port map(
		clk	=> adc_clk,
		adc	=> adc,
		Irms => Irms
	);
	
	trip_gen : trip_generator
	port map(
		clk	=> adc_clk,
		I => Irms,
		trip_signal	=> trip_signal
	);
end architecture;
