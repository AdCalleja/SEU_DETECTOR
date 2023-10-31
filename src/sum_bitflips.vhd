library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.bus_pkg.all;

entity sum_bitflips is
  generic
  (MEM_WIDTH : integer := 40;
  MEM_ADDRS : integer := 256;
  N_MEMS  : integer := 10
);
  port
  (
    clk : in std_logic;
    rst_n      : in std_logic; 
    bitflips   : in std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * N_MEMS)))) downto 0);
    total_bitflips  : out std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * MEM_ADDRS * N_MEMS)))) downto 0)
  );
end sum_bitflips;

architecture rtl of sum_bitflips is

  signal total_bitflips_temp    : std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * MEM_ADDRS * N_MEMS)))) downto 0);
  

begin

sum : process (clk) begin
    if rising_edge(clk) then
      if rst_n = '1' then -- Sync becuase it's also used as "EN"
            total_bitflips <= std_logic_vector(unsigned(total_bitflips) + unsigned(bitflips));
      else
        total_bitflips <= (others => '0');
      end if;
    else
        total_bitflips <=total_bitflips;
    end if;
  end process;
  
  --total_bitflips <= total_bitflips_temp; --SHOULD I USE A TEMP? I'M NOT SURE

end rtl;