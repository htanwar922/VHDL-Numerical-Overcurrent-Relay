
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

use work.my_types.all;
use work.my_float_package.all;

entity t_relay is
end t_relay;

architecture t_relay of t_relay is 
	 component overcurrent_relay
	 port	(	adc 				: in float32;
				clk_in			: in std_logic 	:= '0';
				trip_signal 	: out std_logic 	:= '0'
			);
	 end component;
	 
	 component two_kHz
	 port	(
				clk_in			: in std_logic 	:= '0';
				clk_out		 	: out std_logic 	:= '0'
			);
	 end component;

	 signal adc				: float32;
	 signal clk_in			: std_logic;
	 signal clk_out			: std_logic;
	 signal trip_signal	: std_logic;

begin

	uut: overcurrent_relay port map( clk_in => clk_in, trip_signal => trip_signal, adc => adc);
	uuu: two_kHz port map( clk_in => clk_in, clk_out => clk_out);
	
	clock : process
	begin
		clk_in <= '0';
		wait for 625 ps;
		clk_in <= '1';
		wait for 625 ps;
	end process;
	
	 process_test : process(clk_out)
        file f_in : text open read_mode is "test_cases_gen1.txt";
        variable li : line;
        variable x : std_ulogic_vector(31 downto 0);
        variable ret : boolean;
    begin
            if rising_edge(clk_out) then
                readline(f_in, li);
                ieee.std_logic_textio.read(li, x, ret);
                adc <= float32(x);
            end if;
    end process;
end architecture;
