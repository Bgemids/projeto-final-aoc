--------------------------------------------------------------------------------
-- alu_decoder.vhd
-- Decodificador da ALU - MIPS single-cycle 32 bits
--
-- Entradas: ALUOp (vem do decodificador principal)
--           Funct (bits 5..0 da instrucao, usado so em instrucoes R-type)
-- Saida   : ALUControl (3 bits) - operacao que a ALU deve executar
--
-- Codificacao de ALUControl (tabela do enunciado):
--   000 = A and B | 001 = A or B | 010 = A + B | 110 = A - B | 111 = slt
--
-- Bloco puramente combinacional: nao usa clock nem reset.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_decoder is
    port (
        ALUOp      : in  std_logic_vector(1 downto 0);  -- 00 = soma | 01 = subtracao | 1X = olhar funct
        Funct      : in  std_logic_vector(5 downto 0);  -- Instr(5 downto 0)
        ALUControl : out std_logic_vector(2 downto 0)
    );
end entity alu_decoder;

architecture rtl of alu_decoder is

    -- Codigos de operacao da ALU
    constant ALU_AND : std_logic_vector(2 downto 0) := "000";
    constant ALU_OR  : std_logic_vector(2 downto 0) := "001";
    constant ALU_ADD : std_logic_vector(2 downto 0) := "010";
    constant ALU_SUB : std_logic_vector(2 downto 0) := "110";
    constant ALU_SLT : std_logic_vector(2 downto 0) := "111";

    -- Campo funct das instrucoes R-type
    constant F_ADD : std_logic_vector(5 downto 0) := "100000";
    constant F_SUB : std_logic_vector(5 downto 0) := "100010";
    constant F_AND : std_logic_vector(5 downto 0) := "100100";
    constant F_OR  : std_logic_vector(5 downto 0) := "100101";
    constant F_SLT : std_logic_vector(5 downto 0) := "101010";

begin

    process (ALUOp, Funct)
    begin
        case ALUOp is
            -- LW, SW, ADDI (e J/JAL, onde o resultado e ignorado): soma
            when "00" =>
                ALUControl <= ALU_ADD;

            -- BEQ: subtrai para comparar (Zero = '1' quando A = B)
            when "01" =>
                ALUControl <= ALU_SUB;

            -- R-type ("1X"): a operacao e definida pelo campo funct
            when others =>
                case Funct is
                    when F_ADD  => ALUControl <= ALU_ADD;
                    when F_SUB  => ALUControl <= ALU_SUB;
                    when F_AND  => ALUControl <= ALU_AND;
                    when F_OR   => ALUControl <= ALU_OR;
                    when F_SLT  => ALUControl <= ALU_SLT;
                    when others => ALUControl <= ALU_ADD;  -- funct nao suportado: valor seguro
                end case;
        end case;
    end process;

end architecture rtl;
