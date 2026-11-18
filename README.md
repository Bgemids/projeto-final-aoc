# Projeto Final - AOC (UFMG)

Processador MIPS de 32 bits single-cycle em VHDL, com suporte a Branch (BEQ), JAL, LW e SW.

O trabalho foi dividido em duas partes:

1. **Caminho de dados**: os blocos por onde os dados passam (Clarice, Fernanda e Bruno).
2. **Unidade de controle**: a controladora que gera os sinais de controle (equipe com Thiago e Edson).

## Estrutura

```
Caminho de Dados/
  Multiplexador/            mux2.vhd, tb_mux2.vhd                       (Clarice)
  Sign Extend/              sign_extend.vhd, tb_sign_extend.vhd         (Clarice)
  Memoria de Dados/         data_memory.vhd, tb_data_memory.vhd         (Clarice)
  ALU/                      alu.vhd, tb_alu.vhd                         (Fernanda)
  Banco de Registradores/   register_file.vhd, tb_register_file.vhd     (Fernanda)
  Shift Left 2/             shift_left2.vhd, tb_shift_left2.vhd         (Fernanda)
Maquina de Estados/         unidade de controle
  control_unit.vhd          modulo de topo da controladora
  main_decoder.vhd          decodificador principal (opcode -> sinais de controle)
  alu_decoder.vhd           decodificador da ALU (ALUOp + funct -> ALUControl)
  tb_control_unit.vhd       testbench auto-verificavel
Documentacao/               relatorios em PDF de cada parte
```

Ainda faltam no repositório: Memoria de Instrucoes e PC.

## Blocos do caminho de dados

| Bloco | Entidade | Portas | Tipo |
|---|---|---|---|
| Multiplexador 2:1 | `mux2` (generic `N`, padrao 32) | `A`, `B`, `Sel`, `Y` | combinacional |
| Sign Extend | `sign_extend` | `imm16` (16 bits), `imm32` (32 bits) | combinacional |
| Memoria de Dados | `data_memory` | `Clk`, `MemWrite`, `Address`, `WriteData`, `ReadData` | escrita sincrona, leitura combinacional; 256 palavras de 32 bits, enderecamento por byte, alinhado em 4 |
| ALU | `ALU` | `SrcA`, `SrcB`, `ALUControl` (3 bits), `ALUResult`, `Zero` | combinacional; and `000`, or `001`, add `010`, sub `110`, slt `111` |
| Banco de Registradores | `RegisterFile` | `clk`, `rst`, `we3`, `a1`, `a2`, `a3`, `wd3`, `rd1`, `rd2` | escrita e reset sincronos, leitura combinacional; `$0` sempre zero |
| Shift Left 2 | `ShiftLeft2` | `a`, `y` | combinacional; `y = a * 4` |

## Instrucoes suportadas pela controladora

R-type (add, sub, and, or, slt), LW, SW, BEQ, ADDI, J e JAL.

## Simulacao

### EDA Playground

- Clarice (Mux, Sign Extend, Memoria de Dados): https://edaplayground.com/x/GpRt (GHDL)
- Fernanda (ALU, Banco de Registradores, Shift Left 2): https://edaplayground.com/x/bprG (Aldec Riviera Pro)

Em cada playground, escolha o testbench no campo "Top entity" antes de rodar.

### GHDL local

Cada pasta tem o bloco e o seu testbench. Exemplo para a ALU:

```sh
cd "Caminho de Dados/ALU"
ghdl -a --std=08 alu.vhd tb_alu.vhd
ghdl --elab-run --std=08 tb_alu --vcd=tb_alu.vcd
```

Os testbenches do Mux, Sign Extend, Memoria de Dados e da controladora verificam os resultados com `assert`. Os da ALU, do Banco de Registradores e do Shift Left 2 geram formas de onda para conferencia visual (EPWave ou GTKWave).
