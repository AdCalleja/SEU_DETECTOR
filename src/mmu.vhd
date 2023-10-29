library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.bus_pkg.all;

entity mmu is
  generic
  (
    MEM_WIDTH : integer := 40;
    MEM_ADDRS : integer := 256);
  port
  (
    clk        : in std_logic;
    rst_n      : in std_logic; 
    mem_clk    : out std_logic; -- In this case mem_clk==clk but if wanted to be modified logic can be implemented here
    data       : out std_logic_vector(MEM_WIDTH - 1 downto 0);
    addr       : out std_logic_vector(integer(ceil(log2(real(MEM_ADDRS)))) - 1 downto 0);
    mmu_finish : out std_logic
  );
end mmu;

architecture rtl of mmu is
  signal counter : std_logic_vector(integer(ceil(log2(real(MEM_ADDRS)))) downto 0) := (others => '0'); -- NO -1 Because it overflows and never stop looping the counter
begin
  addr_gen : process (clk) begin
    if rising_edge(CLK) then
      if rst_n = '1' then -- Sync becuase it's also used as "EN"
        if unsigned(counter) >= MEM_ADDRS-1 then
          counter    <= counter; -- Stall at last addr and maintain enabled the mmu_finish
          mmu_finish <= '1';
        else
          counter    <= std_logic_vector(unsigned(counter) + 1);
          mmu_finish <= '0';
        end if;
      else
        counter    <= (others => '0');
        mmu_finish <= '0';
      end if;
    end if;
  end process;

  -- Combinatorial, dont care about the clk, and it adds a delay from counter
  -- IDK if it is in WRITE or READ mode, always generate the output
  data_gen : process (rst_n, counter) begin 
      if rst_n = '1' then -- Sync becuase it's also used as "EN"
        if counter(0) = '0' then -- Even
          data <= "1010101010101010101010101010101010101010";
        elsif counter(0) = '1' then -- Odd
          data <= "0101010101010101010101010101010101010101";
        end if;
      else
        data <= "1010101010101010101010101010101010101010"; -- RST Even
      end if;
  end process;

  mem_clk <= clk;
  addr <= counter(integer(ceil(log2(real(MEM_ADDRS))))-1 downto 0); -- Tell to it to ignore MSB bit

end rtl;