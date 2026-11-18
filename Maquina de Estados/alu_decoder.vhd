--------------------------------------------------------------------------------
-- alu_decoder.vhd
-- Decodificador da ALU - MIPS single-cycle 32 bits
--
-- Entradas: ALUOp (vem do decodificador principal)
--           Funct (bits 5..0 da instrucao, usado so em instrucoes R-type)
-- Saida   : ALUControl (3 bits) - operacao que a ALU deve executar
--
-- Implementa a tabela "Operacoes do ALU" do enunciado:
--   ALUOp  funct    ALUControl
--   00     X        010 (add)
--   X1     X        110 (sub)
--   1X     100000   010 (add)
--   1X     100010   110 (sub)
--   1X     100100   000 (and)
--   1X     100101   001 (or)
--   1X     101010   111 (slt)
--   1X     101011   011 (mult)  -> 011 "nao e usado" pela ALU (resultado 0)
--
-- Bloco puramente combinacional: nao usa clock nem reset.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu_decoder is
    port (
        ALUOp      : in  std_logic_vector(1 downto 0);  -- 00 = soma | X1 = subtracao | 1X = olhar funct
        Funct      : in  std_logic_vector(5 downto 0);  -- Instr(5 downto 0)
        ALUControl : out std_logic_vector(2 downto 0)
    );
end entity alu_decoder;

architecture rtl of alu_decoder is

    -- Codigos de operacao da ALU
    constant ALU_AND  : std_logic_vector(2 downto 0) := "000";
    constant ALU_OR   : std_logic_vector(2 downto 0) := "001";
    constant ALU_ADD  : std_logic_vector(2 downto 0) := "010";
    constant ALU_MULT : std_logic_vector(2 downto 0) := "011";
    constant ALU_SUB  : std_logic_vector(2 downto 0) := "110";
    constant ALU_SLT  : std_logic_vector(2 downto 0) := "111";

    -- Campo funct das instrucoes R-type
    constant F_ADD  : std_logic_vector(5 downto 0) := "100000";
    constant F_SUB  : std_logic_vector(5 downto 0) := "100010";
    constant F_AND  : std_logic_vector(5 downto 0) := "100100";
    constant F_OR   : std_logic_vector(5 downto 0) := "100101";
    constant F_SLT  : std_logic_vector(5 downto 0) := "101010";
    constant F_MULT : std_logic_vector(5 downto 0) := "101011";

begin

    process (ALUOp, Funct)
    begin
        if ALUOp = "00" then
            -- LW, SW, ADDI (e J/JAL, onde o resultado e ignorado): soma
            ALUControl <= ALU_ADD;

        elsif ALUOp(0) = '1' then
            -- X1 - BEQ: subtrai para comparar (Zero = '1' quando A = B)
            ALUControl <= ALU_SUB;

        else
            -- 1X - R-type: a operacao e definida pelo campo funct
            case Funct is
                when F_ADD  => ALUControl <= ALU_ADD;
                when F_SUB  => ALUControl <= ALU_SUB;
                when F_AND  => ALUControl <= ALU_AND;
                when F_OR   => ALUControl <= ALU_OR;
                when F_SLT  => ALUControl <= ALU_SLT;
                when F_MULT => ALUControl <= ALU_MULT;
                when others => ALUControl <= ALU_ADD;  -- funct nao suportado: valor seguro
            end case;
        end if;
    end process;

end architecture rtl;
