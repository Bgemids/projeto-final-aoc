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
-- Bloco puramente combinacional: nao usa clock nem reset.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity main_decoder is
    port (
        Op       : in  std_logic_vector(5 downto 0);  -- opcode = Instr(31 downto 26)
        RegWrite : out std_logic;                     -- habilita escrita no banco de registradores
        RegDst   : out std_logic_vector(1 downto 0);  -- 00 = rt | 01 = rd | 10 = $ra (31)
        ALUSrc   : out std_logic;                     -- 0 = RD2 | 1 = imediato estendido
        Branch   : out std_logic;                     -- 1 = instrucao BEQ
        MemWrite : out std_logic;                     -- habilita escrita na memoria de dados
        MemtoReg : out std_logic_vector(1 downto 0);  -- 00 = ALUResult | 01 = ReadData | 10 = PC+4
        Jump     : out std_logic;                     -- 1 = desvio incondicional (J / JAL)
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
    -- Bit:   10        9..8     7        6        5          4..3       2      1..0
    --        RegWrite  RegDst   ALUSrc   Branch   MemWrite   MemtoReg   Jump   ALUOp
    signal controls : std_logic_vector(10 downto 0);

begin

    -- Tabela verdade do decodificador principal
    process (Op)
    begin
        case Op is
            --                       RW  RD   AS  Br  MW  M2R  J   ALUOp
            when OP_RTYPE => controls <= "1" & "01" & "0" & "0" & "0" & "00" & "0" & "10";
            when OP_LW    => controls <= "1" & "00" & "1" & "0" & "0" & "01" & "0" & "00";
            when OP_SW    => controls <= "0" & "00" & "1" & "0" & "1" & "00" & "0" & "00";
            when OP_BEQ   => controls <= "0" & "00" & "0" & "1" & "0" & "00" & "0" & "01";
            when OP_ADDI  => controls <= "1" & "00" & "1" & "0" & "0" & "00" & "0" & "00";
            when OP_J     => controls <= "0" & "00" & "0" & "0" & "0" & "00" & "1" & "00";
            when OP_JAL   => controls <= "1" & "10" & "0" & "0" & "0" & "10" & "1" & "00";
            -- Opcode nao suportado: nenhuma escrita e nenhum desvio (equivale a um NOP)
            when others   => controls <= (others => '0');
        end case;
    end process;

    -- Separacao da palavra de controle nos sinais individuais
    RegWrite <= controls(10);
    RegDst   <= controls(9 downto 8);
    ALUSrc   <= controls(7);
    Branch   <= controls(6);
    MemWrite <= controls(5);
    MemtoReg <= controls(4 downto 3);
    Jump     <= controls(2);
    ALUOp    <= controls(1 downto 0);

end architecture rtl;
