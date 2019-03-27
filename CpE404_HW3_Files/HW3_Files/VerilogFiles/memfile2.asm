# memfile2.asm
# Dr. Harris - 7 Feb 2019
# 
# Test the MIPS processor. 
# Instructions: add, sub, and, or, slt, addi, lw, sw, beq, j 
# Added instructions: andi, lb, jr
#
# Fill in the Description column below
#
#       Assembly           Description                         Address    Machine 
.text
.globl main 

main:   addi $2, $0, 0x732c #$2 = 29484                         0          2002732c 
        addi $3, $0, -32768 #$3 = -32768                        4          20038000 
        add  $4, $3, $3     #$4 =-32768 + -32768 = -65536       8          00632020
        add  $4, $4, $3     #$4 =-65536 + - 32768= -98304       c          00832020
        sub  $4, $4, $2		#$4 = -98304 - 29484 = -127788      10         00822022
        andi $3, $4, 0x897F #$3 = FFFE0cd4 AND 0000897f = 0x854 14         3083897f 
        sw   $4, 32($0)     #mem[32] = 0xFFFE0CD4               18         ac040020  
        lb   $6, 34($0)     #$6= 0xFE                           1c         80060022     
        andi $3, $3, 0xEF   #$3 = 0x44                          20         306300ef
        jr   $3             #j to address in $3 0x44 is PC      24         00600008
        add  $0, $0, $0     #nop                                28         00000020
        andi $6, $6, 0x123  #not executed                       2c         30c60123
        add  $6, $6, $6     #not executed                       30         00c63020
        addi $6, $6, -578   #not executed                       34         20c6fdbe
        addi $6, $6, 77     #not executed                       38         20c6004d
        sub  $6, $2, $6     #not executed                       3c         00463022
        sub  $6, $2, $6     #not executed              	        40         00463022
        sw   $6, 12($3)     #mem[0x44] = 0xFE or 433            44         ac66000c
        jr   $3             #j to address in $3  0X44           48         00600008
