library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity data_memory is
    port (
        Clk       : in  std_logic;
        MemWrite  : in  std_logic;
        Address   : in  std_logic_vector(31 downto 0);
        WriteData : in  std_logic_vector(31 downto 0);
        ReadData  : out std_logic_vector(31 downto 0)
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

    -- LEITURA COMBINACIONAL
    process(Address, RAM)
        variable index : integer;
    begin

        -- Valor padrao da saida
        ReadData <= (others => '0');

        -- Verifica alinhamento e faixa de endereco
        if Address(1 downto 0) = "00" and
           unsigned(Address(31 downto 10)) = to_unsigned(0, 22) then

            index := to_integer(unsigned(Address(9 downto 2)));

            ReadData <= RAM(index);

        end if;

    end process;

    -- ESCRITA SINCRONIZADA
    process(Clk)
        variable index : integer;
    begin

        if rising_edge(Clk) then

            if MemWrite = '1' then

                -- Verifica alinhamento e faixa de endereco
                if Address(1 downto 0) = "00" and
                   unsigned(Address(31 downto 10)) = to_unsigned(0, 22) then

                    index := to_integer(unsigned(Address(9 downto 2)));

                    RAM(index) <= WriteData;

                end if;

            end if;

        end if;

    end process;

end Behavioral;
