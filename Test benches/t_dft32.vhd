
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.read;

use work.my_types.all;
use work.my_float_package.all;
use work.my_functions.all;

entity t_dft32 is
end entity;

architecture t_dft32 of t_dft32 is
    constant zero      : float32 := b"0_0000_0000_0000_0000_0000_0000_0000_000";
    
    component dft32 is
        port (
			clk : in std_logic;
			adc : in float32;
			Irms : out float32
		);
    end component;
    
    signal t_clk : std_logic := '0';
    signal t_adc : float32 := zero;
    signal t_Irms : float32;
begin
	 uut : dft32
	 port map (
		clk => t_clk,
		adc => t_adc,
		Irms => t_Irms
	 );
    
    --reset <= '1', '1' after 100 ns, '0' after 503 ns;
    
    process_clock : process
        variable n : natural := 0;
    begin
			t_clk <= '0'; wait for 10 ns; t_clk <= '1'; wait for 10 ns;
--			writeproc(to_slv(t_adc), "read by adc :");
--			report "sample number " & integer'image(n);
			n := n + 1;
    end process;
    
    process_test : process(t_clk)
        file f_in : text open read_mode is "test_dft.txt";
        variable li : line;
        variable x : std_ulogic_vector(31 downto 0);
        variable ret : boolean;
    begin
        if rising_edge(t_clk) then
            readline(f_in, li);
            ieee.std_logic_textio.read(li, x, ret);
--            writeproc(std_logic_vector(x), "read value :");
            t_adc <= decimal(x);
--            readline(f_in, li);
--            readline(f_in, li);
        end if;
    end process;


--    process
--        variable l : float(4 downto -3) := b"00111_010";--_010";
--        variable r : float(4 downto -3) := b"10111_001";--_000";
--    begin
--        wait for 10 ns;
--        writeproc(to_slv(l + r));
--    end process;
end architecture;

--'C:/Users/neha1/Desktop/docr/docr.sim/sim_1/behav/xsim/elaborate.log'
