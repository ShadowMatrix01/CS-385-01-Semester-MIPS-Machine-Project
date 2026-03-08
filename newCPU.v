//Names: Aiden Ocasio, Jacob Rulka, and Jhan Gomez
//Instructor: Professor Markov
//Course: CS-385-01
//Date: 03/10/26
//Purpose: To show a simplified 16 bit MIPS single cycle machine that can execute R-type instructions and I-type instructions using a mix of behavorial and gate-level modeling.

// Behavioral implementation of MIPS Register File
module reg_file (RR1,RR2,WR,WD,RegWrite,RD1,RD2,clock);
  input [1:0] RR1,RR2,WR; //Instead of 5 bits for rs, rt, and rd, it is only two bits. 
  input [15:0] WD; //16 bits for complete instruction rather than the traditional 32 bits.
  input RegWrite,clock;
  output [15:0] RD1,RD2; //The read data ports of the reg file are likewise only 16 bits.

  reg [15:0] Regs[0:3]; //4 registers, 16 bits long.

  assign RD1 = Regs[RR1]; //RS is assigned to read data port 1.
  assign RD2 = Regs[RR2]; //RT is assigned to read data port 2.

  initial Regs[0] = 0; //$zeri must always be 0.

  always @(negedge clock)
    if (RegWrite==1 & WR!=0) //Prevents $zero from being overwritten and make sure only when asserted that Write Register is allowed.
    Regs[WR] <= WD;

endmodule


module ALU1 (a,b,ainvert,binvert,op,less,carryin,carryout,result);

   input a,b,less,carryin,ainvert,binvert;
   input [1:0] op;
   output carryout,result;

   wire nota,notb;
   wire a1,b1;
   wire and_out,or_out;
   wire sum;
   wire axb,ab,axb_cin;

   // Inverters
   not (nota,a);
   not (notb,b);

   // Input select
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

   // AND / OR
   and (and_out,a1,b1);
   or  (or_out,a1,b1);

   // Full Adder
   xor (axb,a1,b1);
   xor (sum,axb,carryin);

   and (ab,a1,b1);
   and (axb_cin,axb,carryin);
   or  (carryout,ab,axb_cin);

   // Operation select
   wire op0n,op1n;
   not (op0n,op[0]);
   not (op1n,op[1]);

   wire r0,r1,r2,r3;

   and (r0,and_out,op1n,op0n);
   and (r1,or_out,op1n,op[0]);
   and (r2,sum,op[1],op0n);
   and (r3,less,op[1],op[0]);

   or (result,r0,r1,r2,r3);

endmodule


// 1-bit MSB ALU (bit 15)
module ALUmsb (a,b,ainvert,binvert,op,less,carryin,carryout,result,set);

   input a,b,less,carryin,ainvert,binvert;
   input [1:0] op;
   output carryout,result,set;

   wire nota,notb;
   wire a1,b1;
   wire and_out,or_out;
   wire sum;
   wire axb,ab,axb_cin;

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

   xor (axb,a1,b1);
   xor (sum,axb,carryin);

   and (ab,a1,b1);
   and (axb_cin,axb,carryin);
   or  (carryout,ab,axb_cin);

   buf (set,sum);   // SLT set output is just the sum output of the MSB ALU

   wire op0n,op1n;
   not (op0n,op[0]);
   not (op1n,op[1]);

   wire r0,r1,r2,r3;

   and (r0,and_out,op1n,op0n);
   and (r1,or_out,op1n,op[0]);
   and (r2,sum,op[1],op0n);
   and (r3,less,op[1],op[0]);

   or (result,r0,r1,r2,r3);

endmodule


