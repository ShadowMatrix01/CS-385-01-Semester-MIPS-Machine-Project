# MIPS Assembly equivalent of the 16-bit ALU Verilog design

# ALU control op encodings (Verilog -> MIPS instruction):
#   4'b0000 -> AND   -> and  $t0,$t1,$t2
#   4'b0001 -> OR    -> or   $t0,$t1,$t2
#   4'b0010 -> ADD   -> add  $t0,$t1,$t2
#   4'b0110 -> SUB   -> sub  $t0,$t1,$t2
#   4'b0111 -> SLT   -> slt  $t0,$t1,$t2
#   4'b1100 -> NOR   -> nor  $t0,$t1,$t2



        .text
        .globl main


main:

# Test 1: op=0000 AND  7 & 1 = 1
# Verilog: op=4'b0000; a=7; b=1
# MIPS: and $t0,$t1,$t2

        li   $v0, 4
        la   $a0, lbl_and1
        syscall

        li   $t1, 7            # a = 7   (0b0000000000000111)
        li   $t2, 1            # b = 1   (0b0000000000000001)
        and  $t0, $t1, $t2     # result  = 7 & 1 = 1
        move $a0, $t0
        jal  print_result
        

# Test 2: op=0001 OR  5 | 2 = 7
# Verilog: op=4'b0001; a=5; b=2
# MIPS: or $t0,$t1,$t2

        li   $v0, 4
        la   $a0, lbl_or1
        syscall

        li   $t1, 5            # a = 5   (0b0000000000000101)
        li   $t2, 2            # b = 2   (0b0000000000000010)
        or   $t0, $t1, $t2     # result  = 5 | 2 = 7
        move $a0, $t0
        jal  print_result
        

# Test 3: op=0010 ADD  4 + 2 = 6
# Verilog: op=4'b0010; a=4; b=2
# MIPS: add $t0,$t1,$t2

        li   $v0, 4
        la   $a0, lbl_add1
        syscall

        li   $t1, 4            # a = 4   (0b0000000000000100)
        li   $t2, 2            # b = 2   (0b0000000000000010)
        add  $t0, $t1, $t2     # result  = 4 + 2 = 6
        move $a0, $t0
        jal  print_result
        

# Test 4: op=0010 ADD  7 + 1 = 8
# Verilog: op=4'b0010; a=7; b=1
# MIPS: add $t0,$t1,$t2

        li   $v0, 4
        la   $a0, lbl_add2
        syscall

        li   $t1, 7            # a = 7   (0b0000000000000111)
        li   $t2, 1            # b = 1   (0b0000000000000001)
        add  $t0, $t1, $t2     # result  = 7 + 1 = 8
        move $a0, $t0
        jal  print_result
        

# Test 5: op=0110 SUB  5 - 3 = 2  (zero=0)
# Verilog: op=4'b0110; a=5; b=3
# MIPS: sub $t0,$t1,$t2
# Note: binvert=1, carryin=1 -> two's complement subtraction
        li   $v0, 4
        la   $a0, lbl_sub1
        syscall

        li   $t1, 5            # a = 5   (0b0000000000000101)
        li   $t2, 3            # b = 3   (0b0000000000000011)
        sub  $t0, $t1, $t2     # result  = 5 - 3 = 2  ; zero=0
        move $a0, $t0
        jal  print_result
        

# Test 6: op=0110 SUB  -1 - 1 = -2
# Verilog: op=4'b0110; a=0xFFFF (-1); b=1
# MIPS:    sub $t0,$t1,$t2
# BEQ/BNE: zero flag would be 0 here (result ≠ 0, no branch)
        li   $v0, 4
        la   $a0, lbl_sub2
        syscall

        li   $t1, -1           # a = -1  (0b1111111111111111)
        li   $t2, 1            # b =  1  (0b0000000000000001)
        sub  $t0, $t1, $t2     # result  = -1 - 1 = -2
        move $a0, $t0
        jal  print_result
        

