# Programa usado no teste de integracao (Integracao (teste)/mips_teste.vhd).
# Pode ser montado no MARS para conferir os codigos de maquina da ROM.
# Configuracao do MARS: Settings > Memory Configuration > Compact, Text at Address 0.

        addi $t0, $zero, 5      # 0x00  contador = 5
        addi $t1, $zero, 0      # 0x04  soma = 0
loop:   add  $t1, $t1, $t0      # 0x08  soma += contador
        addi $t0, $t0, -1       # 0x0C  contador--
        beq  $t0, $zero, done   # 0x10  sai do laco quando contador = 0
        j    loop               # 0x14
done:   sw   $t1, 0($zero)      # 0x18  mem[0] = 15
        lw   $t2, 0($zero)      # 0x1C  $t2 = 15
        jal  func               # 0x20  $ra = 0x24
        sw   $t3, 12($zero)     # 0x24  executa depois do jr: mem[12] = 7
        slt  $t3, $t1, $t2      # 0x28  15 < 15 -> 0
fim:    j    fim                # 0x2C  para aqui
func:   addi $t3, $zero, 7      # 0x30
        sw   $t3, 4($zero)      # 0x34  mem[4] = 7
        sw   $ra, 8($zero)      # 0x38  mem[8] = 0x24
        jr   $ra                # 0x3C  volta para 0x24
