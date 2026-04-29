// Names: Aiden Ocasio, Jacob Rulka, and Jhan Gomez
// Instructor: Professor Markov
// Course: CS-385-01
// Date: 05/05/26
// Purpose: To demonstrate how the final, 5 stage pipelined CPU in MIPS would perform.
module reg_file (RR1,RR2,WR,WD,RegWrite,RD1,RD2,clock);
  input [1:0] RR1,RR2,WR; //Instead of 5 bits for rs, rt, and rd, it is only two bits. 
  input [15:0] WD; //16 bits for complete instruction rather than the traditional 32 bits.
  input RegWrite,clock;
  output [15:0] RD1,RD2; //The read data ports of the reg file are likewise only 16 bits.
  reg [15:0] Regs[0:3]; //4 registers, 16 bits long.
  assign RD1 = Regs[RR1]; //RS is assigned to read data port 1.
  assign RD2 = Regs[RR2]; //RT is assigned to read data port 2.
  initial Regs[0] = 0; //$zero must always be 0.
  always @(negedge clock)
    if (RegWrite==1 & WR!=0) //Prevents $zero from being overwritten and make sure only when asserted that Write Register is allowed.
    Regs[WR] <= WD;
endmodule

// MUXES 
//4x1 Multiplexer, used by the ALU to choose whether it is an and, or, add, less operation.
module mux(a, b, a1, b1, select, out);
   input a, b, a1, b1;
   input [1:0] select;
   output out;

   wire notS0, notS1;
   not (notS0,select[0]);
   not (notS1,select[1]);

   wire r0,r1,r2,r3;

   and (r0,a,notS1,notS0);
   and (r1,b,notS1,select[0]);
   and (r2,a1,select[1],notS0);
   and (r3,b1,select[1],select[0]);

   or (out,r0,r1,r2,r3);
endmodule

//This mux is generic, and is used as a building block for the ALU
module mux2x1(a, b, select, out);
    input a, b, select;
    output out;
    wire notselect;
    not (notselect, select);
    and (a_out, a, notselect);
    and (b_out, b, select);
    or (out, a_out, b_out);
    endmodule
    //This mux is used to select the destination register.
    module muxWR(a, b, select, out);
    input [1:0] a, b;
    input select;
    output [1:0] out;
    mux2x1 one(a[0], b[0], select, out[0]);
    mux2x1 two(a[1], b[1], select, out[1]);
endmodule

//This mux is used for writing back, for the program counter, and to select between the value RD2 in the register file or the immediate field.
module muxB (a, b, select, out);
    input [15:0] a, b;
    input select;
    output [15:0] out;
    
    //16 muxes for the respective 16 bits of RD2 and SignExtend
    mux2x1 mux1  (a[0], b[0], select, out[0]);
    mux2x1 mux2  (a[1], b[1], select, out[1]);
    mux2x1 mux3  (a[2], b[2], select, out[2]);
    mux2x1 mux4  (a[3], b[3], select, out[3]);
    mux2x1 mux5  (a[4], b[4], select, out[4]);
    mux2x1 mux6  (a[5], b[5], select, out[5]);
    mux2x1 mux7  (a[6], b[6], select, out[6]);
    mux2x1 mux8  (a[7], b[7], select, out[7]);
    mux2x1 mux9  (a[8], b[8], select, out[8]);
    mux2x1 mux10 (a[9], b[9], select, out[9]);
    mux2x1 mux11 (a[10], b[10], select, out[10]);
    mux2x1 mux12 (a[11], b[11], select, out[11]);
    mux2x1 mux13 (a[12], b[12], select, out[12]);
    mux2x1 mux14 (a[13], b[13], select, out[13]);
    mux2x1 mux15 (a[14], b[14], select, out[14]);
    mux2x1 mux16 (a[15], b[15], select, out[15]);
endmodule

