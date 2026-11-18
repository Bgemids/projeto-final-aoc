library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        SrcA       : in  std_logic_vector(31 downto 0);
        SrcB       : in  std_logic_vector(31 downto 0);
        ALUControl : in  std_logic_vector(2 downto 0);
        ALUResult  : out std_logic_vector(31 downto 0);
        Zero       : out std_logic
    );
end ALU;

architecture Behavioral of ALU is
    signal s_result : std_logic_vector(31 downto 0);
begin
    process(SrcA, SrcB, ALUControl)
    begin
        case ALUControl is
            when "000" => s_result <= SrcA and SrcB;
            when "001" => s_result <= SrcA or SrcB;
            when "010" => s_result <= std_logic_vector(signed(SrcA) + signed(SrcB));
            when "110" => s_result <= std_logic_vector(signed(SrcA) - signed(SrcB));
            when "111" => 
                if signed(SrcA) < signed(SrcB) then
                    s_result <= x"00000001";
                else
                    s_result <= x"00000000";
                end if;
            when others => s_result <= (others => '0');
        end case;
    end process;
    
    ALUResult <= s_result;
    Zero <= '1' when s_result = x"00000000" else '0';
end Behavioral;
