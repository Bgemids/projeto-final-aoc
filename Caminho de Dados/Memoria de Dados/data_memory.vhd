library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    port (
        Clk       : in  std_logic;
        rst       : in  std_logic; -- Opcional: zera RAM(0) entre execucoes
        MemWrite  : in  std_logic;
        Address   : in  std_logic_vector(31 downto 0);
        WriteData : in  std_logic_vector(31 downto 0);
        ReadData  : out std_logic_vector(31 downto 0);
        ResultOut : out std_logic_vector(31 downto 0)  -- Saida direta de RAM(0) para o ARM
    );
end data_memory;

architecture Behavioral of data_memory is

    -- Memoria com 256 palavras de 32 bits
    type memory_array is array (0 to 255)
        of std_logic_vector(31 downto 0);

    -- Inicializacao das posicoes com zero
    signal RAM : memory_array :=
        (others => (others => '0'));

begin

    -- Expoe continuamente RAM(0) (endereco 0x00002000) para leitura via AXI
    ResultOut <= RAM(0);

    -- LEITURA COMBINACIONAL
    process(Address, RAM)
        variable index : integer;
    begin
        ReadData <= (others => '0');

        -- Verifica apenas alinhamento de palavra (bits 1..0 = "00")
        if Address(1 downto 0) = "00" then
            index := to_integer(unsigned(Address(9 downto 2)));
            ReadData <= RAM(index);
        end if;
    end process;

    -- ESCRITA SINCRONIZADA
    process(Clk)
        variable index : integer;
    begin
        if rising_edge(Clk) then
            if rst = '1' then
                RAM(0) <= (others => '0');
            elsif MemWrite = '1' then
                -- Verifica apenas alinhamento de palavra
                if Address(1 downto 0) = "00" then
                    index := to_integer(unsigned(Address(9 downto 2)));
                    RAM(index) <= WriteData;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
