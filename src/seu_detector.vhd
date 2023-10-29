library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.bus_pkg.all;

entity seu_detector is 
	generic (N_MLAB:integer:=2;
				N_M10K:integer:=10;
				WIDTH_M10K:integer:=40);
	port (clk_src, rst  : in  std_logic;						
	      total_errors_out : out std_logic_vector(integer(ceil(log2(real(WIDTH_M10K*N_M10K)))) downto 0) -- Number of errros in binary
		);	
end seu_detector;

architecture rtl of seu_detector is	
	signal clk : std_logic;
	
	signal clk_mlab : std_logic;
	signal clk_write : std_logic;	
	signal write_en : std_logic;
	signal read_en : std_logic;
	signal write_data : std_logic_vector(N_MLAB-1 downto 0) := (others => '1');
	signal read_data : std_logic_vector(N_MLAB-1 downto 0);
	--signal total_errors : unsigned(31 downto 0) := (others => '0');
	signal rdaddress_sig : STD_LOGIC_VECTOR (7 DOWNTO 0) ;
	signal wraddress_sig		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal data_sig : STD_LOGIC_VECTOR (19 DOWNTO 0) := (others => '1');
	signal data_sig_m10k : STD_LOGIC_VECTOR (39 DOWNTO 0) := (others => '1');
	signal q_mlab_1, q_mlab_2		:  STD_LOGIC_VECTOR (19 DOWNTO 0);
	signal q_m10k_1, q_m10k_2		:  STD_LOGIC_VECTOR (39 DOWNTO 0);
	--constant count_ones_witdh: integer := (N_MLAB*q_mlab_1'length);
	--signal cnt_input :  STD_LOGIC_VECTOR (count_ones_witdh-1 DOWNTO 0);
	signal total_errors: std_logic_vector(integer(ceil(log2(real(q_m10k_1'length*N_M10K)))) downto 0); -- Number of errros in binary		
	--signal count_errors_din : std_logic_vector((N_M10K * q_m10k_1'length - 1) downto 0);
	signal count_errors_din : bus_array(N_M10K-1 downto 0)((q_m10k_1'length - 1) downto 0);
		
		
	attribute preserve : boolean ;
	attribute preserve of q_mlab_1 : signal is true;
	attribute preserve of q_mlab_2 : signal is true;


	component ram_m10k IS
	PORT
	(
		clock		: IN STD_LOGIC  := '1';
		data		: IN STD_LOGIC_VECTOR (39 DOWNTO 0);
		rdaddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wraddress		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren		: IN STD_LOGIC  := '0';
		q		: OUT STD_LOGIC_VECTOR (39 DOWNTO 0)
	);
	END component;
	
begin
	
	
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
		
		
	--Generic d_ff init based on N. GENERATE all the D Flip Flopps
	GEN_M10K: for i in (N_M10K-1) downto 0 generate
		ram_m10k_inst : work.ram_m10k PORT MAP (
			data	 => data_sig_m10k,
			rdaddress	 => rdaddress_sig,
			wraddress	 => wraddress_sig,
			clock	 => clk,
			wren	 => write_en,
			q	 => count_errors_din(i)
		);
		--count_errors_din(i)<=q_m10k_1;
	end generate;

	
	
	
	
	--CNT_ONES : entity work.count_ones GENERIC MAP (din_width=>(N_M10K*q_m10k_1'length)) PORT MAP (din => (q_mlab_1 & q_mlab_2 & q_m10k_1), dout => total_errors);
	CNT_ERRORS_PATTERN : entity work.count_errors_pattern GENERIC MAP (
		din_width=>40, 
		n_arrays=>N_M10K, 
		pattern=>"1010101010101010101010101010101010101010")
		PORT MAP (
			din => count_errors_din, 
			dout => total_errors);
	total_errors_out <= total_errors;

---- Memory Dumping
--	sum_errors : process(clk) begin
--		rdaddress_sig <=  std_logic_vector( unsigned(rdaddress_sig) + 1 );
--		total_errors <= total_errors + unsigned(total_errors);
--	end process;	
	
	-- READ
--	process(clk) begin
--		if read_en = '1' then
--			total_errors_out <= total_errors;
--		end if;
--	end process;
	
	-- Write-Update
--	process(clk) begin
--		if write_en = 1 then
--			data_sig
--		end if;
--	end process;
	
	
end rtl;
