--------------------------------------------------------------------------------
-- control_unit.vhd
-- Unidade de controle (controladora) - MIPS single-cycle 32 bits
--
-- Modulo de topo da controladora: interliga o decodificador principal e o
-- decodificador da ALU, e detecta a instrucao JR. E este o componente
-- instanciado no processador.
--
-- Ligacao com o caminho de dados (figura do enunciado):
--   Op        <= Instr(31 downto 26)
--   Funct     <= Instr(5 downto 0)
--   PCSrc     <= Branch and Zero               (porta AND no caminho de dados)
--   RegWrite  -> we3 do banco de registradores (RegisterFile)
--   MemWrite  -> MemWrite da memoria de dados  (data_memory)
--   ALUControl-> ALUControl da ALU             (ALU)
--   RegDst, ALUSrc, MemtoReg -> Sel dos mux2
--
-- Extensao para J, JAL e JR (fora da figura do enunciado):
--   Jump    -> Sel do mux2 que escolhe PCJump = PCPlus4(31..28) & Instr(25..0) & "00"
--   Jal     -> Sel do mux2 (N = 5) que escolhe o registrador 31 como destino
--              e Sel do mux2 que escolhe PCPlus4 como dado escrito
--   JumpReg -> Sel do mux2 que escolhe RD1 (registrador rs) como proximo PC
--
-- JR e uma instrucao R-type (opcode 000000, funct 001000). Como o decodificador
-- principal so ve o opcode, a deteccao do JR fica aqui, onde opcode e funct
-- estao disponiveis. No JR o RegWrite do decodificador principal e anulado,
-- porque o JR nao escreve em nenhum registrador.
--
-- Bloco puramente combinacional: nao usa clock nem reset.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    port (
        Op         : in  std_logic_vector(5 downto 0);  -- Instr(31 downto 26)
        Funct      : in  std_logic_vector(5 downto 0);  -- Instr(5 downto 0)
        RegWrite   : out std_logic;                     -- habilita escrita no banco de registradores
        RegDst     : out std_logic;                     -- 0 = rt | 1 = rd
        ALUSrc     : out std_logic;                     -- 0 = RD2 | 1 = imediato estendido
        Branch     : out std_logic;                     -- 1 = BEQ
        MemWrite   : out std_logic;                     -- habilita escrita na memoria de dados
        MemtoReg   : out std_logic;                     -- 0 = ALUResult | 1 = ReadData
        Jump       : out std_logic;                     -- 1 = J / JAL
        Jal        : out std_logic;                     -- 1 = JAL (destino $ra, dado PC+4)
        JumpReg    : out std_logic;                     -- 1 = JR (proximo PC = registrador rs)
        ALUControl : out std_logic_vector(2 downto 0)   -- operacao da ALU
    );
end entity control_unit;

architecture structural of control_unit is

    constant OP_RTYPE : std_logic_vector(5 downto 0) := "000000";
    constant F_JR     : std_logic_vector(5 downto 0) := "001000";

    -- Sinal interno: liga o decodificador principal ao decodificador da ALU
    signal ALUOp : std_logic_vector(1 downto 0);

    -- RegWrite vindo do decodificador principal, antes de considerar o JR
    signal RegWrite_dec : std_logic;

    -- '1' quando a instrucao atual e JR
    signal is_jr : std_logic;

begin

    u_main_decoder : entity work.main_decoder
        port map (
            Op       => Op,
            RegWrite => RegWrite_dec,
            RegDst   => RegDst,
            ALUSrc   => ALUSrc,
            Branch   => Branch,
            MemWrite => MemWrite,
            MemtoReg => MemtoReg,
            Jump     => Jump,
            Jal      => Jal,
            ALUOp    => ALUOp
        );

    u_alu_decoder : entity work.alu_decoder
        port map (
            ALUOp      => ALUOp,
            Funct      => Funct,
            ALUControl => ALUControl
        );

    -- Deteccao do JR: R-type com funct 001000
    is_jr <= '1' when (Op = OP_RTYPE and Funct = F_JR) else '0';

    JumpReg  <= is_jr;
    RegWrite <= RegWrite_dec and (not is_jr);

end architecture structural;
