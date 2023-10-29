LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.bus_pkg.all;

entity tb_count_errors_pattern is 
end tb_count_errors_pattern;

architecture rtl of tb_count_errors_pattern is	
	--variable N_ARRAYS : integer := 1;
	--variable DIN_WIDTH : integer := 40;
    signal din_test		:  bus_array(1 downto 0)(39 downto 0) := (("1010101010101010101010101010101110101010"),
																					("0010101010101010101010101010101010101010"));
    signal errors : std_logic_vector(integer(ceil(log2(real(40*2)))) downto 0);
   
	component ram_m10k IS
		PORT
		(
			clock		: IN STD_LOGIC  := '1';
			data		: IN STD_LOGIC_VECTOR (39 DOWNTO 0);
			rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			wren		: IN STD_LOGIC  := '0';
			q		: OUT STD_LOGIC_VECTOR (39 DOWNTO 0)
		);
		END component;

	component count_errors_pattern is 
		generic(
			din_width:integer:=40;
			n_arrays:integer:=1;
			pattern:std_logic_vector(39 downto 0) := "1010101010101010101010101010101010101010"
		);
	   port (
		  din:in bus_array(n_arrays-1 downto 0)(din_width-1 downto 0);
		  dout:out std_logic_vector(integer(ceil(log2(real(din_width*n_arrays)))) downto 0)
	  );
	end component;

begin

	DUT: entity work.count_errors_pattern GENERIC MAP (
		din_width=>40, 
		n_arrays=>2, 
		pattern=>"1010101010101010101010101010101010101010")
		PORT MAP (
			din => din_test, 
			dout => errors);
	
end;