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
    clk_src          : in std_logic;
    rst_n            : in std_logic;
    total_bitflips_out : out std_logic_vector(integer(ceil(log2(real(40 * 10)))) downto 0) -- Number of errros in binary std_logic_vector(integer(ceil(log2(real(WIDTH_M10K*N_M10K)))) downto 0)
  );
end seu_detector;

architecture rtl of seu_detector is
  -- CONSTANTS --
  constant N_M10K    : integer := 10;
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
  signal q_mem      : bus_array(N_M10K - 1 downto 0)((MEM_WIDTH - 1) downto 0);
  signal mmu_finish : std_logic;

  -- Count Errors
  signal total_bitflips       : std_logic_vector(integer(ceil(log2(real(MEM_WIDTH * N_M10K)))) downto 0); -- Number of errros in binary	
  signal addr0_count_bitflips : std_logic; -- Used to cope with the delay introduced by the memory from write to q

  -- signal clk_mlab : std_logic;
  -- signal clk_write : std_logic;	
  -- signal write_en : std_logic;
  -- signal read_en : std_logic;
  -- signal write_data : std_logic_vector(N_MLAB-1 downto 0) := (others => '1');
  -- signal read_data : std_logic_vector(N_MLAB-1 downto 0);
  -- --signal total_bitflips : unsigned(31 downto 0) := (others => '0');
  -- signal rdaddress_sig : STD_LOGIC_VECTOR (7 DOWNTO 0) ;
  -- signal wraddress_sig		: STD_LOGIC_VECTOR (7 DOWNTO 0);
  -- signal data_sig : STD_LOGIC_VECTOR (19 DOWNTO 0) := (others => '1');
  -- signal data_sig_m10k : STD_LOGIC_VECTOR (39 DOWNTO 0) := (others => '1');
  -- signal q_mlab_1, q_mlab_2		:  STD_LOGIC_VECTOR (19 DOWNTO 0);
  -- signal q_m10k_1, q_m10k_2		:  STD_LOGIC_VECTOR (39 DOWNTO 0);
  -- --constant count_ones_witdh: integer := (N_MLAB*q_mlab_1'length);
  -- --signal cnt_input :  STD_LOGIC_VECTOR (count_ones_witdh-1 DOWNTO 0);	
  -- --signal count_bitflips_din : std_logic_vector((N_M10K * q_m10k_1'length - 1) downto 0);
  -- PRESERVE LINES --
  -- Needed if Quartus want to simplify my lines :(	
  --attribute preserve : boolean ;
  --attribute preserve of q_mem : signal is true;

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
  -- Could have a clock to UPDATE and to READ
  --CLK_DIV : entity work.clock_divider GENERIC MAP (LIMIT=>25000) port map (clk_src, rst, clk);

  -- Clock at which frequency MLAB memory is dumped
  --CLK_MLAB_DUMP : entity work.clock_divider GENERIC MAP (LIMIT=>25000) port map (clk_src, rst, clk_mlab);

  -- ENABLEs
  --WRITE_EN_GEN: entity work.clock_divider GENERIC MAP (LIMIT=>100000) port map (clk_src, rst, write_en);
  --READ_EN_GEN: entity work.clock_divider GENERIC MAP (LIMIT=>50000) port map (clk_src, rst, read_en);

  --	--Generic d_ff init based on N. GENERATE all the D Flip Flopps
  --	write_data <= (others => write_data_ref);
  --	GEN_MLABS: for i in N_MLAB-1 downto 0 generate
  --		ram_mlab_inst : ram_mlab PORT MAP (
  --			data	 => data_sig,
  --			rdaddress	 => rdaddress_sig,
  --			wraddress	 => wraddress_sig,
  --			wrclock	 => clk,
  --			wren	 => clk_write,
  --			q	 => q_sig
  --		);
  --		D_FF: entity work.d_ff port map (clk, rst, write_data(i), read_data(i));
  --	end generate;

  --		ram_mlab_inst_1 : work.ram_mlab PORT MAP (
  --			data	 => data_sig,
  --			rdaddress	 => rdaddress_sig(4 downto 0),
  --			wraddress	 => wraddress_sig(4 downto 0),
  --			wrclock	 => clk,
  --			wren	 => write_en,
  --			q	 => q_mlab_1
  --		);
  --		
  --		ram_mlab_inst_2 : work.ram_mlab PORT MAP (
  --			data	 => data_sig,
  --			rdaddress	 => rdaddress_sig(4 downto 0),
  --			wraddress	 => wraddress_sig(4 downto 0),
  --			wrclock	 => clk,
  --			wren	 => write_en,
  --			q	 => q_mlab_2
  --		);
  --		ram_m10k_inst_1 : work.ram_m10k PORT MAP (
  --			data	 => data_sig_m10k,
  --			rdaddress	 => rdaddress_sig,
  --			wraddress	 => wraddress_sig,
  --			clock	 => clk,
  --			wren	 => write_en,
  --			q	 => q_m10k_1
  --		);

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
  GEN_M10K : for i in (N_M10K - 1) downto 0 generate
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

  --CNT_ONES : entity work.count_ones GENERIC MAP (din_width=>(N_M10K*q_m10k_1'length)) PORT MAP (din => (q_mlab_1 & q_mlab_2 & q_m10k_1), dout => total_bitflips);
  CNT_ERRORS : entity work.count_bitflips_pattern generic
    map (
    DIN_WIDTH => 40,
    N_ARRAYS  => N_M10K)
    port
    map (
    din   => q_mem,
    addr0 => addr0_count_bitflips,
    dout  => total_bitflips);
  total_bitflips_out <= total_bitflips;

  ---- Memory Dumping
  --	sum_bitflips : process(clk) begin
  --		rdaddress_sig <=  std_logic_vector( unsigned(rdaddress_sig) + 1 );
  --		total_bitflips <= total_bitflips + unsigned(total_bitflips);
  --	end process;	

  -- READ
  --	process(clk) begin
  --		if read_en = '1' then
  --			total_bitflips_out <= total_bitflips;
  --		end if;
  --	end process;

  -- Write-Update
  --	process(clk) begin
  --		if write_en = 1 then
  --			data_sig
  --		end if;
  --	end process;
end rtl;