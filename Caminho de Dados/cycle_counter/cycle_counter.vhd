library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cycle_counter is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        en    : in  std_logic;
        count : out std_logic_vector(63 downto 0)
    );
end entity cycle_counter;

architecture rtl of cycle_counter is
    signal cnt_reg : unsigned(63 downto 0) := (others => '0');
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cnt_reg <= (others => '0');
            elsif en = '1' then
                cnt_reg <= cnt_reg + 1;
            end if;
        end if;
    end process;

    count <= std_logic_vector(cnt_reg);
end architecture rtl;