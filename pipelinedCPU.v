// Names: Aiden Ocasio, Jacob Rulka, and Jhan Gomez
// Instructor: Professor Markov
// Course: CS-385-01
// Date: 04/21/26
// Purpose: To demonstrate how a simplfied, 
// and pipelined 16 bit MIPS cpu can operate for R-type instructions and ADDI.
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
//1 bit alu works on bits 0-14 and does operations accordingly.
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

//Main control determines if R-type instruction or I-type instruction and sends the coressponding bit [From MSB to LSB] to  RegDst, ALUSrc, MemToReg, RegWrite, MemWrite, beq, bne, ALUctl
module MainControl (Op,Control); 
  input [3:0] Op;
  output reg [6:0] Control; //Control is now 7 bits since no branching.
// Control bits: IDEX_RegDst,IDEX_ALUSrc,IDEX_RegWrite,IDEX_ALUctl;
  always @(Op) case (Op)
  //R type instructions
    4'b0000: Control <= 7'b1_0_1_0010; // ADD
    4'b0001: Control <= 7'b1_0_1_0110; // SUB
    4'b0010: Control <= 7'b1_0_1_0000; // AND
    4'b0011: Control <= 7'b1_0_1_0001; // OR
    4'b0101: Control <= 7'b1_0_1_1101; // NAND
    4'b0100: Control <= 7'b1_0_1_1100; // NOR
    4'b0110: Control <= 7'b1_0_1_0111; // SLT
    //I type instruction:
    4'b0111: Control <= 7'b0_1_1_0010; // ADDI
    default: Control <= 7'b0000000;
 endcase
endmodule


module CPU (clock,PC,IFID_IR,IDEX_IR,WD);
  input clock;
  output [15:0] PC,IFID_IR,IDEX_IR,WD;
  reg[15:0] PC, IMemory[0:1023];

  initial begin
// Program with nop's - no hazards
  IMemory[0] = 16'b0111_00_01_00_001111; //addi $t1,$zero,15  ($t1=15)
  IMemory[1] = 16'b0111_00_10_00_000111; //addi $t2,$zero,7  ($t2= 7)
  IMemory[2] = 16'b0000_00_00_00_000000; //nop
  IMemory[3] = 16'b0010_01_10_11_000000; //and $t3,$t1,$t2   ($t3= 7)
  IMemory[4] = 16'b0000_00_00_00_000000; //nop
  IMemory[5] = 16'b0001_01_11_10_000000; //sub $t2,$t1,$t3   ($t2= 8)
  IMemory[6] = 16'b0000_00_00_00_000000; //nop
  IMemory[7] = 16'b0011_10_11_10_000000; //or $t2,$t2,$t3   ($t2=15)
  IMemory[8] = 16'b0000_00_00_00_000000; //nop
  IMemory[9] = 16'b0000_10_11_11_000000; //add $t3,$t2,$t3   ($t3=22)
  IMemory[10] = 16'b0000_00_00_00_000000; //nop
  IMemory[11] = 16'b0100_10_11_01_000000; //nor $t1,$t2,$t3   ($t1=-32)
  IMemory[12] = 16'b0110_11_10_01_000000; //slt $t1,$t3,$t2   ($t1= 0)
  IMemory[13] = 16'b0110_10_11_01_000000; //slt $t1,$t2,$t3   ($t1= 1)
end
  
/*
  initial begin 
// Program without nop's - wrong results due to data hazards
  IMemory[0] = 16'b0111_00_01_00_001111; //addi $t1,$zero,15  ($t1=15)
  IMemory[1] = 16'b0111_00_10_00_000111; //addi $t2,$zero,7  ($t2= 7)
  IMemory[2] = 16'b0010_01_10_11_000000; //and $t3,$t1,$t2   ($t3= 7)
  IMemory[3] = 16'b0001_01_11_10_000000; //sub $t2,$t1,$t3   ($t2= 8)
  IMemory[4] = 16'b0011_10_11_10_000000; //or $t2,$t2,$t3   ($t2=15)
  IMemory[5] = 16'b0000_10_11_11_000000; //add $t3,$t2,$t3   ($t3=22)
  IMemory[6] = 16'b0100_10_11_01_000000; //nor $t1,$t2,$t3   ($t1=-32)
  IMemory[7] = 16'b0110_11_10_01_000000; //slt $t1,$t3,$t2   ($t1= 0)
  IMemory[8] = 16'b0110_10_11_01_000000; //slt $t1,$t2,$t3   ($t1= 1)
  end
*/
// Pipeline stages
//=== IF STAGE ===
   wire [15:0] NextPC;
//--------------------------------
   reg[15:0] IFID_IR;
//--------------------------------
   ALU fetch (4'b0010,PC,16'd2,NextPC,Unused);

