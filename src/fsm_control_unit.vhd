library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
------------------------------------------
entity fsm_control_unit is
  generic
  (
    FREQ_READ_OUT    : integer := 1; --Test for 1 hz
    N_READS_TO_WRITE : integer := 1 --Number of reads that have to be performed before rewritting mem
  );
  port
  (
    clk      : in std_logic;
    rst_n    : in std_logic;
    en_sw    : in std_logic;
    clk_out : out std_logic;
    mmu_rst_n : out std_logic;
    w_mem_en : out std_logic;
    r_out_en : out std_logic;
    n_read_mem : in std_logic_vector(15 downto 0);-- 65536 reads of mem per cycle of write max. CAN BE REDUCED TO SIMPLIFY DESIGN
    t_read_out : in std_logic_vector(13-1 downto 0)); -- 8192s = 2.27hours max 
end fsm_control_unit;

architecture RTL of fsm_control_unit is
  type state_type is (STANDBY, WRITE, IDLE, READ_MEM, READ_OUT);
  signal next_state, current_state : state_type;

  -- FSM SIGNALS OUTPUT
  signal mmu_rst_n_tmp        : std_logic;
  signal w_mem_en_tmp         : std_logic;
  signal r_out_tmp            : std_logic;

  -- Internal Counters
  signal cnt_read_out_en  : std_logic;
  signal cnt_read_out_rst : std_logic;
  signal cnt_n_reads_mem: std_logic_vector(32-1 downto 0) := (others => '0');
  signal en                   : std_logic;
  signal seconds : std_logic;




  -- Attribute "safe" implements a safe state machine.
  -- This is a state machine that can recover from an
  -- illegal state (by returning to the reset state).
  attribute syn_encoding               : string;
  attribute syn_encoding of state_type : type is "safe";
begin

  FSM_STATE : process (clk, rst_n)
  begin
    if (rst_n = '0') then
      current_state <= WRITE;
    elsif (clk'event and clk = '1') then
      current_state <= next_state;
    end if;
  end process;
  FSM_OUTPUT : process (clk)
  begin
    if rising_edge(clk) then
      case current_state is
        when STANDBY =>
          mmu_rst_n_tmp        <= '0';
          w_mem_en_tmp         <= '1';
          r_out_tmp            <= '1';
          cnt_read_out_en  <= '0';
          cnt_read_out_rst <= '1';
          en                   <= '0';
          if en_sw = '1' then
            next_state <= WRITE;
          end if;
        when WRITE =>
          mmu_rst_n_tmp        <= '1';
          w_mem_en_tmp         <= '1';
          r_out_tmp            <= '0';
          cnt_read_out_en  <= '0';
          cnt_read_out_rst <= '1';
          en                   <= '1';
        when IDLE =>
          mmu_rst_n_tmp        <= '0';
          w_mem_en_tmp         <= '1';
          r_out_tmp            <= '0';
          cnt_read_out_en  <= '1';
          cnt_read_out_rst <= '0';
          en                   <= '1';
        when READ_MEM =>
          mmu_rst_n_tmp        <= '1';
          w_mem_en_tmp         <= '1';
          r_out_tmp            <= '0';
          cnt_read_out_en  <= '0';
          cnt_read_out_rst <= '1';
          en                   <= '1';
        when READ_OUT =>
          mmu_rst_n_tmp        <= '0';
          w_mem_en_tmp         <= '1';
          r_out_tmp            <= '1';
          cnt_read_out_en  <= '1';
          cnt_read_out_rst <= '1';
          en                   <= '1';
        when others =>
          mmu_rst_n_tmp        <= '0';
          w_mem_en_tmp         <= '1';
          r_out_tmp            <= '1';
          cnt_read_out_en  <= '0';
          cnt_read_out_rst <= '1';
          en                   <= '0';
      end case;
    end if;
  end process;


  -- Counter of the number of reads before a write is needed
  CNR_N_READS : entity work.counter_gen generic
    map(
    CNT_WDTH => 16
    ) port map
    (
    clk     => r_out_tmp,
    RESET_N => rst_n,
    EN      => '1',
    CLC =>  w_mem_en_tmp,
    DIR => '1',
    CNT_TO => n_read_mem,
    CNT => cnt_n_reads_mem
    );

      -- Counter to wait the time needed to read mem
    CLK_DIV_SECONDS : entity work.clock_divider GENERIC MAP (LIMIT=>100000000) port map (clk, rst_n, seconds);
    CNR_READ_MEM : entity work.counter_gen generic
      map(
      CNT_WDTH => 13 -- Has to at least match t_read_out size in case n_read_mem=1
      ) port map
      (
      clk     => seconds,
      RESET_N => rst_n,
      EN      => '1',
      CLC =>  w_mem_en_tmp,
      DIR => '1',
      CNT_TO => std_logic_vector(unsigned(t_read_out)/unsigned(n_read_mem)), --others=0?
      CNT => cnt_n_reads_mem
      );


  -- SYSTEM_CLK_EN Dirty trick to solve that I was not consistant with ENs
  -- Disables clk 
  -- This should work because I am latching out the signal that has to be sent to MCU
  clk_out <= clk when en = '1' else '0';


  mmu_rst_n        <= mmu_rst_n_tmp;
  w_mem_en         <= w_mem_en_tmp;
  r_out_en            <= r_out_tmp;

end RTL;