--------------------------------------------------------------------------------
-- tb_control_unit.vhd
-- Testbench auto-verificavel da unidade de controle.
-- Aplica cada instrucao suportada e compara todas as saidas com o esperado.
-- Tambem testa o decodificador da ALU sozinho para ALUOp = "11" (linha X1
-- da tabela do enunciado), que o decodificador principal nunca gera.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_control_unit is
end entity tb_control_unit;

architecture sim of tb_control_unit is

    signal Op, Funct  : std_logic_vector(5 downto 0) := (others => '0');
    signal RegWrite   : std_logic;
    signal RegDst     : std_logic;
    signal ALUSrc     : std_logic;
    signal Branch     : std_logic;
    signal MemWrite   : std_logic;
    signal MemtoReg   : std_logic;
    signal Jump       : std_logic;
    signal Jal        : std_logic;
    signal ALUControl : std_logic_vector(2 downto 0);

    -- Todas as saidas concatenadas, para comparar de uma vez:
    -- RegWrite & RegDst & ALUSrc & Branch & MemWrite & MemtoReg & Jump & Jal & ALUControl
    signal ctrl : std_logic_vector(10 downto 0);

    -- Decodificador da ALU isolado (teste da linha X1)
    signal t_ALUOp      : std_logic_vector(1 downto 0) := "00";
    signal t_ALUControl : std_logic_vector(2 downto 0);

    signal errors : natural := 0;

begin

    dut : entity work.control_unit
        port map (
            Op         => Op,
            Funct      => Funct,
            RegWrite   => RegWrite,
            RegDst     => RegDst,
            ALUSrc     => ALUSrc,
            Branch     => Branch,
            MemWrite   => MemWrite,
            MemtoReg   => MemtoReg,
            Jump       => Jump,
            Jal        => Jal,
            ALUControl => ALUControl
        );

    dut_alu_dec : entity work.alu_decoder
        port map (
            ALUOp      => t_ALUOp,
            Funct      => Funct,
            ALUControl => t_ALUControl
        );

    ctrl <= RegWrite & RegDst & ALUSrc & Branch & MemWrite & MemtoReg & Jump & Jal & ALUControl;

    stimulus : process

        procedure check (
            constant name     : in string;
            constant op_v     : in std_logic_vector(5 downto 0);
            constant funct_v  : in std_logic_vector(5 downto 0);
            constant expected : in std_logic_vector(10 downto 0)
        ) is
        begin
            Op    <= op_v;
            Funct <= funct_v;
            wait for 10 ns;
            if ctrl = expected then
                report "OK: " & name severity note;
            else
                report "FALHA em " & name severity error;
                errors <= errors + 1;
            end if;
        end procedure;

    begin
        --                                        RW    RD    AS    Br    MW    M2R   J     Jal   ALUCtl
        check("ADD",  "000000", "100000",        "1" & "1" & "0" & "0" & "0" & "0" & "0" & "0" & "010");
        check("SUB",  "000000", "100010",        "1" & "1" & "0" & "0" & "0" & "0" & "0" & "0" & "110");
        check("AND",  "000000", "100100",        "1" & "1" & "0" & "0" & "0" & "0" & "0" & "0" & "000");
        check("OR",   "000000", "100101",        "1" & "1" & "0" & "0" & "0" & "0" & "0" & "0" & "001");
        check("SLT",  "000000", "101010",        "1" & "1" & "0" & "0" & "0" & "0" & "0" & "0" & "111");
        check("MULT (tabela: 011)", "000000", "101011",
                                                 "1" & "1" & "0" & "0" & "0" & "0" & "0" & "0" & "011");
        check("LW",   "100011", "000000",        "1" & "0" & "1" & "0" & "0" & "1" & "0" & "0" & "010");
        check("SW",   "101011", "000000",        "0" & "0" & "1" & "0" & "1" & "0" & "0" & "0" & "010");
        check("BEQ",  "000100", "000000",        "0" & "0" & "0" & "1" & "0" & "0" & "0" & "0" & "110");
        check("ADDI", "001000", "000000",        "1" & "0" & "1" & "0" & "0" & "0" & "0" & "0" & "010");
        check("J",    "000010", "000000",        "0" & "0" & "0" & "0" & "0" & "0" & "1" & "0" & "010");
        check("JAL",  "000011", "000000",        "1" & "0" & "0" & "0" & "0" & "0" & "1" & "1" & "010");
        -- Opcode invalido: nada pode ser escrito e nenhum desvio pode ocorrer
        check("INVALIDO", "111111", "000000",    "0" & "0" & "0" & "0" & "0" & "0" & "0" & "0" & "010");
        -- Funct com cara de "sub" nao pode afetar LW (ALUOp = 00 ignora o funct)
        check("LW (funct ignorado)", "100011", "100010",
                                                 "1" & "0" & "1" & "0" & "0" & "1" & "0" & "0" & "010");

        -- Linha X1 da tabela: ALUOp = "11" deve gerar subtracao, qualquer funct
        t_ALUOp <= "11";
        Funct   <= "100100";  -- funct de AND, deve ser ignorado
        wait for 10 ns;
        if t_ALUControl = "110" then
            report "OK: ALUOp = 11 -> sub" severity note;
        else
            report "FALHA em ALUOp = 11 -> sub" severity error;
            errors <= errors + 1;
        end if;

        wait for 1 ns;
        if errors = 0 then
            report "TODOS OS TESTES DA CONTROLADORA PASSARAM" severity note;
        else
            report integer'image(errors) & " TESTE(S) FALHARAM" severity failure;
        end if;
        wait;
    end process;

end architecture sim;