//=== ID STAGE ===
   wire [6:0] Control;
   wire [15:0] RD1,RD2,SignExtend,WD;
   wire [15:0] FWD_RD1,FWD_RD2; // Outputs of the forwarding muxes
   reg [15:0] IDEX_IR; // For monitoring the pipeline
   reg IDEX_RegWrite,IDEX_ALUSrc,IDEX_RegDst;
   reg [15:0] IDEX_RD1,IDEX_RD2,IDEX_SignExt;
   reg [1:0]  IDEX_rt,IDEX_rd;
   wire [1:0] WR;
   reg_file rf (IFID_IR[11:10],IFID_IR[9:8],WR,WD,IDEX_RegWrite,RD1,RD2,clock);
   MainControl MainCtr (IFID_IR[15:12],Control);
   assign SignExtend = {{8{IFID_IR[7]}},IFID_IR[7:0]};


//=== EXE STAGE ===
   wire [15:0] B,ALUOut;
   reg [3:0] IDEX_ALUctl;
   ALU ex (IDEX_ALUctl, IDEX_RD1, B, ALUOut, Zero);
   assign B  = (IDEX_ALUSrc) ? IDEX_SignExt: IDEX_RD2;   // ALUSrc Mux 
   assign WR = (IDEX_RegDst) ? IDEX_rd: IDEX_rt;         // RegDst Mux
   assign WD = ALUOut;

// Forwarding multiplexers
   assign FWD_RD1 = (IDEX_RegWrite && WR==IFID_IR[11:10]) ? ALUOut: RD1;
   assign FWD_RD2 = (IDEX_RegWrite && WR==IFID_IR[9:8])  ? ALUOut: RD2;

   initial begin
    PC = 0;
    IFID_IR = 0; // clear pipeline register to avoid forwarding from empty pipeline
    IDEX_RegWrite = 0; 
   end

// Running the pipeline
   always @(negedge clock) begin

// Stage 1 - IF
    PC <= NextPC;
    IFID_IR <= IMemory[PC>>1];

// Stage 2 - ID
    IDEX_IR <= IFID_IR; // For monitoring the pipeline
    {IDEX_RegDst,IDEX_ALUSrc,IDEX_RegWrite,IDEX_ALUctl} <= Control;    

//  No Forwarding
    IDEX_RD1 <= RD1; 
    IDEX_RD2 <= RD2;

//  Forwarding
//  IDEX_RD1 <= FWD_RD1; 
//  IDEX_RD2 <= FWD_RD2;

    IDEX_SignExt <= SignExtend;
    IDEX_rt <= IFID_IR[9:8];
    IDEX_rd <= IFID_IR[7:6];

// Stage 3 - EX
// No transfers needed here - on negedge WD is written into register WR
  end
endmodule

// Test module
module test ();
  reg clock;
  wire signed [15:0] PC,IFID_IR,IDEX_IR,WD;
  CPU test_cpu(clock,PC,IFID_IR,IDEX_IR,WD);
  always #1 clock = ~clock;
  initial begin
    $display ("PC  IFID_IR   IDEX_IR   WD");
    $monitor ("%2d    %h      %h    %2d",PC,IFID_IR,IDEX_IR,WD);
    clock = 1;
    #29 $finish;
  end
endmodule

/* Output
Program with nop's
---------------------------
 PC  IFID_IR   IDEX_IR   WD
 0  00000000  xxxxxxxx   x
 4  2009000f  00000000   x
 8  200a0007  2009000f  15
12  00000000  200a0007   7
16  012a5824  00000000   0
20  00000000  012a5824   7
24  012b5022  00000000   0
28  00000000  012b5022   8
32  014b5025  00000000   0
36  00000000  014b5025  15
40  014b5820  00000000   0
44  00000000  014b5820  22
48  014b4827  00000000   0
52  016a482a  014b4827  -32
56  014b482a  016a482a   0
60  xxxxxxxx  014b482a   1

Program without nop's
--------------------------
PC  IFID_IR   IDEX_IR   WD
 0  00000000  xxxxxxxx   x
 4  2009000f  00000000   x
 8  200a0007  2009000f  15
12  012a5824  200a0007   7
16  012b5022  012a5824   X
20  014b5025  012b5022   x
24  014b5820  014b5025   X
28  014b4827  014b5820   x
32  016a482a  014b4827   X
36  014b482a  016a482a   X
40  xxxxxxxx  014b482a   X
44  xxxxxxxx  xxxxxxxx   X
48  xxxxxxxx  xxxxxxxx   X
52  xxxxxxxx  xxxxxxxx   X
56  xxxxxxxx  xxxxxxxx   X
60  xxxxxxxx  xxxxxxxx   X
*/