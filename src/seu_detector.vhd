library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.bus_pkg.all;

entity seu_detector is
  generic
  (
    N_READS_TO_WRITE : integer := 1;
    T_READ_OUT       : integer := 10000 -- Random value to test 100MHZ 
  );
  port
  (
    clk_src            : in std_logic;
    rst_n              : in std_logic;
    total_bitflips_out : out std_logic_vector(integer(ceil(log2(real(40 * 256 * 10)))) downto 0) -- Number of errros in binary std_logic_vector(integer(ceil(log2(real(WIDTH_M10K*N_MEMS)))) downto 0)
  );
end seu_detector;

architecture rtl of seu_detector is
  -- CONSTANTS --
  constant N_MEMS    : integer := 10;
  constant MEM_WIDTH : integer := 40;
  constant MEM_ADDRS : integer := 256;

  -- SIGNALS -- 
  signal clk : std_logic;

  -- Control Unit
  signal mmu_rst_n : std_logic;
  signal w_mem_en  : std_logic;
  signal r_out     : std_logic;
  -- Memory
  signal mem_clk    : std_logic;
  signal data       : std_logic_vector(40 - 1 downto 0);
  signal addr       : std_logic_vector(integer(ceil(log2(real(MEM_ADDRS)))) - 1 downto 0);
  signal q_mem      : bus_array(N_MEMS - 1 downto 0)((MEM_WIDTH - 1) downto 0);
  signal mmu_finish : std_logic;

  -- Count Errors
  signal bitflips       : std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * N_MEMS)))) downto 0); -- Number of errros in binary	
  signal addr0_count_bitflips : std_logic; -- Used to cope with the delay introduced by the memory from write to q

  -- Add errors
  signal total_bitflips       : std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * MEM_ADDRS * N_MEMS)))) downto 0); -- Number of errros in binary	

  component ram_m10k
    port
    (
      address : in std_logic_vector (7 downto 0);
      clock   : in std_logic := '1';
      data    : in std_logic_vector (39 downto 0);
      wren    : in std_logic;
      q       : out std_logic_vector (39 downto 0)
    );
  end component;

begin
  clk <= clk_src;

  MMU : entity work.mmu generic
    map(
    MEM_WIDTH => MEM_WIDTH,
    MEM_ADDRS => MEM_ADDRS
    ) port map
    (
    clk        => clk,
    rst_n      => rst_n,
    mem_clk    => mem_clk,
    data       => data,
    addr       => addr,
    mmu_finish => mmu_finish
    );

  --Generic d_ff init based on N. GENERATE all the D Flip Flopps
  GEN_M10K : for i in (N_MEMS - 1) downto 0 generate
    ram_m10k_inst : ram_m10k port
    map (
    address => addr,
    clock   => mem_clk,
    data    => data,
    wren    => w_mem_en,
    q       => q_mem(i)
    );
  end generate;

  -- Delay to cope with memory induced delay from address to q. Only get LSB to minimize resources
  reg : process (clk) begin
    if rising_edge(clk) then
      if rst_n = '1' then
        addr0_count_bitflips <= addr(0);
      else
        addr0_count_bitflips <= '0'; -- Not sure if this reset is needed
      end if;
    else
      addr0_count_bitflips <= addr0_count_bitflips;
    end if;
  end process;

  --CNT_ONES : entity work.count_ones GENERIC MAP (din_width=>(N_MEMS*q_m10k_1'length)) PORT MAP (din => (q_mlab_1 & q_mlab_2 & q_m10k_1), dout => total_bitflips);
  CNT_BITFLIPS : entity work.count_bitflips_pattern generic
    map (
    MEM_WIDTH => MEM_WIDTH,
    N_MEMS    => N_MEMS)
    port
    map (
    din   => q_mem,
    addr0 => addr0_count_bitflips,
    dout  => bitflips);


 SUM_BITFLIPS : entity work.sum_bitflips generic map(
    MEM_WIDTH => MEM_WIDTH,
	MEM_ADDRS => MEM_ADDRS,
    N_MEMS    => N_MEMS
 ) port map (
	clk => mem_clk,
	rst_n => rst_n,
	bitflips => bitflips,
	total_bitflips => total_bitflips
 );


 READ_OUT_REG : entity work.read_out_reg generic map(
    MEM_WIDTH => MEM_WIDTH,
	MEM_ADDRS => MEM_ADDRS,
    N_MEMS    => N_MEMS
  )port map(
	clk => mem_clk,
	rst_n => rst_n,
	en => r_out,
	din => total_bitflips,
	dout => total_bitflips_out
	);

end rtl;