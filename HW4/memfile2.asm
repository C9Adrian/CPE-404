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

main:   addi $2, $0, 0x732c #                                  0          2002732c 
        addi $3, $0, -32768 #                                  4          20038000 
        add  $4, $3, $3     #                                  8          00632020
        add  $4, $4, $3     #                                  c          00832020
        sub  $4, $4, $2		#                                  10         00822022
        andi $3, $4, 0x897F #                                  14         3083897f 
        sw   $4, 32($0)     #                                  18         ac040020  
        lb   $6, 34($0)     #                                  1c         80060022     
        andi $3, $3, 0xEF   #                                  20         306300ef
        jr   $3             #                                  24         00600008
        add  $0, $0, $0     #                                  28         00000020
        andi $6, $6, 0x123  #                                  2c         30c60123
        add  $6, $6, $6     #                                  30         00c63020
        addi $6, $6, -578   #                                  34         20c6fdbe
        addi $6, $6, 77     #                                  38         20c6004d
        sub  $6, $2, $6     #                                  3c         00463022
        sub  $6, $2, $6     #                                  40         00463022
        sw   $6, 12($3)     #                                  44         ac66000c
        jr   $3             #                                  48         00600008