//Fulladder is used to handle ALU arithmetic operations.
module fulladder(x, y, sum, carryin, carryout);
   input x, y, carryin;
   output sum, carryout;
   wire xysum, ab, axb_cin;

   xor (xysum,x,y);
   xor (sum,xysum,carryin);

   and (ab,x,y);
   and (axb_cin,xysum,carryin);
   or  (carryout,ab,axb_cin);
endmodule
//1 bit ALU works on bits 0-14 and does operations accordingly.
module ALU1 (a,b,ainvert,binvert,op,less,carryin,carryout,result);
   input a,b,less,carryin,ainvert,binvert;
   input [1:0] op;
   output carryout,result;
   wire nota,notb,a1,b1,and_out,or_out,sum;

   not (nota,a);
   not (notb,b);

   wire na_inv,nb_inv;
   not (na_inv,ainvert);
   not (nb_inv,binvert);

   wire a_sel0,a_sel1,b_sel0,b_sel1;

   and (a_sel0,a,na_inv);
   and (a_sel1,nota,ainvert);
   or  (a1,a_sel0,a_sel1);

   and (b_sel0,b,nb_inv);
   and (b_sel1,notb,binvert);
   or  (b1,b_sel0,b_sel1);

   and (and_out,a1,b1);
   or  (or_out,a1,b1);

   fulladder fa1(a1, b1, sum, carryin, carryout);
   mux m1(and_out, or_out, sum, less, op, result);
endmodule
//Does the same as above, but also has a set buffer to the slt flag.
module ALUmsb (a,b,ainvert,binvert,op,less,carryin,carryout,result,set);
   input a,b,less,carryin,ainvert,binvert;
   input [1:0] op;
   output carryout,result,set;
   wire nota,notb,a1,b1,and_out,or_out,sum;

   not (nota,a);
   not (notb,b);

   wire na_inv,nb_inv;
   not (na_inv,ainvert);
   not (nb_inv,binvert);

   wire a_sel0,a_sel1,b_sel0,b_sel1;

   and (a_sel0,a,na_inv);
   and (a_sel1,nota,ainvert);
   or  (a1,a_sel0,a_sel1);

   and (b_sel0,b,nb_inv);
   and (b_sel1,notb,binvert);
   or  (b1,b_sel0,b_sel1);

   and (and_out,a1,b1);
   or  (or_out,a1,b1);

   fulladder fa1(a1, b1, sum, carryin, carryout);
   mux m1(and_out, or_out, sum, less, op, result);
   buf (set,sum);
