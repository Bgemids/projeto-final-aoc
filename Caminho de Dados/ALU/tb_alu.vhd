library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_ALU is
-- Entidade de testbench é sempre vazia
end tb_ALU;

architecture behavior of tb_ALU is
    -- 1. Declarar o componente que vamos testar
    component ALU
    Port (
        SrcA       : in  std_logic_vector(31 downto 0);
        SrcB       : in  std_logic_vector(31 downto 0);
        ALUControl : in  std_logic_vector(2 downto 0);
        ALUResult  : out std_logic_vector(31 downto 0);
        Zero       : out std_logic
    );
    end component;

    -- 2. Sinais internos para conectar às portas da ALU
    signal SrcA       : std_logic_vector(31 downto 0) := (others => '0');
    signal SrcB       : std_logic_vector(31 downto 0) := (others => '0');
    signal ALUControl : std_logic_vector(2 downto 0) := (others => '0');
    signal ALUResult  : std_logic_vector(31 downto 0);
    signal Zero       : std_logic;

begin
    -- 3. Instanciar a ALU (Ligar os sinais do testbench na ALU)
    uut: ALU port map (
        SrcA => SrcA,
        SrcB => SrcB,
        ALUControl => ALUControl,
        ALUResult => ALUResult,
        Zero => Zero
    );

    -- 4. Processo que gera os estímulos (Nossos testes)
    stim_proc: process
    begin
        -- Teste 1: Soma (ALUControl 010)
        SrcA <= x"0000000A"; -- Valor 10
        SrcB <= x"00000005"; -- Valor 5
        ALUControl <= "010"; 
        wait for 10 ns;
        
        -- Teste 2: Subtração (ALUControl 110)
        SrcA <= x"0000000A"; -- 10
        SrcB <= x"00000005"; -- 5
        ALUControl <= "110"; 
        wait for 10 ns;
        
        -- Teste 3: Subtração resultando em Zero (testando a flag Zero)
        SrcA <= x"0000000A"; -- 10
        SrcB <= x"0000000A"; -- 10
        ALUControl <= "110"; 
        wait for 10 ns;
        
        -- Teste 4: AND lógico (ALUControl 000)
        SrcA <= x"0000000F"; 
        SrcB <= x"00000003"; 
        ALUControl <= "000"; 
        wait for 10 ns;
        
        -- Teste 5: OR lógico (ALUControl 001)
        SrcA <= x"000000F0"; 
        SrcB <= x"0000000F"; 
        ALUControl <= "001"; 
        wait for 10 ns;
        
        -- Teste 6: SLT - Set on Less Than (ALUControl 111)
        SrcA <= x"00000005"; -- 5
        SrcB <= x"0000000A"; -- 10
        ALUControl <= "111"; -- Como 5 < 10, ALUResult deve ser 1
        wait for 10 ns;
        
        -- Teste 7: SLT (Falso)
        SrcA <= x"0000000A"; -- 10
        SrcB <= x"00000005"; -- 5
        ALUControl <= "111"; -- Como 10 não é menor que 5, ALUResult deve ser 0
        wait for 10 ns;

        -- Teste 8: A and (not B) (ALUControl 100) - acrescentado na integracao
        SrcA <= x"000000FF";
        SrcB <= x"0000000F";
        ALUControl <= "100"; -- ALUResult deve ser 000000F0
        wait for 10 ns;
        assert ALUResult = x"000000F0" report "ERRO: A and (not B)" severity error;

        -- Teste 9: A or (not B) (ALUControl 101) - acrescentado na integracao
        SrcA <= x"00000000";
        SrcB <= x"FFFFFF00";
        ALUControl <= "101"; -- ALUResult deve ser 000000FF
        wait for 10 ns;
        assert ALUResult = x"000000FF" report "ERRO: A or (not B)" severity error;

        wait; -- Interrompe a simulação
    end process;

end behavior;
