library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;

entity clock_divider is
  generic
    (LIMIT : integer := 25000);
  port
  (
    clk, reset_n : in std_logic;
    clock_out    : out std_logic);
end clock_divider;

architecture bhv of clock_divider is

  signal count : integer   := 1;
  signal tmp   : std_logic := '0';

begin

  process (clk, reset_n)
  begin
    if (reset_n = '0') then
      count <= 1;
      tmp   <= '0';
    elsif (clk'event and clk = '1') then
      count <= count + 1;
      if (count = LIMIT) then
        tmp   <= not tmp;
        count <= 1;
      end if;
    end if;
    clock_out <= tmp;
  end process;

end bhv;


-- -- Time_unit For more complex design
-- library IEEE;
-- use IEEE.STD_LOGIC_1164.all;
-- use IEEE.numeric_std.all;

-- entity TimeUnit is
-- 	generic
-- 	  (SECONDS : integer := 25000); -- 1s == 100.000.000 pulses for clock
-- 	port
-- 	(
-- 	  clk, reset_n : in std_logic;
-- 	  clock_out    : out std_logic);
--   end clock_divider;
  
--   architecture bhv of clock_divider is
  
  
--   begin
  
--   end bhv;
