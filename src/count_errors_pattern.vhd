library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.bus_pkg.all;

entity count_errors_pattern is 
	generic(
		din_width:integer:=40;
		n_arrays:integer:=1;
		pattern:std_logic_vector(39 downto 0) := "1010101010101010101010101010101010101010"
	);
   port (
      din:in bus_array(n_arrays-1 downto 0)(din_width-1 downto 0);
      dout:out std_logic_vector(integer(ceil(log2(real(din_width*n_arrays)))) downto 0)
  );
end count_errors_pattern;

architecture rtl of count_errors_pattern is

	function count_errors_func(slv : bus_array; pattern: STD_LOGIC_VECTOR) return natural is 
		variable n_errors : natural := 0;
		--variable pattern_tmp:STD_LOGIC_VECTOR (39 DOWNTO 0) := pattern;

		begin
			for i in slv'range loop
				for j in slv(i)'range loop
					if slv(i)(j) /= pattern(j) then
						n_errors := n_errors + 1;
					end if;
				end loop;
					--pattern_tmp := not pattern_tmp;

			end loop;
		return n_errors;
	end function count_errors_func;

begin
   dout <= std_logic_vector(to_unsigned(count_errors_func(din, pattern), dout'length) );
end rtl;

