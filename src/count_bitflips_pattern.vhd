library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.bus_pkg.all;

entity count_bitflips_pattern is
  generic
  (
    MEM_WIDTH : integer := 40;
    N_MEMS  : integer := 256
    --PATTERN   : std_logic_vector(39 downto 0) := "1010101010101010101010101010101010101010"
  );
  port
  (
    din   : in bus_array(N_MEMS - 1 downto 0)(MEM_WIDTH - 1 downto 0);
    addr0 : in std_logic; -- Mux control Even/Odd
    dout  : out std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * N_MEMS)))) downto 0)
  );
end count_bitflips_pattern;

architecture rtl of count_bitflips_pattern is

  signal pattern    : std_logic_vector(MEM_WIDTH - 1 downto 0);
  function count_bitflips_func(slv : bus_array; PATTERN : std_logic_vector) return natural is
    variable n_bitflips : natural := 0;
    --variable pattern_tmp:STD_LOGIC_VECTOR (39 DOWNTO 0) := PATTERN;
  begin
    for i in slv'range loop
      for j in slv(i)'range loop
        if slv(i)(j) /= PATTERN(j) then
          n_bitflips := n_bitflips + 1;
        end if;
      end loop;
      --pattern_tmp := not pattern_tmp;

    end loop;
    return n_bitflips;
  end function count_bitflips_func;

begin

  pattern_gen : process (addr0) begin
    if addr0 = '0' then -- Even
      pattern <= "1010101010101010101010101010101010101010";
    elsif addr0 = '1' then -- Odd
      pattern <= "0101010101010101010101010101010101010101";
    end if;
  end process;

  dout <= std_logic_vector(to_unsigned(count_bitflips_func(din, PATTERN), dout'length));
end rtl;