
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
    component dft32 is
        --generic( N : natural := 40 );
        port (
			clk : in std_logic := '0';
			adc : in float32;
			X_1 : out float32
		);
    end component;
    
    signal t_clk : std_logic := '0';
    signal t_adc : float32;
    signal t_X_1 : float32;
begin
    uut : dft32
        --generic map( N => 40 );
        port map (
            clk => t_clk,
            adc => t_adc,
            X_1 => t_X_1
        );
    
    --reset <= '1', '1' after 100 ns, '0' after 503 ns;
    
    process_clock : process(t_clk)
    begin
        t_clk  <= not t_clk after 10 ns;
    end process;
    
--    process_test : process(t_clk)
--        file f_in : text open read_mode is "test_dft.txt";
--        variable li : line;
--        variable x : std_ulogic_vector(31 downto 0);
--        variable ret : boolean;
--    begin
--        --file_open(f_in, "test_dft.txt",  read_mode);
--        while not endfile(f_in) loop
--            --wait for 10 ns;
--            if rising_edge(t_clk) then
--                readline(f_in, li);
--                ieee.std_logic_textio.read(li, x, ret);
--                t_adc <= decimal(x);
--            end if;
--            --wait for 10 ns;
--        end loop;
--    end process;
    
end architecture;

--'C:/Users/neha1/Desktop/docr/docr.sim/sim_1/behav/xsim/elaborate.log'
