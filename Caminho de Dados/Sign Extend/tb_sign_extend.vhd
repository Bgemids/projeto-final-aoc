library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_sign_extend is
end tb_sign_extend;

architecture test of tb_sign_extend is

    signal imm16 : std_logic_vector(15 downto 0);
    signal imm32 : std_logic_vector(31 downto 0);

begin

    uut: entity work.sign_extend
        port map (
            imm16 => imm16,
            imm32 => imm32
        );

    stimulus: process
    begin

        -- Teste 1: imediato positivo
        imm16 <= x"000A";

        wait for 10 ns;

        assert imm32 = x"0000000A"
            report "ERRO: extensao de sinal positiva"
            severity error;

        -- Teste 2: maior valor positivo de 16 bits
        imm16 <= x"7FFF";

        wait for 10 ns;

        assert imm32 = x"00007FFF"
            report "ERRO: extensao do maior positivo"
            severity error;

        -- Teste 3: imediato negativo
        imm16 <= x"8000";

        wait for 10 ns;

        assert imm32 = x"FFFF8000"
            report "ERRO: extensao de sinal negativa"
            severity error;

        -- Teste 4: imediato -1
        imm16 <= x"FFFF";

        wait for 10 ns;

        assert imm32 = x"FFFFFFFF"
            report "ERRO: extensao do valor -1"
            severity error;

        report "TESTES DO SIGN EXTEND CONCLUIDOS!"
            severity note;

        wait;
    end process;

end test;
