--------------------------------------------------------------------------------
-- tb_mips_teste.vhd
-- Testbench do processador de teste: roda programa_teste.asm por 60 ciclos e
-- confere as escritas na memoria (SW) e o PC final.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity tb_mips_teste is end entity;
architecture sim of tb_mips_teste is
    signal clk : std_logic := '0';
    signal rst : std_logic := '1';
    signal PC, Instr, ALUResult, WriteData : std_logic_vector(31 downto 0);
    signal MemWrite : std_logic;
    type wr_t is array (0 to 3) of std_logic_vector(31 downto 0);
    signal mem_seen : wr_t := (others => (others => 'U'));
    signal ciclos : natural := 0;
begin
    uut: entity work.mips_teste port map (clk, rst, PC, Instr, ALUResult, WriteData, MemWrite);
    clk <= not clk after 5 ns when ciclos < 60 else '0';
    process(clk) begin
        if rising_edge(clk) then
            ciclos <= ciclos + 1;
            if rst = '0' and MemWrite = '1' then
                report "SW: mem[" & integer'image(to_integer(unsigned(ALUResult))) & "] <= " &
                       integer'image(to_integer(unsigned(WriteData)));
                mem_seen(to_integer(unsigned(ALUResult(3 downto 2)))) <= WriteData;
            end if;
        end if;
    end process;
    process begin
        wait for 12 ns; rst <= '0';
        wait until ciclos = 59;
        assert mem_seen(0) = x"0000000F" report "FALHA: soma do laco (esperado 15)" severity error;
        assert mem_seen(1) = x"00000007" report "FALHA: addi dentro da funcao (esperado 7)" severity error;
        assert mem_seen(2) = x"00000024" report "FALHA: $ra do JAL (esperado 0x24)" severity error;
        assert mem_seen(3) = x"00000007" report "FALHA: retorno do JR (esperado mem[12] = 7)" severity error;
        assert PC = x"0000002C" report "FALHA: PC final (esperado 0x2C)" severity error;
        report "FIM: PC final = " & integer'image(to_integer(unsigned(PC)));
        wait;
    end process;
end architecture;
