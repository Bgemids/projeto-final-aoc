--------------------------------------------------------------------------------
-- control_unit.vhd
-- Unidade de controle (controladora) - MIPS single-cycle 32 bits
--
-- Modulo de topo da controladora: apenas interliga o decodificador principal
-- e o decodificador da ALU. E este o componente instanciado no processador.
--
-- Ligacao com o caminho de dados:
--   Op    <= Instr(31 downto 26)
--   Funct <= Instr(5 downto 0)
--   PCSrc <= Branch and Zero   (porta AND fica no caminho de dados / topo)
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
        RegDst     : out std_logic_vector(1 downto 0);  -- 00 = rt | 01 = rd | 10 = $ra (31)
        ALUSrc     : out std_logic;                     -- 0 = RD2 | 1 = imediato estendido
        Branch     : out std_logic;                     -- 1 = BEQ
        MemWrite   : out std_logic;                     -- habilita escrita na memoria de dados
        MemtoReg   : out std_logic_vector(1 downto 0);  -- 00 = ALUResult | 01 = ReadData | 10 = PC+4
        Jump       : out std_logic;                     -- 1 = J / JAL
        ALUControl : out std_logic_vector(2 downto 0)   -- operacao da ALU
    );
end entity control_unit;

architecture structural of control_unit is

    -- Sinal interno: liga o decodificador principal ao decodificador da ALU
    signal ALUOp : std_logic_vector(1 downto 0);

begin

    u_main_decoder : entity work.main_decoder
        port map (
            Op       => Op,
            RegWrite => RegWrite,
            RegDst   => RegDst,
            ALUSrc   => ALUSrc,
            Branch   => Branch,
            MemWrite => MemWrite,
            MemtoReg => MemtoReg,
            Jump     => Jump,
            ALUOp    => ALUOp
        );

    u_alu_decoder : entity work.alu_decoder
        port map (
            ALUOp      => ALUOp,
            Funct      => Funct,
            ALUControl => ALUControl
        );

end architecture structural;
