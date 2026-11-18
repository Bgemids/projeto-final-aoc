# Projeto Final - AOC (UFMG)

Processador MIPS de 32 bits single-cycle em VHDL, com suporte a Branch (BEQ), JAL, LW e SW
(e JR, para voltar das funcoes chamadas com JAL).

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
Integracao (teste)/         processador de teste com PC e memoria de instrucoes PROVISORIOS
  mips_teste.vhd            liga todos os blocos acima, como na figura do enunciado
  tb_mips_teste.vhd         roda o programa e confere as escritas na memoria e o PC final
  programa_teste.asm        programa de teste (laco, beq, j, sw, lw, jal, jr, slt)
Documentacao/               relatorios em PDF de cada parte e a documentacao do grupo
                            (PDF e .docx editavel)
```

Ainda faltam no repositório: Memoria de Instrucoes e PC definitivos (parte do Bruno).

## Blocos do caminho de dados

| Bloco | Entidade | Portas | Tipo |
|---|---|---|---|
| Multiplexador 2:1 | `mux2` (generic `N`, padrao 32) | `A`, `B`, `Sel`, `Y` | combinacional |
| Sign Extend | `sign_extend` | `imm16` (16 bits), `imm32` (32 bits) | combinacional |
| Memoria de Dados | `data_memory` | `Clk`, `MemWrite`, `Address`, `WriteData`, `ReadData` | escrita sincrona, leitura combinacional; 256 palavras de 32 bits, enderecamento por byte, alinhado em 4 |
| ALU | `ALU` | `SrcA`, `SrcB`, `ALUControl` (3 bits), `ALUResult`, `Zero` | combinacional; tabela abaixo |
| Banco de Registradores | `RegisterFile` | `clk`, `rst`, `we3`, `a1`, `a2`, `a3`, `wd3`, `rd1`, `rd2` | escrita e reset sincronos, leitura combinacional; `$0` sempre zero |
| Shift Left 2 | `ShiftLeft2` | `a`, `y` | combinacional; `y = a * 4` |

Operacoes da ALU (tabela do enunciado):

| ALUControl | Operacao |
|---|---|
| 000 | A and B |
| 001 | A or B |
| 010 | A + B |
| 011 | nao e usado (resultado 0) |
| 100 | A and (not B) |
| 101 | A or (not B) |
| 110 | A - B |
| 111 | slt |

## Unidade de controle

Sinais gerados para cada instrucao:

| Instrucao | Op | RegWrite | RegDst | ALUSrc | Branch | MemWrite | MemtoReg | Jump | Jal | JumpReg | ALUOp |
|---|---|---|---|---|---|---|---|---|---|---|---|
| R-type | 000000 | 1 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | 10 |
| LW | 100011 | 1 | 0 | 1 | 0 | 0 | 1 | 0 | 0 | 0 | 00 |
| SW | 101011 | 0 | 0 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 00 |
| BEQ | 000100 | 0 | 0 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 01 |
| ADDI | 001000 | 1 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 00 |
| J | 000010 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 0 | 0 | 00 |
| JAL | 000011 | 1 | 0 | 0 | 0 | 0 | 0 | 1 | 1 | 0 | 00 |
| JR (funct 001000) | 000000 | 0 | 1 | 0 | 0 | 0 | 0 | 0 | 0 | 1 | 10 |

O JR e uma instrucao R-type, entao o decodificador principal (que so ve o opcode) nao o distingue.
A deteccao fica no `control_unit.vhd`, que ve opcode e `funct`: gera `JumpReg` e anula o `RegWrite`.

O decodificador da ALU segue a tabela do enunciado: `ALUOp = 00` soma, `X1` subtrai,
`1X` olha o `funct` (add, sub, and, or, slt e `101011` -> `011`).

## Ligacao entre as partes

O caminho de dados segue a figura do enunciado. `RegDst`, `ALUSrc` e `MemtoReg` tem 1 bit e
controlam instancias do `mux2`. O banco de registradores recebe `RegWrite` na porta `we3`.

A figura do enunciado nao tem J, JAL nem JR. Para suporta-los, a controladora gera tres sinais
extras, e o caminho de dados usa quatro `mux2` a mais:

| Sinal | mux2 | Entrada 0 | Entrada 1 |
|---|---|---|---|
| `Jump` | proximo PC | saida do mux do `PCSrc` | `PCJump = PCPlus4(31..28) & Instr(25..0) & "00"` |
| `Jal` | registrador de destino (`N => 5`) | saida do mux do `RegDst` | `"11111"` ($ra) |
| `Jal` | dado escrito no registrador | saida do mux do `MemtoReg` | `PCPlus4` |
| `JumpReg` | proximo PC (`PCNext`) | saida do mux do `Jump` | `RD1` (registrador rs) |

O arquivo `Integracao (teste)/mips_teste.vhd` mostra essa ligacao completa.

## Simulacao

### EDA Playground

- Clarice (Mux, Sign Extend, Memoria de Dados): https://edaplayground.com/x/GpRt (GHDL)
- Fernanda (ALU, Banco de Registradores, Shift Left 2): https://edaplayground.com/x/bprG (Aldec Riviera Pro)

Em cada playground, escolha o testbench no campo "Top entity" antes de rodar.
A ALU destes playgrounds ainda nao tem as operacoes 100 e 101; a versao atual esta neste repositorio.

### GHDL local

Cada pasta tem o bloco e o seu testbench. Exemplo para a ALU:

```sh
cd "Caminho de Dados/ALU"
ghdl -a --std=08 alu.vhd tb_alu.vhd
ghdl --elab-run --std=08 tb_alu --vcd=tb_alu.vcd
```

Teste de integracao (a partir da raiz do repositorio):

```sh
ghdl -a --std=08 "Caminho de Dados"/*/[!t]*.vhd \
  "Maquina de Estados/main_decoder.vhd" "Maquina de Estados/alu_decoder.vhd" \
  "Maquina de Estados/control_unit.vhd" \
  "Integracao (teste)/mips_teste.vhd" "Integracao (teste)/tb_mips_teste.vhd"
ghdl --elab-run --std=08 tb_mips_teste
```

Os testbenches do Mux, Sign Extend, Memoria de Dados, da controladora e da integracao verificam os
resultados com `assert`. Os da ALU, do Banco de Registradores e do Shift Left 2 geram formas de onda
para conferencia visual (EPWave ou GTKWave); o da ALU tambem confere as operacoes 100 e 101.
