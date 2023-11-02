library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_misc.all;
use work.bus_pkg.all;
use ieee.math_real.all;

entity top is
  port
  (
    CLK_SRC        : in std_logic                    := '0'; --        clock.clk
    RESET_N        : in std_logic                    := '0'; --      reset_n.reset_n
    OFFSET_ADDRESS : in std_logic_vector(7 downto 0) := (others => '0'); -- avalon_slave.address
    READ_EN        : in std_logic                    := '0'; --             .read
    DATA_OUT       : buffer std_logic_vector(31 downto 0); --             .readdata
    WRITE_EN       : in std_logic;
    DATA_IN        : in std_logic_vector(31 downto 0) := (others => '0');--    avalon_st.data
    INS_IRQ0       : out std_logic
    --EMPTY           : in  std_logic                     := '0';             --             .empty
    --END_OF_PACKET   : in  std_logic                     := '0';             --             .endofpacket
    --READY           : out std_logic;                                        --             .ready
    --START_OF_PACKET : in  std_logic                     := '0';             --             .startofpacket
    --SINK_VALID      : in  std_logic                     := '0'              --             .valid
  );
end entity top;

architecture rtl of top is
  -- CONSTANTS --
  constant N_MEMS    : integer := 10;
  constant MEM_WIDTH : integer := 40;
  constant MEM_ADDRS : integer := 256;

  -- MM WRITE
  signal en_sw              : std_logic;
  signal n_reads            : std_logic_vector(15 downto 0);
  signal t_write            : std_logic_vector(13 - 1 downto 0);
  signal t_write_resolution : std_logic;
  -- MM READ
  signal total_bitflips_out : std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * MEM_ADDRS * N_MEMS)))) downto 0);

begin

  -- MM Interrupt
  INS_IRQ0 <= or_reduce(total_bitflips_out);

  MM_WRITE_READ : process (CLK_SRC, RESET_N)
  begin
    if RESET_N = '1' then -- ASYNC RESET
      if rising_edge(CLK_SRC) then
        if WRITE_EN = '1' then
          case OFFSET_ADDRESS is
            when "00000000" =>
              en_sw <= DATA_IN(0);
            when "00000001" =>
              n_reads <= DATA_IN(15 downto 0);
            when "00000010" =>
              t_write <= DATA_IN(13 - 1 downto 0);
            when "00000011" =>
              t_write_resolution <= DATA_IN(0);
            when others =>
              en_sw              <= en_sw;
              n_reads            <= n_reads;
              t_write            <= t_write;
              t_write_resolution <= t_write_resolution;
          end case;
        elsif READ_EN then
          DATA_OUT <= total_bitflips_out;

        else
          en_sw              <= en_sw;
          n_reads            <= n_reads;
          t_write            <= t_write;
          t_write_resolution <= t_write_resolution;
          DATA_OUT           <= DATA_OUT; -- Todo: Make sure that DATA_OUT HAS TO BE KEEP AT VALUE OR OTHER THING
        end if;
      else
        en_sw              <= en_sw;
        n_reads            <= n_reads;
        t_write            <= t_write;
        t_write_resolution <= t_write_resolution;
        DATA_OUT           <= DATA_OUT;
      end if;
    else
      en_sw              <= '0';
      n_reads            <= (others => '0');
      t_write            <= (others => '0');
      t_write_resolution <= '0';
      DATA_OUT           <= (others => '0');
    end if;
  end process;

  SEU_DETECTOR : entity work.seu_detector generic
    map(
    N_MEMS    => N_MEMS,
    MEM_WIDTH => MEM_WIDTH,
    MEM_ADDRS => MEM_ADDRS
    ) port map
    (
    clk_src            => CLK_SRC,
    rst_n              => RESET_N,
    en_sw              => en_sw,
    n_reads            => n_reads,
    t_write            => t_write,
    t_write_resolution => t_write_resolution,
    total_bitflips_out => total_bitflips_out --TODO INTERRUP CONTROLLER FOR THIS. See if it's worth testing like this or implement the IRQ first BOTH probably
    );


end architecture rtl; -- of debayer