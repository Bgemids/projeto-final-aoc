library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_mux2 is
end tb_mux2;

architecture test of tb_mux2 is

    signal A   : std_logic_vector(31 downto 0);
    signal B   : std_logic_vector(31 downto 0);
    signal Sel : std_logic;
    signal Y   : std_logic_vector(31 downto 0);

begin

    uut: entity work.mux2
        generic map (
            N => 32
        )
        port map (
            A   => A,
            B   => B,
            Sel => Sel,
            Y   => Y
        );

    stimulus: process
    begin

        -- Teste 1: seleção de A
        A <= x"12345678";
        B <= x"ABCDEF01";
        Sel <= '0';

        wait for 10 ns;

        assert Y = x"12345678"
            report "ERRO: MUX deveria selecionar A"
            severity error;

        -- Teste 2: seleção de B
        Sel <= '1';

        wait for 10 ns;

        assert Y = x"ABCDEF01"
            report "ERRO: MUX deveria selecionar B"
            severity error;

        -- Teste 3: novos valores, selecionando A
        A <= x"FFFFFFFF";
        B <= x"00000000";
        Sel <= '0';

        wait for 10 ns;

        assert Y = x"FFFFFFFF"
            report "ERRO: MUX nao selecionou A corretamente"
            severity error;

        report "TESTES DO MUX CONCLUIDOS!"
            severity note;

        wait;
    end process;

end test;
