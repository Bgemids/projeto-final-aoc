library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_RegisterFile is
end tb_RegisterFile;

architecture behavior of tb_RegisterFile is
    component RegisterFile
    Port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        we3   : in  std_logic;
        a1    : in  std_logic_vector(4 downto 0);
        a2    : in  std_logic_vector(4 downto 0);
        a3    : in  std_logic_vector(4 downto 0);
        wd3   : in  std_logic_vector(31 downto 0);
        rd1   : out std_logic_vector(31 downto 0);
        rd2   : out std_logic_vector(31 downto 0)
    );
    end component;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '0';
    signal we3   : std_logic := '0';
    signal a1    : std_logic_vector(4 downto 0) := (others => '0');
    signal a2    : std_logic_vector(4 downto 0) := (others => '0');
    signal a3    : std_logic_vector(4 downto 0) := (others => '0');
    signal wd3   : std_logic_vector(31 downto 0) := (others => '0');
    signal rd1   : std_logic_vector(31 downto 0);
    signal rd2   : std_logic_vector(31 downto 0);

    signal sim_finished : boolean := false;
    constant clk_period : time := 10 ns;

begin
    uut: RegisterFile port map (
        clk => clk, rst => rst, we3 => we3,
        a1 => a1, a2 => a2, a3 => a3,
        wd3 => wd3, rd1 => rd1, rd2 => rd2
    );

    clk_process :process
    begin
        while not sim_finished loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

    stim_proc: process
    begin
        rst <= '1';
        wait for clk_period;
        rst <= '0';

        we3 <= '1';
        a3 <= "00000";
        wd3 <= x"FFFFFFFF";
        wait for clk_period;
        
        we3 <= '0';
        a1 <= "00000"; 
        wait for clk_period;

        we3 <= '1';
        a3 <= "01000";
        wd3 <= x"000000AA";
        wait for clk_period;

        a3 <= "01001";
        wd3 <= x"000000BB";
        wait for clk_period;

        we3 <= '0';
        a1 <= "01000";
        a2 <= "01001";
        wait for clk_period * 2;
        
        rst <= '1';
        wait for clk_period;

        sim_finished <= true;
        wait;
    end process;
end behavior;
