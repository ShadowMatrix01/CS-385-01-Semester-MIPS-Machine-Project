// Names: Aiden Ocasio, Jacob Rulka, and Jhan Gomez
// Instructor: Professor Markov
// Course: CS-385-01
// Date: 04/02/26
// Purpose: 16-bit MIPS single-cycle CPU (R-type + I-type)

// MUXES 
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

module mux2x1(a, b, select, out);
input a, b, select;
output out;
wire notselect;
not (notselect, select);
and (a_out, a, notselect);
and (b_out, b, select);
or (out, a_out, b_out);
endmodule

module muxWR(a, b, select, out);
input [1:0] a, b;
input select;
output [1:0] out;
mux2x1 one(a[0], b[0], select, out[0]);
mux2x1 two(a[1], b[1], select, out[1]);
endmodule

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

// ALU 
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

// REG FILE

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

// CONTROL

//Main control determines if R-type instruction or I-type instruction and sends the coressponding bit [From MSB to LSB] to RegDst,ALUSrc,RegWrite,and ALUOp
module MainControl (Op,Control); 
  input [3:0] Op;
  output reg [10:0] Control; //Control is now 11 bits.
// Control bits: RegDst, ALUSrc, MemToReg, RegWrite, MemWrite, beq, bne, ALUctl
  always @(Op) case (Op)
   // R type Instructions:
    4'b0000: Control <= 11'b10010_00_0010; // ADD
    4'b0001: Control <= 11'b10010_00_0110; // SUB
    4'b0010: Control <= 11'b10010_00_0000; // AND
    4'b0011: Control <= 11'b10010_00_0001; // OR
    4'b0101: Control <= 11'b10010_00_1101; // NAND
    4'b0100: Control <= 11'b10010_00_1100; // NOR
    4'b0110: Control <= 11'b10010_00_0111; // SLT

  // I type Instructions:
   4'b0111: Control <= 11'b01010_00_0010; // ADDI
   4'b1000: Control <= 11'b01110_00_0010; // LW
   4'b1001: Control <= 11'b01001_00_0010; // SW
   4'b1010: Control <= 11'b00000_10_0110; // BEQ
   4'b1011: Control <= 11'b00000_01_0110; // BNE

    default: Control <= 11'b00000000000;
  endcase
endmodule

//Branch control determines if the branch should be taken based on the opcode and the zero flag from the ALU.
module branch_control (beq, bne, zero, PCSrc);
    input beq, bne, zero;
    output PCSrc;
    wire notzero;
    not (notzero, zero);
    wire beq_taken, bne_taken;
    and (beq_taken, beq, zero);
    and (bne_taken, bne, notzero);
    or (PCSrc, beq_taken, bne_taken);
endmodule

//CPU 

module CPU (clock,PC,WD,IR);
  input clock;
  output [15:0] WD,IR,PC;
  reg [15:0] PC;
  reg[15:0] IMemory[0:1023], DMemory[0:1023]; //Expanded with data memory.
  wire [15:0] NextPC,A,B,ALUOut,RD2,SignExtend;
  wire [15:0] BranchTarget, PCNext;
  wire [3:0] ALUctl;
  wire [1:0] WR;
  wire [15:0] WD; //Needed to write to a data memory address.
  wire RegDst, ALUSrc, RegWrite;
  wire beq, bne, Zero, PCSrc;
  wire MemWrite, MemtoReg;
  wire Unused, Unused2;
  wire [15:0] MemReturn;
  initial begin
  // Program (converted to 16-bit)
  IMemory[0] = 16'b1000_00_01_00000000; // lw t1,0($0)
  IMemory[1] = 16'b1000_00_10_00000010; // lw t2,2($0)
  IMemory[2] = 16'b0110_01_10_11_000000; // slt t3,t1,t2
  IMemory[3] = 16'b1011_11_00_00000010; //bne $t3, $zero, skip
  IMemory[4] = 16'b1001_00_01_00000010; // sw t1,2($0)
  IMemory[5] = 16'b1001_00_10_00000000; // sw t2,0($0)
  IMemory[6] = 16'b1000_00_01_00000000; // lw t1,0($0)
  IMemory[7] = 16'b1000_00_10_00000010; // lw t2,2($0)
  IMemory[8] = 16'b0100_10_10_10_000000; // nor t2,t2,t2
  IMemory[9] = 16'b0111_10_10_00000001; // addi t2,t2,1
  IMemory[10]= 16'b0000_01_10_11_000000; // add t3,t1,t2
  DMemory[1] = 7;
  DMemory[0] = 5; // address 2 (because >>1)
end
  initial PC = 0;
  assign IR = IMemory[PC>>1];
  assign MemReturn = DMemory[ALUOut>>1];

  muxWR write(IR[9:8], IR[7:6], RegDst, WR);
  assign SignExtend = {{8{IR[7]}},IR[7:0]};
  muxB mb(RD2, SignExtend, ALUSrc, B);

  muxB write_back(ALUOut, MemReturn, MemtoReg, WD);
  reg_file rf (IR[11:10],IR[9:8],WR,WD,RegWrite,A,RD2,clock);

  ALU fetch (4'b0010,PC,16'd2,NextPC,);
  ALU ex (ALUctl, A, B, ALUOut, Zero);
  
  MainControl MainCtr (IR[15:12],
    {RegDst, ALUSrc, MemtoReg, RegWrite, MemWrite, beq, bne, ALUctl});
    
  branch_control BCU (beq, bne, Zero, PCSrc);
  ALU branch_adder (4'b0010, NextPC, {SignExtend[14:0],1'b0}, BranchTarget,Unused2);
  muxB PC_mux(NextPC, BranchTarget, PCSrc, PCNext);
  always @(negedge clock) begin
    PC <= PCNext;
    if (MemWrite)
      DMemory[ALUOut>>1] <= RD2;
  end
endmodule

module test ();
  reg clock;
  wire signed [15:0] WD,IR,PC;
  CPU cpu(clock,PC,WD,IR);
  always #1 clock = ~clock;
  initial begin
    $display ("PC   IR                        WD        ");
    $monitor ("%2d   (%b)   %d (%b)",PC,IR,WD, WD);
    clock = 1;
    #20 $finish;
  end
endmodule
