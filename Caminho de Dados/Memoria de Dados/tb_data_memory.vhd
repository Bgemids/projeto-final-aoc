library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_data_memory is
end tb_data_memory;

architecture test of tb_data_memory is

    signal Clk       : std_logic := '0';
    signal MemWrite  : std_logic := '0';
    signal Address   : std_logic_vector(31 downto 0);
    signal WriteData : std_logic_vector(31 downto 0);
    signal ReadData  : std_logic_vector(31 downto 0);

begin

    -- Instancia a memoria de dados
    uut: entity work.data_memory
        port map (
            Clk       => Clk,
            MemWrite  => MemWrite,
            Address   => Address,
            WriteData => WriteData,
            ReadData  => ReadData
        );

-- Geracao de clock com duracao limitada
clock_process: process
begin

    for i in 0 to 5 loop

        Clk <= '0';
        wait for 5 ns;

        Clk <= '1';
        wait for 5 ns;

    end loop;

    wait;

end process;

    stimulus: process
    begin

        -- TESTE 1: leitura de posicao inicialmente zerada
        Address <= x"00000004";
        MemWrite <= '0';

        wait for 2 ns;

        assert ReadData = x"00000000"
            report "ERRO: memoria nao iniciou zerada"
            severity error;


        -- TESTE 2: escrita na memoria
        Address <= x"00000004";
        WriteData <= x"DEADBEEF";
        MemWrite <= '1';

        wait until rising_edge(Clk);
        wait for 1 ns;

        MemWrite <= '0';

        wait for 1 ns;

        assert ReadData = x"DEADBEEF"
            report "ERRO: falha na escrita ou leitura"
            severity error;


        -- TESTE 3: escrita em outra posicao
        Address <= x"00000008";
        WriteData <= x"12345678";
        MemWrite <= '1';

        wait until rising_edge(Clk);
        wait for 1 ns;

        MemWrite <= '0';

        wait for 1 ns;

        assert ReadData = x"12345678"
            report "ERRO: falha na segunda escrita"
            severity error;


        -- TESTE 4: tentativa de escrita com MemWrite = 0
        Address <= x"00000004";
        WriteData <= x"FFFFFFFF";
        MemWrite <= '0';

        wait until rising_edge(Clk);
        wait for 1 ns;

        assert ReadData = x"DEADBEEF"
            report "ERRO: memoria escreveu sem habilitacao"
            severity error;


        -- TESTE 5: endereco desalinhado
        Address <= x"00000005";
        WriteData <= x"AAAAAAAA";
        MemWrite <= '1';

        wait until rising_edge(Clk);
        wait for 1 ns;

        MemWrite <= '0';

        assert ReadData = x"00000000"
            report "ERRO: leitura de endereco desalinhado"
            severity error;


        -- TESTE 6: endereco fora da memoria
        Address <= x"00000400";
        WriteData <= x"BBBBBBBB";
        MemWrite <= '1';

        wait until rising_edge(Clk);
        wait for 1 ns;

        MemWrite <= '0';

        assert ReadData = x"00000000"
            report "ERRO: leitura fora da memoria"
            severity error;


        -- TESTE 7: verifica se o dado original foi preservado
        Address <= x"00000004";

        wait for 2 ns;

        assert ReadData = x"DEADBEEF"
            report "ERRO: dado original foi alterado"
            severity error;


        report "TODOS OS TESTES DA DATA MEMORY FORAM CONCLUIDOS!"
            severity note;

        wait;

    end process;

end test;