# Test 7: op=0111 SLT  5 < 1 -> 0 
# Verilog: op=4'b0111; a=5; b=1
# MIPS:    slt $t0,$t1,$t2
# Hardware: computes (a-b); if MSB of result (sign bit) = 1 -> less=1
        li   $v0, 4
        la   $a0, lbl_slt1
        syscall

        li   $t1, 5            # a = 5
        li   $t2, 1            # b = 1
        slt  $t0, $t1, $t2     # result  = (5 < 1) ? 1 : 0 = 0
        move $a0, $t0
        jal  print_result
        

# Test 8: op=0111 SLT  -2 < -1 -> 1
# Verilog: op=4'b0111; a=0xFFFE (-2); b=0xFFFF (-1)
# MIPS:    slt $t0,$t1,$t2
# Hardware: MSB of (-2 - -1) = MSB of -1 = 1 -> set=1 -> result[0]=1
        li   $v0, 4
        la   $a0, lbl_slt2
        syscall

        li   $t1, -2           # a = -2  (0b1111111111111110)
        li   $t2, -1           # b = -1  (0b1111111111111111)
        slt  $t0, $t1, $t2     # result  = (-2 < -1) ? 1 : 0 = 1
        move $a0, $t0
        jal  print_result
        

# Test 9: op=1100 NOR  ~(5 | 2) = 0xFFF8 (-8)
# Verilog: op=4'b1100; a=5; b=2
# MIPS:    nor $t0,$t1,$t2
# Hardware: ainvert=1, binvert=1, op[1:0]=00 -> AND(~a,~b) = NOR(a,b)
        li   $v0, 4
        la   $a0, lbl_nor1
        syscall

        li   $t1, 5            # a = 5   (0b0000000000000101)
        li   $t2, 2            # b = 2   (0b0000000000000010)
        nor  $t0, $t1, $t2     # result  = ~(5 | 2) = 0xFFF8 = -8
        move $a0, $t0
        jal  print_result
        

# Test 10: op=1101 NOR variant ~(5 | 2) using OR path
# Verilog: op=4'b1101; a=5; b=2
# MIPS equivalent: nor then keep only OR path -> same NOR result via De Morgan
# No exact MIPS instruction for this variant; we use nor again as it matches output
        li   $v0, 4
        la   $a0, lbl_nor2
        syscall

        li   $t1, 5            # a = 5
        li   $t2, 2            # b = 2
        # op=1101 -> ainvert=1, binvert=1, op[1:0]=01 -> OR(~a,~b) = XNOR-like
        # Computed manually: ~a=0xFFFA, ~b=0xFFFD, OR(~a,~b)=0xFFFF
        # MIPS approximation using available instructions:
        nor  $t3, $t1, $zero   # ~a  = NOT a  (nor with zero)
        nor  $t0, $t2, $zero   # ~b  = NOT b
        or   $t0, $t3, $t0     # OR(~a, ~b)
        move $a0, $t0
        jal  print_result
        j program_end
print_result:
        li   $v0, 1             # syscall 1 = print_int
        syscall
        li   $v0, 4             # syscall 4 = print_string
        la   $a0, newline
        syscall
        jr   $ra                # return to caller
program_end:
# End of program
        li   $v0, 10            # syscall 10 = exit
        syscall
        
        
        .data
lbl_and1:   .asciiz "AND  7 & 1      = "
lbl_or1:    .asciiz "OR   5 | 2      = "
lbl_add1:   .asciiz "ADD  4 + 2      = "
lbl_add2:   .asciiz "ADD  7 + 1      = "
lbl_sub1:   .asciiz "SUB  5 - 3      = "
lbl_sub2:   .asciiz "SUB -1 - 1      = "
lbl_slt1:   .asciiz "SLT  5 < 1      = "
lbl_slt2:   .asciiz "SLT -2 < -1     = "
lbl_nor1:   .asciiz "NOR  5 | 2 ~    = "
lbl_nor2:   .asciiz "NOR2 5 | 2 ~OR  = "
newline:    .asciiz "\n"
