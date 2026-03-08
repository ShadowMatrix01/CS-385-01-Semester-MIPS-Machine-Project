// Gate Level implementation of a 16-bit MIPS ALU for Progress Report 1

// 1-bit ALU (bits 0-14)
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


// test module (same test cases, widened to 16-bit)
module testALU;

   reg signed [15:0] a;
   reg signed [15:0] b;
   reg [3:0] op;
   wire signed [15:0] result;
   wire zero;

   ALU alu (op,a,b,result,zero);

   initial begin
    $display("op   a                        b                        result                   zero");
    $monitor ("%b %b(%d) %b(%d) %b(%d) %b",op,a,a,b,b,result,result,zero);

       op = 4'b0000; a = 16'b0000000000000111; b = 16'b0000000000000001;
    #1 op = 4'b0001; a = 16'b0000000000000101; b = 16'b0000000000000010;
    #1 op = 4'b0010; a = 16'b0000000000000100; b = 16'b0000000000000010;
    #1 op = 4'b0010; a = 16'b0000000000000111; b = 16'b0000000000000001;
    #1 op = 4'b0110; a = 16'b0000000000000101; b = 16'b0000000000000011;
    #1 op = 4'b0110; a = 16'b1111111111111111; b = 16'b0000000000000001;
    #1 op = 4'b0111; a = 16'b0000000000000101; b = 16'b0000000000000001;
    #1 op = 4'b0111; a = 16'b1111111111111110; b = 16'b1111111111111111;
    #1 op = 4'b1100; a = 16'b0000000000000101; b = 16'b0000000000000010;
    #1 op = 4'b1101; a = 16'b0000000000000101; b = 16'b0000000000000010;
   end

endmodule