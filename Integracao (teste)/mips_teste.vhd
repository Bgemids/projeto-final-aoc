--------------------------------------------------------------------------------
-- mips_teste.vhd
-- Processador de TESTE, so para verificar a compatibilidade entre os blocos
-- do caminho de dados (Clarice e Fernanda) e a controladora (Maquina de Estados).
-- O PC e a memoria de instrucoes aqui sao PROVISORIOS: os definitivos sao a
-- parte do Bruno e devem substituir estes quando estiverem prontos.
-- O programa da ROM esta em programa_teste.asm.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mips_teste is
    port (clk, rst : in std_logic;
          PC_out, Instr_out, ALUResult_out, WriteData_out : out std_logic_vector(31 downto 0);
          MemWrite_out : out std_logic);
end entity;

architecture rtl of mips_teste is
    type rom_t is array (0 to 63) of std_logic_vector(31 downto 0);
    constant ROM : rom_t := (
         0 => x"20080005",  -- 00: addi $t0,$0,5
         1 => x"20090000",  -- 04: addi $t1,$0,0
         2 => x"01284820",  -- 08: loop: add $t1,$t1,$t0
         3 => x"2108FFFF",  -- 0C: addi $t0,$t0,-1
         4 => x"11000001",  -- 10: beq $t0,$0,done
         5 => x"08000002",  -- 14: j loop
         6 => x"AC090000",  -- 18: done: sw $t1,0($0)
         7 => x"8C0A0000",  -- 1C: lw $t2,0($0)
         8 => x"0C00000A",  -- 20: jal func
         9 => x"08000009",  -- 24: j fim (nao deve executar)
        10 => x"200B0007",  -- 28: func: addi $t3,$0,7
        11 => x"AC0B0004",  -- 2C: sw $t3,4($0)
        12 => x"AC1F0008",  -- 30: sw $ra,8($0)
        13 => x"012A582A",  -- 34: slt $t3,$t1,$t2
        14 => x"0800000E",  -- 38: fim: j fim
        others => x"00000000");
    signal PC, PCNext, PCPlus4, PCBranch, PCJump, PCBrMux, Instr : std_logic_vector(31 downto 0);
    signal SignImm, SignImmSh, SrcA, SrcB, WriteData, ALUResult, ReadData : std_logic_vector(31 downto 0);
    signal ResultMem, Result : std_logic_vector(31 downto 0);
    signal WriteReg0, WriteReg : std_logic_vector(4 downto 0);
    signal RegWrite, RegDst, ALUSrc, Branch, MemWrite, MemtoReg, Jump, Jal, Zero, PCSrc : std_logic;
    signal ALUControl : std_logic_vector(2 downto 0);
begin
    -- PC provisorio: registrador com reset sincrono ativo em alto
    process(clk) begin
        if rising_edge(clk) then
            if rst = '1' then PC <= (others => '0'); else PC <= PCNext; end if;
        end if;
    end process;
    -- Memoria de instrucoes provisoria (ROM combinacional)
    Instr   <= ROM(to_integer(unsigned(PC(7 downto 2))));
    PCPlus4 <= std_logic_vector(unsigned(PC) + 4);

    cu: entity work.control_unit port map (
        Op => Instr(31 downto 26), Funct => Instr(5 downto 0),
        RegWrite => RegWrite, RegDst => RegDst, ALUSrc => ALUSrc, Branch => Branch,
        MemWrite => MemWrite, MemtoReg => MemtoReg, Jump => Jump, Jal => Jal,
        ALUControl => ALUControl);

    rf: entity work.RegisterFile port map (
        clk => clk, rst => rst, we3 => RegWrite,
        a1 => Instr(25 downto 21), a2 => Instr(20 downto 16), a3 => WriteReg,
        wd3 => Result, rd1 => SrcA, rd2 => WriteData);

    mux_regdst: entity work.mux2 generic map (N => 5) port map (
        A => Instr(20 downto 16), B => Instr(15 downto 11), Sel => RegDst, Y => WriteReg0);
    mux_jal_reg: entity work.mux2 generic map (N => 5) port map (
        A => WriteReg0, B => "11111", Sel => Jal, Y => WriteReg);

    se: entity work.sign_extend port map (imm16 => Instr(15 downto 0), imm32 => SignImm);

    mux_alusrc: entity work.mux2 generic map (N => 32) port map (
        A => WriteData, B => SignImm, Sel => ALUSrc, Y => SrcB);

    alu_i: entity work.ALU port map (
        SrcA => SrcA, SrcB => SrcB, ALUControl => ALUControl, ALUResult => ALUResult, Zero => Zero);

    dm: entity work.data_memory port map (
        Clk => clk, MemWrite => MemWrite, Address => ALUResult, WriteData => WriteData, ReadData => ReadData);

    mux_memtoreg: entity work.mux2 generic map (N => 32) port map (
        A => ALUResult, B => ReadData, Sel => MemtoReg, Y => ResultMem);
    mux_jal_res: entity work.mux2 generic map (N => 32) port map (
        A => ResultMem, B => PCPlus4, Sel => Jal, Y => Result);

    sl2: entity work.ShiftLeft2 port map (a => SignImm, y => SignImmSh);
    PCBranch <= std_logic_vector(unsigned(PCPlus4) + unsigned(SignImmSh));
    PCSrc    <= Branch and Zero;
    PCJump   <= PCPlus4(31 downto 28) & Instr(25 downto 0) & "00";

    mux_pcsrc: entity work.mux2 generic map (N => 32) port map (
        A => PCPlus4, B => PCBranch, Sel => PCSrc, Y => PCBrMux);
    mux_jump: entity work.mux2 generic map (N => 32) port map (
        A => PCBrMux, B => PCJump, Sel => Jump, Y => PCNext);

    PC_out <= PC; Instr_out <= Instr; ALUResult_out <= ALUResult;
    WriteData_out <= WriteData; MemWrite_out <= MemWrite;
end architecture;
