library ieee;
use ieee.std_logic_1164.all;
------------------------------------------
entity control_unit is
    generic (
        FREQ_READ_OUT:integer:=1; --Test for 1 hz
        N_READS_TO_WRITE:integer:=1 --Number of reads that have to be performed before rewritting mem
        );
    port
    (
    clk : in std_logic;
    rst_n : in std_logic;
    r_out_en    : out std_logic;
    w_mem_en    : out std_logic);
end control_unit;

architecture FSM of control_unit is
  type state_type is (write_mem, read_mem, read_out);
  signal next_state, current_state : state_type;


    -- Attribute "safe" implements a safe state machine.
	-- This is a state machine that can recover from an
	-- illegal state (by returning to the reset state).
	attribute syn_encoding : string;
	attribute syn_encoding of state_type : type is "safe";


begin

  process (clk, rst_n)
  begin
    if (rst_n = '0') then
        current_state <= write_mem;
    elsif (clk'event and clk = '1') then
        current_state <= next_state;
    end if;
  end process;


  process (clk)
  begin
    if rising_edge(clk) then
      case current_state is
        when write_mem =>
            r_out_en <= '0';
            w_mem_en <= '1'; 
        when read_mem =>
            r_out_en <= '0';
            w_mem_en <= '1'; 
        when read_out =>
            r_out_en <= '0';
            w_mem_en <= '1'; 
        when others =>
            r_out_en <= '0';
            w_mem_en <= '0'; 
      end case;
    end if;
  end process;



end FSM;