library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RegisterFile is
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
end RegisterFile;

architecture Behavioral of RegisterFile is
    type reg_array is array (0 to 31) of std_logic_vector(31 downto 0);
    signal regs : reg_array := (others => (others => '0'));
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                regs <= (others => (others => '0'));
            elsif we3 = '1' then
                if to_integer(unsigned(a3)) /= 0 then
                    regs(to_integer(unsigned(a3))) <= wd3;
                end if;
            end if;
        end if;
    end process;

    rd1 <= x"00000000" when to_integer(unsigned(a1)) = 0 else regs(to_integer(unsigned(a1)));
    rd2 <= x"00000000" when to_integer(unsigned(a2)) = 0 else regs(to_integer(unsigned(a2)));
end Behavioral;
