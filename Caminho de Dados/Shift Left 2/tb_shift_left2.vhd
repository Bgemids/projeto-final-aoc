library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_ShiftLeft2 is
end tb_ShiftLeft2;

architecture behavior of tb_ShiftLeft2 is
    component ShiftLeft2
    Port (
        a : in  std_logic_vector(31 downto 0);
        y : out std_logic_vector(31 downto 0)
    );
    end component;

    signal a : std_logic_vector(31 downto 0) := (others => '0');
    signal y : std_logic_vector(31 downto 0);

begin
    uut: ShiftLeft2 port map (
        a => a,
        y => y
    );

    stim_proc: process
    begin
        a <= x"00000001";
        wait for 10 ns;
        
        a <= x"0000000A";
        wait for 10 ns;
        
        a <= x"FFFFFFFF";
        wait for 10 ns;
        
        wait;
    end process;
end behavior;
