library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity single_cycle_MIPS_processor is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        en         : in  std_logic;
        done       : out std_logic;
        result_out : out std_logic_vector(31 downto 0);
        pc_out     : out std_logic_vector(31 downto 0);
        cycles     : out std_logic_vector(63 downto 0)
    );
end entity single_cycle_MIPS_processor;

architecture rtl of single_cycle_MIPS_processor is

    -- Constantes do projeto
    constant FIM_ADDR : std_logic_vector(31 downto 0) := x"00000054"; -- Indice 21 da ROM (j 0x15)
    constant PC_INC   : std_logic_vector(31 downto 0) := x"00000004";
    constant REG_RA   : std_logic_vector(4 downto 0)  := "11111";     -- Registrador 31 ($ra)

    -- Controle de execucao e parada
    signal done_int     : std_logic;
    signal running      : std_logic;
    signal reg_write_en : std_logic;
    signal mem_write_en : std_logic;

    -- Fluxo do PC
    signal pc            : std_logic_vector(31 downto 0);
    signal pc_next       : std_logic_vector(31 downto 0);
    signal pc_plus4      : std_logic_vector(31 downto 0);
    signal pc_branch     : std_logic_vector(31 downto 0);
    signal pc_jump       : std_logic_vector(31 downto 0);
    signal pc_branch_mux : std_logic_vector(31 downto 0);
    signal pc_jump_mux   : std_logic_vector(31 downto 0);
    signal pc_src        : std_logic;

    -- Instrucao atual
    signal instr : std_logic_vector(31 downto 0);

    -- Sinais da Unidade de Controle
    signal reg_write   : std_logic;
    signal reg_dst     : std_logic;
    signal alu_src     : std_logic;
    signal branch      : std_logic;
    signal mem_write   : std_logic;
    signal mem_to_reg  : std_logic;
    signal jump        : std_logic;
    signal jal         : std_logic;
    signal jump_reg    : std_logic;
    signal alu_control : std_logic_vector(2 downto 0);

    -- Datapath (Register File, ULA e Data Memory)
    signal write_reg_base   : std_logic_vector(4 downto 0);
    signal write_reg_final  : std_logic_vector(4 downto 0);
    signal rd1              : std_logic_vector(31 downto 0);
    signal rd2              : std_logic_vector(31 downto 0);
    signal sign_imm         : std_logic_vector(31 downto 0);
    signal sign_imm_shifted : std_logic_vector(31 downto 0);
    signal src_b            : std_logic_vector(31 downto 0);
    signal alu_result       : std_logic_vector(31 downto 0);
    signal zero             : std_logic;
    signal read_data        : std_logic_vector(31 downto 0);
    signal mem_to_reg_out   : std_logic_vector(31 downto 0);
    signal wd3              : std_logic_vector(31 downto 0);

