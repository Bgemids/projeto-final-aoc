library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity adder is
    port (
        a : in  std_logic_vector(31 downto 0);
        b : in  std_logic_vector(31 downto 0);
        y : out std_logic_vector(31 downto 0)
    );
end entity adder;

architecture rtl of adder is
begin
    y <= std_logic_vector(unsigned(a) + unsigned(b));
end architecture rtl;