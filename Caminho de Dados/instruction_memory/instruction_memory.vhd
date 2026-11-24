library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_memory is
    port(
        A: in std_logic_vector(31 downto 0);
        RD:out std_logic_vector(31 downto 0)
    );
    
end entity;

architecture Behavioral of instruction_memory is

    subtype word_t is std_logic_vector(31 downto 0);
    type memory_t is array(0 to 21) of word_t;

    constant rom: memory_t := (
        0 => x"201004e2", 
        1 => x"201103e8", 
        2 => x"20122710", 
        3 => x"20132000", 
        4 => x"20080000", 
        5 => x"1110000f", 
        6 => x"20090000", 
        7 => x"11310009", 
        8 => x"200a0000", 
        9 => x"11520005", 
        10 => x"8e6b0000", 
        11 => x"0c000013", 
        12 => x"ae6b0000", 
        13 => x"214a0001", 
        14 => x"08000009", 
        15 => x"21290001", 
        16 => x"08000007", 
        17 => x"21080001", 
        18 => x"08000005", 
        19 => x"216b0001", 
        20 => x"03e00008", 
        21 => x"08000015"
    );
    
begin

    RD <= rom(to_integer(unsigned(A(6 downto 2))))
          when (A(1 downto 0) = "00" and unsigned(A(31 downto 2)) <= 21)
          else (others => '0');

end Behavioral;