begin

    ----------------------------------------------------------------------------
    -- 1. Logica combinacional de controle de execucao e desvios
    ----------------------------------------------------------------------------
    done_int     <= '1' when pc = FIM_ADDR else '0';
    running      <= en and (not done_int);

    -- Trava escritas no banco de registradores e na RAM quando pausado ou concluido
    reg_write_en <= reg_write and running;
    mem_write_en <= mem_write and running;

    -- Condicao de branch e montagem do endereco de jump
    pc_src       <= branch and zero;
    pc_jump      <= pc_plus4(31 downto 28) & instr(25 downto 0) & "00";

    -- Saidas de monitoramento para o ARM/AXI
    done         <= done_int;
    pc_out       <= pc;

    ----------------------------------------------------------------------------
    -- 2. Busca de instrucao (PC, PC+4 e Instruction Memory)
    ----------------------------------------------------------------------------
    u_pc : entity work.pc_register
        port map (
            clk => clk,
            rst => rst,
            en  => running,
            d   => pc_next,
            q   => pc
        );

    u_add_pc4 : entity work.adder
        port map (
            a => pc,
            b => PC_INC,
            y => pc_plus4
        );

    u_imem : entity work.instruction_memory
        port map (
            A  => pc,
            RD => instr
        );

    ----------------------------------------------------------------------------
    -- 3. Unidade de Controle
    ----------------------------------------------------------------------------
    u_ctrl : entity work.control_unit
        port map (
            Op         => instr(31 downto 26),
            Funct      => instr(5 downto 0),
            RegWrite   => reg_write,
            RegDst     => reg_dst,
            ALUSrc     => alu_src,
            Branch     => branch,
            MemWrite   => mem_write,
            MemtoReg   => mem_to_reg,
            Jump       => jump,
            Jal        => jal,
            JumpReg    => jump_reg,
            ALUControl => alu_control
        );

    ----------------------------------------------------------------------------
    -- 4. Selecao de registrador de destino (RegDst + Mux JAL) e Register File
    ----------------------------------------------------------------------------
    u_mux_regdst : entity work.mux2
        generic map (N => 5)
        port map (
            A   => instr(20 downto 16), -- 0: rt
            B   => instr(15 downto 11), -- 1: rd
            Sel => reg_dst,
            Y   => write_reg_base
        );

    -- Mux extra 1 (JAL): escolhe $ra (31) como destino
    u_mux_jal_reg : entity work.mux2
        generic map (N => 5)
        port map (
            A   => write_reg_base, -- 0: saida do RegDst
            B   => REG_RA,         -- 1: "11111" ($ra)
            Sel => jal,
            Y   => write_reg_final
        );

    u_regfile : entity work.RegisterFile
        port map (
            clk => clk,
            rst => rst,
            we3 => reg_write_en,
            a1  => instr(25 downto 21), -- rs
            a2  => instr(20 downto 16), -- rt
            a3  => write_reg_final,
            wd3 => wd3,
            rd1 => rd1,
            rd2 => rd2
        );

    ----------------------------------------------------------------------------
    -- 5. Extensao de sinal, deslocamento e calculo de PCBranch
    ----------------------------------------------------------------------------
    u_signext : entity work.sign_extend
        port map (
            imm16 => instr(15 downto 0),
            imm32 => sign_imm
        );

    u_shl2 : entity work.ShiftLeft2
        port map (
            a => sign_imm,
            y => sign_imm_shifted
        );

    u_add_branch : entity work.adder
        port map (
            a => sign_imm_shifted,
            b => pc_plus4,
            y => pc_branch
        );

    ----------------------------------------------------------------------------
    -- 6. Execucao (Mux ALUSrc e ALU)
    ----------------------------------------------------------------------------
    u_mux_alusrc : entity work.mux2
        generic map (N => 32)
        port map (
            A   => rd2,      -- 0: registrador rt
            B   => sign_imm, -- 1: imediato estendido
            Sel => alu_src,
            Y   => src_b
        );

    u_alu : entity work.ALU
        port map (
            SrcA       => rd1,
            SrcB       => src_b,
            ALUControl => alu_control,
            ALUResult  => alu_result,
            Zero       => zero
        );

    ----------------------------------------------------------------------------
    -- 7. Memoria de Dados e Write-Back (MemtoReg + Mux JAL)
    ----------------------------------------------------------------------------
    u_dmem : entity work.data_memory
        port map (
            Clk       => clk,
            rst       => rst,
            MemWrite  => mem_write_en,
            Address   => alu_result,
            WriteData => rd2,
            ReadData  => read_data,
            ResultOut => result_out
        );

    u_mux_memtoreg : entity work.mux2
        generic map (N => 32)
        port map (
            A   => alu_result, -- 0: resultado da ULA
            B   => read_data,  -- 1: dado lido da RAM
            Sel => mem_to_reg,
            Y   => mem_to_reg_out
        );

    -- Mux extra 2 (JAL): grava PC+4 em $ra
    u_mux_jal_data : entity work.mux2
        generic map (N => 32)
        port map (
            A   => mem_to_reg_out, -- 0: resultado normal (ULA ou RAM)
            B   => pc_plus4,       -- 1: endereco de retorno (PC+4)
            Sel => jal,
            Y   => wd3
        );

    ----------------------------------------------------------------------------
    -- 8. Cascata de selecao do proximo PC (Branch -> Jump -> JR)
    ----------------------------------------------------------------------------
    u_mux_branch : entity work.mux2
        generic map (N => 32)
        port map (
            A   => pc_plus4,  -- 0: sequencial
            B   => pc_branch, -- 1: desvio condicional (BEQ)
            Sel => pc_src,
            Y   => pc_branch_mux
        );

    u_mux_jump : entity work.mux2
        generic map (N => 32)
        port map (
            A   => pc_branch_mux, -- 0: PC+4 ou PCBranch
            B   => pc_jump,       -- 1: endereco de J / JAL
            Sel => jump,
            Y   => pc_jump_mux
        );

    -- Mux extra 3 (JR): carrega RD1 (registrador rs) diretamente no PC
    u_mux_jr : entity work.mux2
        generic map (N => 32)
        port map (
            A   => pc_jump_mux, -- 0: proximo PC normal/branch/jump
            B   => rd1,         -- 1: endereco contido em rs ($ra)
            Sel => jump_reg,
            Y   => pc_next
        );

    ----------------------------------------------------------------------------
    -- 9. Contador de ciclos independente (compartilha clk, rst e running)
    ----------------------------------------------------------------------------
    u_cycle_counter : entity work.cycle_counter
        port map (
            clk   => clk,
            rst   => rst,
            en    => running,
            count => cycles
        );

end architecture rtl;