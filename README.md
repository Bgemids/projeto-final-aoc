# Projeto Final - AOC (UFMG)

Processador MIPS de 32 bits single-cycle em VHDL, com suporte a Branch (BEQ), JAL, LW e SW.

## Estrutura

- `Maquina de Estados/` - unidade de controle (controladora)
  - `control_unit.vhd` - modulo de topo da controladora
  - `main_decoder.vhd` - decodificador principal (opcode -> sinais de controle)
  - `alu_decoder.vhd` - decodificador da ALU (ALUOp + funct -> ALUControl)
  - `tb_control_unit.vhd` - testbench auto-verificavel

## Instrucoes suportadas pela controladora

R-type (add, sub, and, or, slt), LW, SW, BEQ, ADDI, J e JAL.

## Simulacao (GHDL)

```sh
cd "Maquina de Estados"
ghdl -a main_decoder.vhd alu_decoder.vhd control_unit.vhd tb_control_unit.vhd
ghdl -e tb_control_unit
ghdl -r tb_control_unit
```