endmodule
module ALU (op,a,b,result,zero);
   input  [15:0] a,b;
   input  [3:0] op;
   output [15:0] result;
   output zero;
   wire c1,c2,c3,c4,c5,c6,c7,c8;
   wire c9,c10,c11,c12,c13,c14,c15,c16;
   wire set;
   // Bit 0
   ALU1 alu0 (a[0],b[0],op[3],op[2],op[1:0],set,op[2],c1,result[0]);

   // Bits 1-14
   ALU1 alu1  (a[1],b[1],op[3],op[2],op[1:0],1'b0,c1,c2,result[1]);
   ALU1 alu2  (a[2],b[2],op[3],op[2],op[1:0],1'b0,c2,c3,result[2]);
   ALU1 alu3  (a[3],b[3],op[3],op[2],op[1:0],1'b0,c3,c4,result[3]);
   ALU1 alu4  (a[4],b[4],op[3],op[2],op[1:0],1'b0,c4,c5,result[4]);
   ALU1 alu5  (a[5],b[5],op[3],op[2],op[1:0],1'b0,c5,c6,result[5]);
   ALU1 alu6  (a[6],b[6],op[3],op[2],op[1:0],1'b0,c6,c7,result[6]);
   ALU1 alu7  (a[7],b[7],op[3],op[2],op[1:0],1'b0,c7,c8,result[7]);
   ALU1 alu8  (a[8],b[8],op[3],op[2],op[1:0],1'b0,c8,c9,result[8]);
   ALU1 alu9  (a[9],b[9],op[3],op[2],op[1:0],1'b0,c9,c10,result[9]);
   ALU1 alu10 (a[10],b[10],op[3],op[2],op[1:0],1'b0,c10,c11,result[10]);
   ALU1 alu11 (a[11],b[11],op[3],op[2],op[1:0],1'b0,c11,c12,result[11]);
   ALU1 alu12 (a[12],b[12],op[3],op[2],op[1:0],1'b0,c12,c13,result[12]);
   ALU1 alu13 (a[13],b[13],op[3],op[2],op[1:0],1'b0,c13,c14,result[13]);
   ALU1 alu14 (a[14],b[14],op[3],op[2],op[1:0],1'b0,c14,c15,result[14]);

   //MSB ALU for bit 15 includes special set output for ALU0
   ALUmsb alu15 (a[15],b[15],op[3],op[2],op[1:0],1'b0,c15,c16,result[15],set);

   // Zero flag, later needed for beq and bne.
   nor (zero,
        result[0],result[1],result[2],result[3],
        result[4],result[5],result[6],result[7],
        result[8],result[9],result[10],result[11],
        result[12],result[13],result[14],result[15]);
endmodule


//Main control determines if R-type instruction or I-type instruction and sends the corresponding bit to   {IDEX_RegDst,IDEX_ALUSrc,IDEX_MemtoReg,IDEX_RegWrite,IDEX_MemWrite,IDEX_BEQ, IDEX_BNE, IDEX_JUMP, IDEX_ALUctl} 
module MainControl (Op,Control); 
  input [3:0] Op;
  output reg [11:0] Control; //Control is now 12 bits.
  always @(Op) case (Op)
   // R type Instructions:
    4'b0000: Control <= 12'b10010_00_0_0010; // ADD
    4'b0001: Control <= 12'b10010_00_0_0110; // SUB
    4'b0010: Control <= 12'b10010_00_0_0000; // AND
    4'b0011: Control <= 12'b10010_00_0_0001; // OR
    4'b0101: Control <= 12'b10010_00_0_1101; // NAND
    4'b0100: Control <= 12'b10010_00_0_1100; // NOR
    4'b0110: Control <= 12'b10010_00_0_0111; // SLT
  // I type Instructions:
   4'b0111: Control <= 12'b01010_00_0_0010; // ADDI
   4'b1000: Control <= 12'b01110_00_0_0010; // LW
   4'b1001: Control <= 12'b01001_00_0_0010; // SW
   4'b1010: Control <= 12'b00000_10_0_0110; // BEQ
   4'b1011: Control <= 12'b00000_01_0_0110; // BNE
   //J-type Instruction
   4'b1111: Control <= 12'b00000_00_1_0110; // Jump
    default: Control <= 12'b000000000000;
 endcase
endmodule


module CPU (clock,PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD);
  input clock;
  output [15:0] PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD;

  initial begin 
// Program: swap memory cells (if needed) and compute absolute value |5-7|=2
      IMemory[0]  = 16'b1000_00_01_00000000; // lw $t1, 0($0)
      IMemory[1]  = 16'b1000_00_10_00000010; // lw $t2, 2($0)
      IMemory[2]  = 16'b0000000000000000;    // nop
      IMemory[3]  = 16'b0000000000000000;    // nop
      IMemory[4]  = 16'b0000000000000000;    // nop
      IMemory[5]  = 16'b0110_01_10_11000000; // slt $t3,$t1,$t2
      IMemory[6]  = 16'b0000000000000000;    // nop
      IMemory[7]  = 16'b0000000000000000;    // nop
      IMemory[8]  = 16'b0000000000000000;    // nop
      //IMemory[9]  = 16'b1010_11_00_00000101; // beq $t3,$0,5  IMemory[15], 
      //IMemory[9] = 16'b1011_11_00_00000101 //bne $t3, $0, 5  IMemory[15].
      
     // Jumps to instruction address 13, swap.
      IMemory[9] = 16'b1111_00_00_00001101; //j IMemory[13], Because 15 is too late for the swap, as it reaches the nop.
      IMemory[10] = 16'b0000000000000000;    // nop
      IMemory[11] = 16'b0000000000000000;    // nop
      IMemory[12] = 16'b0000000000000000;    // nop
      IMemory[13] = 16'b1001_00_01_00000010; // sw $t1, 2($0)
      IMemory[14] = 16'b1001_00_10_00000000; // sw $t2, 0($0)
      IMemory[15] = 16'b0000000000000000;    // nop
      IMemory[16] = 16'b0000000000000000;    // nop
      IMemory[17] = 16'b0000000000000000;    // nop
      IMemory[18] = 16'b1000_00_01_00000000; // lw $t1, 0($0)
      IMemory[19] = 16'b1000_00_10_00000010; // lw $t2, 2($0)
      IMemory[20] = 16'b0000000000000000;    // nop
      IMemory[21] = 16'b0000000000000000;    // nop
      IMemory[22] = 16'b0000000000000000;    // nop
      IMemory[23] = 16'b0100_10_10_10000000; // nor $t2,$t2,$t2
      IMemory[24] = 16'b0000000000000000;    // nop
      IMemory[25] = 16'b0000000000000000;    // nop
      IMemory[26] = 16'b0000000000000000;    // nop
      IMemory[27] = 16'b0111_10_10_00000001; // addi $t2,$t2,1
      IMemory[28] = 16'b0000000000000000;    // nop
      IMemory[29] = 16'b0000000000000000;    // nop
      IMemory[30] = 16'b0000000000000000;    // nop
      IMemory[31] = 16'b0000_01_10_11000000; // add $t3,$t1,$t2

 
// Data
   DMemory[0] = 5; // switch the cells and see how the simulation output changes
   DMemory[1] = 7; // (beq is taken if DMemory[0]=7; DMemory[1]=5, not taken otherwise)
  end

// Pipeline 
// IF 
   wire [15:0] PCplus4, NextPC;
   reg[15:0] PC, IMemory[0:1023], IFID_IR, IFID_PCplus4;
   ALU fetch (4'b0010,PC,16'd2,PCplus4,Unused1);
   assign NextPC = (EXMEM_BEQ && EXMEM_Zero) || (EXMEM_BNE && ~EXMEM_Zero) ? EXMEM_Target : (EXMEM_JUMP) ? EXMEM_JumpHere: PCplus4;
// ID
   wire [11:0] Control;
   reg IDEX_RegWrite,IDEX_MemtoReg,
       IDEX_BEQ, IDEX_BNE, IDEX_JUMP, IDEX_MemWrite,
       IDEX_ALUSrc,  IDEX_RegDst;
   reg [3:0]  IDEX_ALUctl;
   wire [15:0] RD1,RD2,SignExtend, WD;
   reg [15:0] IDEX_PCplus4,IDEX_RD1,IDEX_RD2,IDEX_SignExt,IDEXE_IR;
   reg [15:0] IDEX_IR; // For monitoring the pipeline
   reg [1:0]  IDEX_rt,IDEX_rd;
   reg MEMWB_RegWrite; // part of MEM stage, but declared here before use (to avoid error)
   reg [1:0] MEMWB_rd; // part of MEM stage, but declared here before use (to avoid error)
   reg_file rf (IFID_IR[11:10],IFID_IR[9:8], MEMWB_rd,WD,MEMWB_RegWrite,RD1,RD2,clock);
   MainControl MainCtr (IFID_IR[15:12],Control); 
   assign SignExtend = {{8{IFID_IR[7]}},IFID_IR[7:0]}; 
// EXE
   reg EXMEM_RegWrite,EXMEM_MemtoReg,
       EXMEM_BEQ, EXMEM_BNE, EXMEM_JUMP, EXMEM_MemWrite;
   wire [15:0] Target;
   reg EXMEM_Zero;
   reg [15:0] EXMEM_Target,EXMEM_ALUOut,EXMEM_RD2;
   reg [15:0] EXMEM_IR; // For monitoring the pipeline
   reg [1:0] EXMEM_rd;
   reg [15:0] EXMEM_JumpHere;
   wire [15:0] B,ALUOut;
   wire [1:0] WR;
   ALU branch (4'b0010,IDEX_SignExt<<1,IDEX_PCplus4,Target,Unused2);
   ALU ex (IDEX_ALUctl, IDEX_RD1, B, ALUOut, Zero);
   assign B  = (IDEX_ALUSrc) ? IDEX_SignExt: IDEX_RD2;        // ALUSrc Mux 
   assign WR = (IDEX_RegDst) ? IDEX_rd: IDEX_rt;              // RegDst Mux
// MEM
   reg MEMWB_MemtoReg;
   reg [15:0] DMemory[0:1023],MEMWB_MemOut,MEMWB_ALUOut;
   reg [15:0] MEMWB_IR; // For monitoring the pipeline
   wire [15:0] MemOut;
   assign MemOut = DMemory[EXMEM_ALUOut>>1];
   always @(negedge clock) if (EXMEM_MemWrite) DMemory[EXMEM_ALUOut>>1] <= EXMEM_RD2;
// WB
   //assign WD = (MEMWB_MemtoReg) ? MEMWB_MemOut: MEMWB_ALUOut; // MemtoReg Mux
   muxB m2(MEMWB_ALUOut, MEMWB_MemOut,MEMWB_MemtoReg,WD);
   initial begin
    PC = 0;
// Initialize pipeline registers
    IDEX_RegWrite=0;IDEX_MemtoReg=0;IDEX_BEQ=0;IDEX_BNE=0;IDEX_JUMP=0;IDEX_MemWrite=0;IDEX_ALUSrc=0;IDEX_RegDst=0;IDEX_ALUctl=0;
    IFID_IR=0;
    EXMEM_RegWrite=0;EXMEM_MemtoReg=0;EXMEM_BEQ=0;EXMEM_BNE=0;EXMEM_JUMP=0;EXMEM_MemWrite=0;
    EXMEM_Target=0;
    MEMWB_RegWrite=0;MEMWB_MemtoReg=0;
   end

// Running the pipeline
   always @(negedge clock) begin 
// IF
    PC <= NextPC;
    IFID_PCplus4 <= PCplus4;
    IFID_IR <= IMemory[PC>>1];
// ID
    IDEX_IR <= IFID_IR; // For monitoring the pipeline
    {IDEX_RegDst,IDEX_ALUSrc,IDEX_MemtoReg,IDEX_RegWrite,IDEX_MemWrite,IDEX_BEQ, IDEX_BNE, IDEX_JUMP, IDEX_ALUctl} <= Control;   
    IDEX_PCplus4 <= IFID_PCplus4;
    IDEX_RD1 <= RD1; 
    IDEX_RD2 <= RD2;
    IDEX_SignExt <= SignExtend;
    IDEX_rt <= IFID_IR[9:8];
    IDEX_rd <= IFID_IR[7:6];
// EXE
    EXMEM_IR <= IDEX_IR; // For monitoring the pipeline
    EXMEM_RegWrite <= IDEX_RegWrite;
    EXMEM_MemtoReg <= IDEX_MemtoReg;
    EXMEM_BEQ  <= IDEX_BEQ;
    EXMEM_JUMP  <= IDEX_JUMP;
    EXMEM_BNE  <= IDEX_BNE;
    EXMEM_MemWrite <= IDEX_MemWrite;
    EXMEM_Target <= Target;
    EXMEM_Zero <= Zero;
    EXMEM_ALUOut <= ALUOut;
    EXMEM_RD2 <= IDEX_RD2;
    EXMEM_rd <= WR;
    EXMEM_JumpHere <= {4'b0000, IDEX_IR[11:0]} << 1; //This was failing, for Jump to work, it has to be logically pipelined
    //I thought it would work if it simply assigned, but then I recalled this was not the single cycle datapath anymore. 
   //It was driving me nuts for houyrs, but is simple. Since J uses absoulute address simply take the 12 bits of the address, pad with 0s to reach 
   //the required 16, and shift left by one to multiply by two to align it to the proper byte address, just like normal MIPS.
// MEM
    MEMWB_IR <= EXMEM_IR; // For monitoring the pipeline
    MEMWB_RegWrite <= EXMEM_RegWrite;
    MEMWB_MemtoReg <= EXMEM_MemtoReg;
    MEMWB_MemOut <= MemOut;
    MEMWB_ALUOut <= EXMEM_ALUOut;
    MEMWB_rd <= EXMEM_rd;
// WB
// Register write happens on neg edge of the clock (if MEMWB_RegWrite is asserted)
  end
endmodule

// Test module
module test ();
  reg clock;
  wire signed [15:0] PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD;
  CPU test_cpu(clock,PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD);
  always #1 clock = ~clock;
  initial begin
    $display ("PC   IFID_IR  IDEX_IR  EXMEM_IR MEMWB_IR  WD");
    $monitor ("%3d  %h %h %h %h %2d",PC,IFID_IR,IDEX_IR,EXMEM_IR,MEMWB_IR,WD);
    clock = 1;
    #69 $finish;
  end
endmodule

/* Output:
PC   IFID_IR  IDEX_IR  EXMEM_IR MEMWB_IR  WD
  0  00000000 xxxxxxxx xxxxxxxx xxxxxxxx  x
  4  8c090000 00000000 xxxxxxxx xxxxxxxx  x
  8  8c0a0004 8c090000 00000000 xxxxxxxx  x
 12  00000000 8c0a0004 8c090000 00000000  0
 16  00000000 00000000 8c0a0004 8c090000  5
 20  00000000 00000000 00000000 8c0a0004  7
 24  012a582a 00000000 00000000 00000000  0
 28  00000000 012a582a 00000000 00000000  0
 32  00000000 00000000 012a582a 00000000  0
 36  00000000 00000000 00000000 012a582a  1
 40  11600005 00000000 00000000 00000000  0
 44  00000000 11600005 00000000 00000000  0
 48  00000000 00000000 11600005 00000000  0
 52  00000000 00000000 00000000 11600005  1
 56  ac090004 00000000 00000000 00000000  0
 60  ac0a0000 ac090004 00000000 00000000  0
 64  00000000 ac0a0000 ac090004 00000000  0
 68  00000000 00000000 ac0a0000 ac090004  4
 72  00000000 00000000 00000000 ac0a0000  0
 76  8c090000 00000000 00000000 00000000  0
 80  8c0a0004 8c090000 00000000 00000000  0
 84  00000000 8c0a0004 8c090000 00000000  0
 88  00000000 00000000 8c0a0004 8c090000  7
 92  00000000 00000000 00000000 8c0a0004  5
 96  014a5027 00000000 00000000 00000000  0
100  00000000 014a5027 00000000 00000000  0
104  00000000 00000000 014a5027 00000000  0
108  00000000 00000000 00000000 014a5027 -6
112  214a0001 00000000 00000000 00000000 -1
116  00000000 214a0001 00000000 00000000 -1
120  00000000 00000000 214a0001 00000000 -1
124  00000000 00000000 00000000 214a0001 -5
128  012a5820 00000000 00000000 00000000  0
132  xxxxxxxx 012a5820 00000000 00000000  0
136  xxxxxxxx xxxxxxxx 012a5820 00000000  0
140  xxxxxxxx xxxxxxxx xxxxxxxx 012a5820  2
*/