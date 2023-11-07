library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; -- math operations using std logic vectors

entity COUNTER_GEN is
  generic
  (
    CNT_WDTH : integer := 32
  );
  port
  (
    RESET_N, CLK, EN, CLC : in std_logic;
    DIR                   : in std_logic := '1';
    CNT_TO                : in std_logic_vector(CNT_WDTH - 1 downto 0); -- Put as variable to be able to modify it from SW
    CNT                   : out std_logic_vector(CNT_WDTH - 1 downto 0)
  );
end COUNTER_GEN;
architecture beh of COUNTER_GEN is

  -- signal, component etc. declarations
  signal Counter : std_logic_vector(CNT_WDTH - 1 downto 0) := (others => '0');

begin

  process (RESET_N, EN, CLK)
  begin
    if RESET_N = '1' then
		if CLK = '1' and CLK'event then
      if CLC = '0' then
        if  EN = '1' then
          if DIR = '1' then
            if Counter >= CNT_TO then
              Counter <= (others => '0');
            else
              Counter <= Counter + 1;
            end if;
          else
            if Counter >= CNT_TO then
              Counter <= (others => '0');
            else
              Counter <= Counter - 1;
            end if;
          end if;
        end if;
      else
        Counter <= (others => '0');
      end if;
	end if;
    else
      Counter <= (others => '0');
    end if;
  end process;

  CNT <= Counter;

end beh;