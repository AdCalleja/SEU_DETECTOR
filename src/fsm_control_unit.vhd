library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
------------------------------------------
entity fsm_control_unit is
  generic
  (
	 T_WRITE_WIDTH : integer := 13
  );
  port
  (
    clk        : in std_logic;
    rst_n      : in std_logic;
    en_sw      : in std_logic;
    mmu_finish : in std_logic;
    clk_out    : out std_logic;
    mmu_rst_n  : out std_logic;
    w_mem_en   : out std_logic;
    r_out_en   : out std_logic;
    n_reads    : in std_logic_vector(15 downto 0);-- 65536 reads of mem per cycle of write max. CAN BE REDUCED TO SIMPLIFY DESIGN
    t_write    : in std_logic_vector(T_WRITE_WIDTH - 1 downto 0);-- 8192e-6s 8192s = 2.27hours max 
    t_write_resolution : in std_logic -- 0: t_write in 1e-6seconds / 0: t_write in 1s --TODO:Using t_write_resolution 0 will prob break CPU. Use it to test IRQ limits but I have to think about a better TimeUnit
    );
end fsm_control_unit;

architecture RTL of fsm_control_unit is
  type state_type is (STANDBY, WRITE, IDLE, READ_MEM, READ_OUT);
  signal next_state, current_state : state_type;

  -- FSM SIGNALS OUTPUT
  signal mmu_rst_n_tmp : std_logic;
  signal w_mem_en_tmp  : std_logic;
  signal r_out_tmp     : std_logic;

  -- Internal Counters
  signal cnt_read_out_en  : std_logic;
  signal cnt_read_out_clc : std_logic;
  signal cnt_n_reads  : std_logic_vector(n_reads'length - 1 downto 0) := (others => '0'); -- SIZE depends on INPUT n_reads size
  signal cnt_read         : std_logic_vector(t_write'length - 1 downto 0); -- SIZE depends on INPUT t_write size
  signal en               : std_logic;
  signal seconds          : std_logic := '0';
  signal cnt_read_clock          : std_logic := '0';



  -- Attribute "safe" implements a safe state machine.
  -- This is a state machine that can recover from an
  -- illegal state (by returning to the reset state).
  attribute syn_encoding               : string;
  attribute syn_encoding of state_type : type is "safe";
begin

  --- Finite State Machine ---
  p_my_FSM_state: process (clk)
    begin
    -- state transitions are always synchronous to the clock
      if (clk'event and clk = '1') then
      -- on synchronous reset in any state we jump to the idle state
        if (rst_n = '0') then
          current_state <= STANDBY;
        else -- there is no reset

        case current_state is
          when STANDBY =>
          if en_sw = '1' then
            current_state <= WRITE;
          end if;
        when WRITE =>
          if mmu_finish = '1' then
            current_state <= IDLE;
          end if;
        when IDLE =>
          if cnt_read = std_logic_vector(unsigned(t_write)/unsigned(n_reads)) then
            current_state <= READ_MEM;
          end if;
        when READ_MEM =>
          if mmu_finish = '1' then
            current_state <= READ_OUT;
          end if;
        when READ_OUT =>
          if cnt_n_reads < n_reads then
            current_state <= IDLE;
          else
            current_state <= WRITE;
          end if;
        when others =>
          current_state <= STANDBY;
        end case;
      end if;
    end if;
  end process p_my_FSM_state;



  p_my_FSM_output: process (current_state)
    begin
      case current_state is
        when STANDBY =>
          mmu_rst_n_tmp    <= '0';
          w_mem_en_tmp     <= '0';
          r_out_tmp        <= '0';
          cnt_read_out_en  <= '0';
          cnt_read_out_clc <= '1';
          en               <= '0';
        when WRITE =>
          mmu_rst_n_tmp    <= '1';
          w_mem_en_tmp     <= '1';
          r_out_tmp        <= '0';
          cnt_read_out_en  <= '0';
          cnt_read_out_clc <= '1';
          en               <= '1';
        when IDLE =>
          mmu_rst_n_tmp    <= '0';
          w_mem_en_tmp     <= '0';
          r_out_tmp        <= '0';
          cnt_read_out_en  <= '1';
          cnt_read_out_clc <= '0';
          en               <= '1';
        when READ_MEM =>
          mmu_rst_n_tmp    <= '1';
          w_mem_en_tmp     <= '0';
          r_out_tmp        <= '0';
          cnt_read_out_en  <= '0';
          cnt_read_out_clc <= '1';
          en               <= '1';
        when READ_OUT =>
          mmu_rst_n_tmp    <= '0';
          w_mem_en_tmp     <= '0';
          r_out_tmp        <= '1';
          cnt_read_out_en  <= '1';
          cnt_read_out_clc <= '1';
          en               <= '1';
        when others =>
          mmu_rst_n_tmp    <= '0';
          w_mem_en_tmp     <= '0';
          r_out_tmp        <= '1';
          cnt_read_out_en  <= '0';
          cnt_read_out_clc <= '1';
          en               <= '0';
    end case;
  end process p_my_FSM_output;


  --- TIME UNITS ---
  -- Counter of the number of reads before a write is needed
  CNT_N_READS_UNIT : entity work.counter_gen generic
    map(
    CNT_WDTH => n_reads'length
    ) port map
    (
    clk     => r_out_tmp,
    RESET_N => rst_n,
    EN      => '1',
    CLC     => w_mem_en_tmp,
    DIR     => '1',
    CNT_TO  => n_reads,
    CNT     => cnt_n_reads
    );

  -- Counter to wait the time needed to read mem
  -- PROBLEM: WITH THE CLOCK_DIV FOR SECONDS CAN'T GO BELOW 1SEC
  -- TODO: MISSING ENABLE, always active SOLVED with RST
  CLK_DIV_SECONDS : entity work.clock_divider generic
    map (LIMIT => 100000000/2) port --1 sec posedge+negedge
    map (clk, (rst_n and cnt_read_out_en) , seconds); -- If any of them 0, has to be like that to start counting corrrectly
  
  -- Resolution selector s vs 1e-6s check
    -- TODO: Clock combination Checker
  cnt_read_clock <= seconds when t_write_resolution='1' else clk;
  
  CNT_READ_T : entity work.counter_gen generic
    map(
    CNT_WDTH => t_write'length -- Has to at least match t_write size in case n_reads=1
    ) port
    map
    (
    clk     => cnt_read_clock,
    RESET_N => rst_n,
    EN      => cnt_read_out_en,
    CLC     => cnt_read_out_clc,
    DIR     => '1',
    CNT_TO  => std_logic_vector(unsigned(t_write)/unsigned(n_reads)), --others=0?
    CNT     => cnt_read
    );
  -- SYSTEM_CLK_EN Dirty trick to solve that I was not consistant with ENs
  -- Disables clk 
  -- This should work because I am latching out the signal that has to be sent to MCU
  clk_out <= clk when en = '1' else '0';
  mmu_rst_n <= mmu_rst_n_tmp;
  w_mem_en  <= w_mem_en_tmp;
  r_out_en  <= r_out_tmp;

end RTL;