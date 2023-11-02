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
    READ_EN        : in std_logic; --             .read
    DATA_OUT       : buffer std_logic_vector(31 downto 0); --             .readdata
    WRITE_EN       : in std_logic;
    DATA_IN        : in std_logic_vector(31 downto 0) := (others => '0');--    avalon_st.data
    INS_IRQ0       : buffer std_logic
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

  -- INTERRUPT
  signal r_out_en : std_logic;
  signal r_out_en_tmp : std_logic;
  signal total_bitflips_out_irq : std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * MEM_ADDRS * N_MEMS)))) downto 0);
  constant ZERO : std_logic_vector(DATA_OUT'range) := (others => '0');

begin

  -- MM Interrupt
  --INS_IRQ0 <= or_reduce(total_bitflips_out);
  --INS_IRQ0 <= r_out_en; -- Produce IRQ every read_out, to know that the system is working

  MM_WRITE_READ : process (CLK_SRC, RESET_N)
  begin
    if RESET_N = '1' then -- ASYNC RESET
      if rising_edge(CLK_SRC) then
        if WRITE_EN = '1' then --WRITE
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
        elsif READ_EN = '1' then -- READ
          case OFFSET_ADDRESS is
            when "00000000" =>
              DATA_OUT <= ZERO(31 downto total_bitflips_out_irq'length) & total_bitflips_out_irq;
            when others =>
              DATA_OUT <= DATA_OUT;
          end case;
        else
          en_sw              <= en_sw;
          n_reads            <= n_reads;
          t_write            <= t_write;
          t_write_resolution <= t_write_resolution;
          DATA_OUT           <= DATA_OUT; -- Todo: Latching when read disabled (==addr example) Make sure that DATA_OUT HAS TO BE KEEP AT VALUE OR OTHER THING
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
    total_bitflips_out => total_bitflips_out, --TODO INTERRUP CONTROLLER FOR THIS. See if it's worth testing like this or implement the IRQ first BOTH probably
    r_out_en           => r_out_en_tmp
    );

  -- Delay IRQTrigger/DataAvailable
  reg : process (CLK_SRC) begin
    if rising_edge(CLK_SRC) then
      if RESET_N = '1' then
        r_out_en <= r_out_en_tmp;
      else
        r_out_en <= '0';
      end if;
    else
      r_out_en <= r_out_en;
    end if;
  end process;

  -- IRQ Servicing complaying with Avalon
  IRQ_Server : process (CLK_SRC) begin
    if rising_edge(CLK_SRC) then
      if RESET_N = '1' then
        if r_out_en = '1' then
          INS_IRQ0 <= r_out_en; -- Latch until IRQ is attended
          total_bitflips_out_irq <= total_bitflips_out;
        elsif READ_EN = '1' and OFFSET_ADDRESS = "00000000" then
          INS_IRQ0 <= '0'; -- IRQ attended when read the addr 0
          total_bitflips_out_irq <= (others => '0'); 
        end if;
      else
        INS_IRQ0 <= '0'; -- Not sure if this reset is needed
        total_bitflips_out_irq <= (others => '0'); 
      end if;
    else
      INS_IRQ0 <= INS_IRQ0;
      total_bitflips_out_irq <= total_bitflips_out_irq; 
    end if;
  end process;
end architecture rtl; -- of debayer