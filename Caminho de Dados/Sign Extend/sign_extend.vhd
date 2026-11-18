library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity sign_extend is
    port (
        imm16 : in  std_logic_vector(15 downto 0);
        imm32 : out std_logic_vector(31 downto 0)
    );
end sign_extend;

architecture Behavioral of sign_extend is
begin

    imm32 <= std_logic_vector(
        resize(signed(imm16), 32)
    );

end Behavioral;
