--------------------------------------------------------------------------------
-- main_decoder.vhd
-- Decodificador principal da unidade de controle - MIPS single-cycle 32 bits
--
-- Entrada : Op (opcode, bits 31..26 da instrucao)
-- Saidas  : sinais de controle do caminho de dados + ALUOp (interno)
--
-- Instrucoes suportadas:
--   R-type (000000), LW (100011), SW (101011), BEQ (000100),
--   ADDI (001000), J (000010), JAL (000011)
--
-- Os sinais RegDst e MemtoReg tem 1 bit, como na figura do professor, e
-- selecionam os multiplexadores 2:1 (mux2) do caminho de dados.
-- Para o JAL foram acrescentados dois sinais (fora da figura do professor):
--   Jump : seleciona o endereco de salto no proximo PC (J e JAL)
--   Jal  : forca o registrador de destino para $ra (31) e o dado escrito
--          para PC+4 (dois mux2 extras no caminho de dados)
--
-- Bloco puramente combinacional: nao usa clock nem reset.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_decoder is
    port (
        Op       : in  std_logic_vector(5 downto 0);  -- opcode = Instr(31 downto 26)
        RegWrite : out std_logic;                     -- habilita escrita no banco de registradores
        RegDst   : out std_logic;                     -- 0 = rt | 1 = rd
        ALUSrc   : out std_logic;                     -- 0 = RD2 | 1 = imediato estendido
        Branch   : out std_logic;                     -- 1 = instrucao BEQ
        MemWrite : out std_logic;                     -- habilita escrita na memoria de dados
        MemtoReg : out std_logic;                     -- 0 = ALUResult | 1 = ReadData
        Jump     : out std_logic;                     -- 1 = desvio incondicional (J / JAL)
        Jal      : out std_logic;                     -- 1 = JAL (destino $ra, dado PC+4)
        ALUOp    : out std_logic_vector(1 downto 0)   -- 00 = soma | 01 = subtracao | 10 = olhar funct
    );
end entity main_decoder;

architecture rtl of main_decoder is

    -- Opcodes das instrucoes suportadas
    constant OP_RTYPE : std_logic_vector(5 downto 0) := "000000";
    constant OP_J     : std_logic_vector(5 downto 0) := "000010";
    constant OP_JAL   : std_logic_vector(5 downto 0) := "000011";
    constant OP_BEQ   : std_logic_vector(5 downto 0) := "000100";
    constant OP_ADDI  : std_logic_vector(5 downto 0) := "001000";
    constant OP_LW    : std_logic_vector(5 downto 0) := "100011";
    constant OP_SW    : std_logic_vector(5 downto 0) := "101011";

    -- Palavra de controle: todos os sinais concatenados em um unico vetor.
    -- Bit:   9         8        7        6        5          4          3      2     1..0
    --        RegWrite  RegDst   ALUSrc   Branch   MemWrite   MemtoReg   Jump   Jal   ALUOp
    signal controls : std_logic_vector(9 downto 0);

begin

    -- Tabela verdade do decodificador principal
    process (Op)
    begin
        case Op is
            --                          RW    RD    AS    Br    MW    M2R   J     Jal   ALUOp
            when OP_RTYPE => controls <= "1" & "1" & "0" & "0" & "0" & "0" & "0" & "0" & "10";
            when OP_LW    => controls <= "1" & "0" & "1" & "0" & "0" & "1" & "0" & "0" & "00";
            when OP_SW    => controls <= "0" & "0" & "1" & "0" & "1" & "0" & "0" & "0" & "00";
            when OP_BEQ   => controls <= "0" & "0" & "0" & "1" & "0" & "0" & "0" & "0" & "01";
            when OP_ADDI  => controls <= "1" & "0" & "1" & "0" & "0" & "0" & "0" & "0" & "00";
            when OP_J     => controls <= "0" & "0" & "0" & "0" & "0" & "0" & "1" & "0" & "00";
            when OP_JAL   => controls <= "1" & "0" & "0" & "0" & "0" & "0" & "1" & "1" & "00";
            -- Opcode nao suportado: nenhuma escrita e nenhum desvio (equivale a um NOP)
            when others   => controls <= (others => '0');
        end case;
    end process;

    -- Separacao da palavra de controle nos sinais individuais
    RegWrite <= controls(9);
    RegDst   <= controls(8);
    ALUSrc   <= controls(7);
    Branch   <= controls(6);
    MemWrite <= controls(5);
    MemtoReg <= controls(4);
    Jump     <= controls(3);
    Jal      <= controls(2);
    ALUOp    <= controls(1 downto 0);

end architecture rtl;
