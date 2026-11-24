library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity pc_register is
    port (
        clk : in  std_logic;
        rst : in  std_logic;
        en  : in  std_logic;
        d   : in  std_logic_vector(31 downto 0);
        q   : out std_logic_vector(31 downto 0)
    );
end entity pc_register;

architecture rtl of pc_register is
    signal pc_reg : std_logic_vector(31 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                pc_reg <= (others => '0');
            elsif en = '1' then
                pc_reg <= d;
            end if;
        end if;
    end process;

    q <= pc_reg;
end architecture rtl;