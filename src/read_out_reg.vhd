library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.bus_pkg.all;

entity read_out_reg is
  generic
  (
    MEM_WIDTH : integer := 40;
    MEM_ADDRS : integer := 256;
    N_MEMS    : integer := 10
  );
  port
  (
    clk   : in std_logic;
    rst_n : in std_logic;
    en    : in std_logic;
    din   : in std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * MEM_ADDRS * N_MEMS)))) downto 0);
    dout  : out std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * MEM_ADDRS * N_MEMS)))) downto 0)

  );
end read_out_reg;
architecture rtl of read_out_reg is
  
    signal dtemp : std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * MEM_ADDRS * N_MEMS)))) downto 0);

begin
  process (clk) begin
    if rising_edge(clk) then
      if rst_n = '1' then -- Sync becuase it's also used as "EN"
        if en = '1' then
          dtemp <= din;
        else
          dtemp <= dtemp;
        end if;
      else
        dtemp <= (others => '0');
      end if;
    else
      dtemp <= dtemp;
    end if;
  end process;

  dout <= dtemp;

end rtl;