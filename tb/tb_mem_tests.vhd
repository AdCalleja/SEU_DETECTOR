LIBRARY ieee;
USE ieee.std_logic_1164.all;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity mem_tests is 
	generic (N_MLAB:integer:=2);
	port (clk_src, rst  : in  std_logic;						
	      total_errors_out : out unsigned(31 downto 0) -- Number of errros in binary
		);	
end mem_tests;

architecture rtl of mem_tests is	
	signal clk : std_logic;
	
	
begin
	
	DUT: entity work.mem_test port map(
	
		);
	
	
	process begin
		
	end process
	
	clk <= not clk after 10 ns;
	reset <= '1' after 50 ns< 
	
end;