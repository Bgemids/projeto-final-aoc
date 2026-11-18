library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mux2 is
    generic (
        N : integer := 32
    );
    port (
        A   : in  std_logic_vector(N-1 downto 0);
        B   : in  std_logic_vector(N-1 downto 0);
        Sel : in  std_logic;
        Y   : out std_logic_vector(N-1 downto 0)
    );
end mux2;

architecture Behavioral of mux2 is
begin

    Y <= B when Sel = '1' else A;

end Behavioral;