// 16-bit ALU
module ALU (op,a,b,result,zero);

   input  [15:0] a;
   input  [15:0] b;
   input  [3:0]  op;
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

   ALUmsb alu15 (a[15],b[15],op[3],op[2],op[1:0],1'b0,c15,c16,result[15],set);

   // Zero flag
   nor (zero,
        result[0],result[1],result[2],result[3],
        result[4],result[5],result[6],result[7],
        result[8],result[9],result[10],result[11],
        result[12],result[13],result[14],result[15]);

endmodule

module MainControl (Op,Control); 
  input [3:0] Op;
  output reg [3:0] Control;
// Control bits: RegDst,ALUSrc,RegWrite,ALUOp
  always @(Op) case (Op)
    4'b0000: Control <= 4'b1011; // Rtype
    4'b1000: Control <= 4'b0110; // ADDI
  endcase
endmodule

module ALUControl (ALUOp,FuncCode,ALUCtl); 
  input ALUOp;
  input [5:0] FuncCode;
  output reg [3:0] ALUCtl;
  always @(ALUOp,FuncCode) case (ALUOp)
    1'b0: ALUCtl <= 4'b0010; // add
    1'b1: case (FuncCode)
	     32: ALUCtl <= 4'b0010; // add
	     34: ALUCtl <= 4'b0110; // sub
	     36: ALUCtl <= 4'b0000; // and
	     37: ALUCtl <= 4'b0001; // or
	     38: ALUCtl <= 4'b1101; // nand
	     39: ALUCtl <= 4'b1100; // nor
	     42: ALUCtl <= 4'b0111; // slt
    endcase
  endcase
endmodule

module CPU (clock,PC,ALUOut,IR);
  input clock;
  output [15:0] ALUOut,IR,PC;
  reg[15:0] PC;
  reg[15:0] IMemory[0:1023];
  wire [15:0] IR,NextPC,A,B,ALUOut,RD2,SignExtend;
  wire[3:0] ALUctl;
  wire [1:0] WR; 
// Test Program
  initial begin 
    IMemory[0] = 16'h810f;  // addi $t1, $0,  15   ($t1=15)
    IMemory[1] = 16'h8207;  // addi $t2, $0,  7    ($t2=7)
    IMemory[2] = 16'h06e4;  // and  $t3, $t1, $t2  ($t3=7)
    IMemory[3] = 16'h07a2;  // sub  $t2, $t1, $t3  ($t2=8)
    IMemory[4] = 16'h0ba5;  // or   $t2, $t2, $t3  ($t2=15)
    IMemory[5] = 16'h0be0;  // add  $t3, $t2, $t3  ($t3=22)
    IMemory[6] = 16'h0b67;  // nor  $t1, $t2, $t3  ($t1=-32)
    IMemory[7] = 16'h0e6a;  // slt  $t1, $t3, $t2  ($t1=0)
    IMemory[8] = 16'h0b6a;  // slt  $t1, $t2, $t3  ($t1=1)
    IMemory[9] = 16'h0b66;  // nand $t1, $t2, $t3 ($t1=1)
  end
  initial PC = 0;
  assign IR = IMemory[PC>>1];
  assign WR = (RegDst) ? IR[7:6]: IR[9:8]; // RegDst Mux
  assign B  = (ALUSrc) ? SignExtend: RD2; // ALUSrc Mux 
  assign SignExtend = {{8{IR[7]}},IR[7:0]}; // sign extension unit
  //assign ALUctl = (ALUOp == 1'b0) ? 4'b0010 : IR[3:0]; // assign bit values to ALUctl
  reg_file rf (IR[11:10],IR[9:8],WR,ALUOut,RegWrite,A,RD2,clock);
  ALU fetch (4'b0010,PC,16'd2,NextPC,Unused);
  ALU ex (ALUctl, A, B, ALUOut, Zero);
  MainControl MainCtr (IR[15:12],{RegDst,ALUSrc,RegWrite,ALUOp});
  ALUControl ALUCtrl(ALUOp, IR[5:0], ALUctl); // ALU control unit
  always @(negedge clock) begin 
    PC <= NextPC;
  end
endmodule

// Test module
module test ();
  reg clock;
  wire signed [15:0] WD,IR,PC;
  CPU test_cpu(clock,PC,WD,IR);
  always #1 clock = ~clock;
  initial begin
    $display ("Clock PC   IR                                 WD");
    $monitor ("%b     %2d   %b  %3d (%b)",clock,PC,IR,WD,WD);
    clock = 1;
    #18 $finish;
  end
endmodule


/* Output
Clock PC   IR                                 WD
1      0   1000000100001111   15 (0000000000001111)
0      2   1000001000000111    7 (0000000000000111)
1      2   1000001000000111    7 (0000000000000111)
0      4   0000011011100100    7 (0000000000000111)
1      4   0000011011100100    7 (0000000000000111)
0      6   0000011110100010    8 (0000000000001000)
1      6   0000011110100010    8 (0000000000001000)
0      8   0000101110100101   15 (0000000000001111)
1      8   0000101110100101   15 (0000000000001111)
0     10   0000101111100000   22 (0000000000010110)
1     10   0000101111100000   22 (0000000000010110)
0     12   0000101101100111  -32 (1111111111100000)
1     12   0000101101100111  -32 (1111111111100000)
0     14   0000111001101010    0 (0000000000000000)
1     14   0000111001101010    0 (0000000000000000)
0     16   0000101101101010    1 (0000000000000001)
CPU2.v:264: $finish called at 16 (1s)
1     16   0000101101101010    1 (0000000000000001)
*/
