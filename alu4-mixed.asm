#Corresponds to the Verilog code for the test module, albeit in 32 bits since MIPS is 32 bits, not 16 bits.
.data
newline: .asciiz "\n"

.text
.globl main

main:                      # Machine Code
#15 and 7 are loaded into $t1 and $t2 respectively.
addi $t1, $zero, 15        # I-type, 00100000000010010000000000001111
addi $t2, $zero, 7         # I-type, 00100000000010100000000000000111
and  $t3, $t1, $t2         # R-type, 00000001001010100101100000100100

#Print result to console.
addi $v0, $zero, 1         # I-type, 00100000000000100000000000000001
add  $a0, $t3, $zero       # R-type, 00000001011000000010000000100000
syscall

#Prints a new line
addi $v0, $zero, 4         # I-type, 00100000000000100000000000000100
lui  $a0, 0x1001           # I-type, 00111100000001000001000000000001     
ori  $a0, $a0, 0x0000      # I-type, 00110100100001000000000000000000
syscall

#Subtracts the value from $t1 by $t3 and stored in $t2
sub  $t2, $t1, $t3         # R-type, 00000001001010110101000000100010
addi $v0, $zero, 1         # R-type, 00100000000000100000000000000001
add  $a0, $t2, $zero       # R-type, 00000001010000000010000000100000
syscall

#Prints a new line
addi $v0, $zero, 4         # I-type, 00100000000000100000000000000100
lui  $a0, 0x1001           # I-type, 00111100000001000001000000000001     
ori  $a0, $a0, 0x0000      # I-type, 00110100100001000000000000000000
syscall

#Or’s the values in $t2 with $t3, stored in $t2.
or   $t2, $t2, $t3         # R-type, 00000001010010110101000000100101
addi $v0, $zero, 1         # I-type, 00100000000000100000000000000001
add  $a0, $t2, $zero       # R-type, 00000001010000000010000000100000
syscall

#Prints a new line
addi $v0, $zero, 4         # I-type, 00100000000000100000000000000100
lui  $a0, 0x1001           # I-type, 00111100000001000001000000000001     
ori  $a0, $a0, 0x0000      # I-type, 00110100100001000000000000000000
syscall

#Adds the value in $t2 with the value in $t3
add  $t3, $t2, $t3         # R-type, 0000001010010110101100000100000
addi $v0, $zero, 1         # I-type, 00100000000000100000000000000001
add  $a0, $t3, $zero       # R-type, 00000001011000000010000000100000
syscall

#Prints a new line
addi $v0, $zero, 4         # I-type, 00100000000000100000000000000100
lui  $a0, 0x1001           # I-type, 00111100000001000001000000000001     
ori  $a0, $a0, 0x0000      # I-type, 00110100100001000000000000000000
syscall

#Nors the value in $t2 with the value in $t3.
nor  $t1, $t2, $t3         # R-type, 00000001010010110100100000100111
addi $v0, $zero, 1         # I-type, 00100000000000100000000000000001
add  $a0, $t1, $zero       # R-type, 00000001001000000010000000100000
syscall

#Prints a new line
addi $v0, $zero, 4         # I-type, 00100000000000100000000000000100
lui  $a0, 0x1001           # I-type, 00111100000001000001000000000001     
ori  $a0, $a0, 0x0000      # I-type, 00110100100001000000000000000000
syscall

#If $t3 is less than $t2, $t1 will be set to 1. 
slt  $t1, $t3, $t2         # R-type, 00000001011010100100100000101010
addi $v0, $zero, 1         # I-type, 00100000000000100000000000000001
add  $a0, $t1, $zero       # R-type, 00000001001000000010000000100000
syscall

#Prints a new line
addi $v0, $zero, 4         # I-type, 00100000000000100000000000000100
lui  $a0, 0x1001           # I-type, 00111100000001000001000000000001     
ori  $a0, $a0, 0x0000      # I-type, 00110100100001000000000000000000
syscall

#If $t2 is less than $t3, $t1 will be set to 1. 
slt  $t1, $t2, $t3         # R-type, 00000001010010110100100000101010

#Print result to console.
addi $v0, $zero, 1         # I-type, 00100000000000100000000000000001
add  $a0, $t1, $zero       # R-type, 00000001001000000010000000100000
syscall

#Prints a new line
addi $v0, $zero, 4         # I-type, 00100000000000100000000000000100
lui  $a0, 0x1001           # I-type, 00111100000001000001000000000001     
ori  $a0, $a0, 0x0000      # I-type, 00110100100001000000000000000000
syscall

# NAND Implementation, since NAND is not a native MIPS instruction.
and  $t1, $t2, $t3         # R-type, 00000001010010110100100000100100
nor  $t1, $t1, $zero       # R-type, 00000001001000000100100000100111

#Prints final NAND result into address line.
addi $v0, $zero, 1         # I-type, 00100000000000100000000000000001
add  $a0, $t1, $zero       # R-type, 00000001001000000010000000100000
syscall

# Exit Program
addi $v0, $zero, 10        # I-type, 00100000000000100000000000001010
syscall
