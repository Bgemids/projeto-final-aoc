--------------------------------------------------------------------------------
-- tb_control_unit.vhd
-- Testbench auto-verificavel da unidade de controle.
-- Aplica cada instrucao suportada e compara todas as saidas com o esperado.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_control_unit is
end entity tb_control_unit;

architecture sim of tb_control_unit is

    signal Op, Funct  : std_logic_vector(5 downto 0) := (others => '0');
    signal RegWrite   : std_logic;
    signal RegDst     : std_logic_vector(1 downto 0);
    signal ALUSrc     : std_logic;
    signal Branch     : std_logic;
    signal MemWrite   : std_logic;
    signal MemtoReg   : std_logic_vector(1 downto 0);
    signal Jump       : std_logic;
    signal ALUControl : std_logic_vector(2 downto 0);

    -- Todas as saidas concatenadas, para comparar de uma vez:
    -- RegWrite & RegDst & ALUSrc & Branch & MemWrite & MemtoReg & Jump & ALUControl
    signal ctrl : std_logic_vector(11 downto 0);

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
            ALUControl => ALUControl
        );

    ctrl <= RegWrite & RegDst & ALUSrc & Branch & MemWrite & MemtoReg & Jump & ALUControl;

    stimulus : process

        procedure check (
            constant name     : in string;
            constant op_v     : in std_logic_vector(5 downto 0);
            constant funct_v  : in std_logic_vector(5 downto 0);
            constant expected : in std_logic_vector(11 downto 0)
        ) is
        begin
            Op    <= op_v;
            Funct <= funct_v;
            wait for 10 ns;
            assert ctrl = expected
                report "FALHA em " & name
                severity error;
            if ctrl = expected then
                report "OK: " & name severity note;
            end if;
        end procedure;

    begin
        --                                       RW RD AS Br MW M2R J ALUCtl
        check("ADD",  "000000", "100000", "1" & "01" & "0" & "0" & "0" & "00" & "0" & "010");
        check("SUB",  "000000", "100010", "1" & "01" & "0" & "0" & "0" & "00" & "0" & "110");
        check("AND",  "000000", "100100", "1" & "01" & "0" & "0" & "0" & "00" & "0" & "000");
        check("OR",   "000000", "100101", "1" & "01" & "0" & "0" & "0" & "00" & "0" & "001");
        check("SLT",  "000000", "101010", "1" & "01" & "0" & "0" & "0" & "00" & "0" & "111");
        check("LW",   "100011", "000000", "1" & "00" & "1" & "0" & "0" & "01" & "0" & "010");
        check("SW",   "101011", "000000", "0" & "00" & "1" & "0" & "1" & "00" & "0" & "010");
        check("BEQ",  "000100", "000000", "0" & "00" & "0" & "1" & "0" & "00" & "0" & "110");
        check("ADDI", "001000", "000000", "1" & "00" & "1" & "0" & "0" & "00" & "0" & "010");
        check("J",    "000010", "000000", "0" & "00" & "0" & "0" & "0" & "00" & "1" & "010");
        check("JAL",  "000011", "000000", "1" & "10" & "0" & "0" & "0" & "10" & "1" & "010");
        -- Opcode invalido: nada pode ser escrito e nenhum desvio pode ocorrer
        check("INVALIDO", "111111", "000000", "0" & "00" & "0" & "0" & "0" & "00" & "0" & "010");
        -- Funct com cara de "sub" nao pode afetar LW (ALUOp = 00 ignora o funct)
        check("LW (funct ignorado)", "100011", "100010", "1" & "00" & "1" & "0" & "0" & "01" & "0" & "010");

        report "Fim da simulacao." severity note;
        wait;
    end process;

end architecture sim;
