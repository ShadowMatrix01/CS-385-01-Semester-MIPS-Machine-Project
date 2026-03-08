// Behavioral model of MIPS - single cycle implementation, R-types and addi
module reg_file (RR1,RR2,WR,WD,RegWrite,RD1,RD2,clock);
  input [1:0] RR1,RR2,WR;
  input [15:0] WD;
  input RegWrite,clock;
  output [15:0] RD1,RD2;
  reg [15:0] Regs[0:15];
  assign RD1 = Regs[RR1];
  assign RD2 = Regs[RR2];
  initial Regs[0] = 0;
  always @(negedge clock)
    if (RegWrite==1 & WR!=0) 
	Regs[WR] <= WD;
endmodule

module ALU (ALUctl,A,B,ALUOut,Zero);
  input [3:0] ALUctl;
  input [15:0] A,B;
  output reg [15:0] ALUOut;
  output Zero;
  always @(ALUctl, A, B) // reevaluate if these change
    case (ALUctl)
      4'b0000: ALUOut <= A & B;
      4'b0001: ALUOut <= A | B;
      4'b0010: ALUOut <= A + B;
      4'b0110: ALUOut <= A - B;
      4'b0111: ALUOut <= A < B ? 1: 0;
      4'b1100: ALUOut <= ~A & ~B;
      4'b1101: ALUOut <= ~A | ~B;
    endcase
  assign Zero = (ALUOut==0); // Zero is true if ALUOut is 0
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
    #16 $finish;
  end
endmodule