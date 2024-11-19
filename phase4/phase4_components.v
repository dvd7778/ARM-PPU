module ROM(input[7:0]A, output reg[31:0]I);
  reg[7:0] Mem[0:255];
      
  always @(A)begin
    I <= {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]};
  end
endmodule

module RAM(input[7:0]A, input [31:0]DI, input Size, input RW, input E, output reg[31:0]DO);
  reg[7:0] Mem[0:255];
      
  always @(A, DI, Size, RW, E)
   
    if(RW == 0) begin//Read
      case(Size)

        1'b0: DO <= {24'b0, Mem[A]};//Byte

        1'b1: DO <= {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]};//Word
      endcase
        end
    else begin
      if(E == 1)begin //Write
        case(Size)

          1'b0: Mem[A] <= DI[7:0];

          1'b1: begin
            Mem[A] <= DI[31:24];
            Mem[A+1] <= DI[23:16];
            Mem[A+2] <= DI[15:8];
            Mem[A+3] <= DI[7:0];
          end
          endcase
      end
    end
 
endmodule


module control_unit(
  input [31:0] instr,
  output reg [3:0] ALU_op,
  output reg [1:0] AM,
  output reg B_instr,
  output reg BL_instr,
  output reg S,
  output reg load_instr,
  output reg RF_enable,
  output reg size,
  output reg RW,
  output reg E
);
  // Data processing opcodes
  parameter AND = 4'b0000;
  parameter EOR = 4'b0001;
  parameter SUB = 4'b0010;
  parameter RSB = 4'b0011;
  parameter ADD = 4'b0100;
  parameter ADC = 4'b0101;
  parameter SBC = 4'b0110;
  parameter RSC = 4'b0111;
  parameter ORR = 4'b1100;
  parameter MOV = 4'b1101;
  parameter BIC = 4'b1110;
  parameter MVN = 4'b1111;
	
  always @(instr) begin
    ALU_op = 4'b1001;
    B_instr = 0;
    BL_instr = 0;
    AM = 2'b01; 
    S = 0;
    RW = 0;
    load_instr = 0;
    RF_enable = 0;
    size = 0;
    E = 0;
      
    case (instr[27:25])
      // data processing with shift
      3'b000: begin
        case (instr[24:21])
          AND:
            ALU_op = 4'b0110;
          EOR:
            ALU_op = 4'b1000;
          SUB:
            ALU_op = 4'b0010;
          RSB:
            ALU_op = 4'b0100;
          ADD:
            ALU_op = 4'b0000;
          ADC:
            ALU_op = 4'b0001;
          SBC:
            ALU_op = 4'b0011;
          RSC:
            ALU_op = 4'b0101;
          ORR:
            ALU_op = 4'b0111;
          MOV:
            ALU_op = 4'b1010;
          BIC:
            ALU_op = 4'b1100;
          MVN:
            ALU_op = 4'b1011;
          default:
            ALU_op = 4'b1001;
        endcase
        AM = 2'b11;
        S = instr[20];
      end
        
      // data processing no shift
      3'b001: begin
        case (instr[24:21])
          AND:
            ALU_op = 4'b0110;
          EOR:
            ALU_op = 4'b1000;
          SUB:
            ALU_op = 4'b0010;
          RSB:
            ALU_op = 4'b0100;
          ADD:
            ALU_op = 4'b0000;
          ADC:
            ALU_op = 4'b0001;
          SBC:
            ALU_op = 4'b0011;
          RSC:
            ALU_op = 4'b0101;
          ORR:
            ALU_op = 4'b0111;
          MOV:
            ALU_op = 4'b1010;
          BIC:
            ALU_op = 4'b1100;
          MVN:
            ALU_op = 4'b1011;
          default:
            ALU_op = 4'b1001;
        endcase
		AM = 2'b00;
        S = instr[20];
      end
        
      // load and store
      3'b010: begin
        if (instr[23])
          ALU_op = 4'b0000;
        else
          ALU_op = 4'b0010;
        AM = 2'b10;
        load_instr = instr[20];
        size = instr[22];
        RW = !instr[20];
        E = 1;
        RF_enable = 1;
       end
        
      // load and store
      3'b011: begin
        if (instr[23])
          ALU_op = 4'b0000;
        else
          ALU_op = 4'b0010;
        AM = 2'b11;
        load_instr = instr[20];
        size = instr[22];
        RW = !instr[20];
        E = 1;
        RF_enable = 1;
      end
        
      //  BL and B
      3'b101: begin
        B_instr = 1;
        BL_instr = instr[24]; 
      end
    endcase
  end
endmodule

// Code your design here
module Register_PC(
   input [31:0] D,
   input LE, Clr, Clk,
   output reg [31:0] Q
);
  
  always @ (posedge Clk) begin//rising edge triggered
    if (Clr) Q <= 8'b00000000;
    else if (LE) Q <= D;
  end
  
endmodule

module Register_PSR(
    input S,
  	input Z, N, C, V,
  	output reg Z_out, N_out, C_out, V_out
);
  
  always @ (S) begin
    if (S) begin
      Z_out = Z;
      N_out = N;
      C_out = C;
      V_out = V;
    end
  end
  
endmodule

//Mux 2x1 32b
module mux_2x1_32b (
    input S, 
    input [31:0] A, 
    input [31:0] B,
    output reg [31:0] Y
);
  
  always @ (S, A, B) begin
    if (S) Y = A;
      else Y = B;
  end
  
endmodule

//Mux 2x1 8b
module mux_2x1_8b (
  input S, 
  input [7:0] A, 
  input [7:0] B,
  output reg [7:0] Y
);
  
  always @ (S, A, B) begin
    if (S) Y = A;
      else Y = B;
  end
  
endmodule

//Mux 2x1 4b
module mux_2x1_4b (
  input S, 
  input [3:0] A, 
  input [3:0] B,
  output reg [3:0] Y
);
  
  always @ (S, A, B) begin
    if (S) Y = A;
      else Y = B;
  end
  
endmodule

module CU_mux_2x1(
    //CU Signals
    input [3:0] ALU_op,
    input [1:0] AM,
    input B_instr, BL_instr, S,load_instr, RF_enable, size, RW, E,
    //NOP Signals
    input [3:0] NOP_ALU_op,
    input [1:0] NOP_AM,
    input NOP_B_instr, NOP_BL_instr, NOP_S ,NOP_load_instr, NOP_RF_enable, NOP_size, NOP_RW, NOP_E,
      
      input mux_e,
  
    output reg [3:0] out_ALU_op,
    output reg [1:0] out_AM,
    output reg out_B_instr, out_BL_instr, out_S ,out_load_instr, out_RF_enable, out_size, out_RW, out_E
  
);
  always @ (ALU_op, AM, B_instr, BL_instr, S, load_instr, RF_enable, size, RW, E) begin
    if (!mux_e) begin
      out_ALU_op = ALU_op;
      out_AM = AM;
      out_B_instr = B_instr;
      out_BL_instr = BL_instr;
      out_S = S;
      out_load_instr = load_instr;
      out_RF_enable = RF_enable;
      out_size = size;
      out_RW = RW;
      out_E = E;
    end
      else begin
      out_ALU_op = NOP_ALU_op;
      out_AM = NOP_AM;
      out_B_instr = NOP_B_instr;
      out_BL_instr = NOP_BL_instr;
      out_S = NOP_S;
      out_load_instr = NOP_load_instr;
      out_RF_enable = NOP_RF_enable;
      out_size = NOP_size;
      out_RW = NOP_RW;
      out_E = NOP_E;
    end
  end
endmodule

// Adder
module Adder(
  input [31:0] A,
  input [31:0] B,
  output reg [31:0] result
);
  always @(A, B)
      result = A + B;
endmodule

//Pipeline Register IF/ID
module Pipeline_Register_IF_ID (input [31:0] InstuctionMemoryOut,
                                input [31:0] NextPC, 
                                input  Clr, Clk, E,
  								output reg [23:0] I23_0,
                                output reg [31:0] output_NextPC,
                                output reg [3:0] I19_16,
                                output reg [3:0] I3_0,
                                output reg [3:0] I15_12,
                                output reg [3:0] I31_28,
                                output reg [11:0] I11_0,
                                output reg [31:0] I31_0 
);
  
    always @ (posedge Clk) begin
        if (Clr) begin 
            I23_0 <= 24'b0; 
            output_NextPC <= 8'b0; 
            I19_16 <= 4'b0; 
            I3_0 <= 4'b0; 
            I15_12 <= 4'b0; 
            I31_28 <= 4'b0; 
            I11_0 <= 12'b0; 
            I31_0 <= 32'b0; 
        end
        else begin
            I23_0 <= InstuctionMemoryOut[23:0]; 
            I19_16 <= InstuctionMemoryOut[19:16]; 
            output_NextPC <= NextPC; 
            I3_0 <= InstuctionMemoryOut[3:0]; 
            I15_12 <= InstuctionMemoryOut[15:12]; 
            I31_28 <= InstuctionMemoryOut[31:28]; 
            I11_0 <= InstuctionMemoryOut[11:0];  
            I31_0 <= InstuctionMemoryOut; 
        end
    end
endmodule

//Pipeline Register ID/EX
module Pipeline_register_ID_EX(
  input clr,
  input clk,
  input [31:0] next_pc_in,
  input [31:0] PA_in,
  input [31:0] PB_in,
  input [31:0] PD_in,
  input [3:0] RD_in,
  input [11:0] immediate_in,
  input [3:0] ID_ALU_op,
  input [1:0] ID_AM,
  input ID_S,
  input ID_load_instr,
  input ID_RF_enable,
  input ID_size,
  input ID_RW,
  input ID_E,
  output reg [31:0] next_pc_out,
  output reg [31:0] PA_out,
  output reg [31:0] PB_out,
  output reg [31:0] PD_out,
  output reg [3:0] RD_out,
  output reg [11:0] immediate_out,
  output reg [3:0] EX_ALU_op,
  output reg [1:0] EX_AM,
  output reg EX_S,
  output reg EX_load_instr,
  output reg EX_RF_enable,
  output reg EX_size,
  output reg EX_RW,
  output reg EX_E
);
  always @(posedge clk) begin // Trigger when the clock increases
    // output 0 when the clear bit is enabled
    if (clr) begin
      next_pc_out <= 32'b0;
      PA_out <= 32'b0;
      PB_out <= 32'b0;
      PD_out <= 32'b0;
      RD_out <= 4'b0;
      immediate_out <= 12'b0;
      EX_ALU_op <= 4'b0;
      EX_AM <= 2'b0;
      EX_S <= 0;
      EX_load_instr <= 0;
      EX_RF_enable <= 0;
      EX_size <= 0;
      EX_RW <= 0;
      EX_E <= 0;
    end
    else begin
      next_pc_out <= next_pc_in;
      PA_out <= PA_in;
      PB_out <= PB_in;
      PD_out <= PD_in;
      RD_out <= RD_in;
      immediate_out <= immediate_in;
      EX_ALU_op <= ID_ALU_op;
      EX_AM <= ID_AM;
      EX_S <= ID_S;
      EX_load_instr <= ID_load_instr;
      EX_RF_enable <= ID_RF_enable;
      EX_size <= ID_size;
      EX_RW <= ID_RW;
      EX_E <= ID_E;
    end
  end
endmodule

//Pipeline Register EX/MEM
module Pipeline_Register_EX_MEM(input [31:0] PD,
                                input [31:0]ALU_Out,
                                input Z_Flag,
                                input N_Flag,
                                input C_Flag,
                                input V_Flag,
                                input [3:0]EX_RD,
                                input EX_load_instr,
                                input EX_RF_enable,
                                input EX_Size,
                                input EX_RW,
                                input EX_E,
                                input Clr, Clk,
                                output reg [31:0] Data_Mem_Out,
                                output reg [31:0] Data_Mem_Add_Out,
                                output reg [3:0] RD_Out,
                                output reg MEM_load_instr,
                                output reg MEM_RF_enable,
                                output reg MEM_Size,
                                output reg MEM_RW,
                                output reg MEM_E);
  
    always @ (posedge Clk) begin //rising edge triggered Register
        if (Clr) begin
            Data_Mem_Out <= 32'b0;
            Data_Mem_Add_Out <= 32'b0;
            RD_Out <= 4'b0;
            MEM_load_instr <= 0;
            MEM_RF_enable <= 0;
            MEM_Size <= 0;
            MEM_RW <= 0;
            MEM_E <= 0;
        end
        else begin
            Data_Mem_Out <= PD[31:0]; 
            Data_Mem_Add_Out <= ALU_Out;
            RD_Out <= EX_RD;
            MEM_load_instr <= EX_load_instr;
            MEM_RF_enable <= EX_RF_enable;
            MEM_Size <= EX_Size;
            MEM_RW <= EX_RW;
            MEM_E <= EX_E;
        end
    end
endmodule

//Pipeline Register MEM/WB
module Pipeline_Register_MEM_WB(input [31:0] DataMemoryOutput,
                                input [3:0] RD,
                                input ID_RF_enable,
                                input Clr, Clk,
                                
                                output reg [31:0] out_DataMemory,
                                output reg [3:0] out_RD,
                                output reg out_ID_RF_enable
                               
);
                               
    always @ (posedge Clk) begin // Rising edge triggered Register
        if (Clr) begin
            out_DataMemory <= 32'b0;
            out_RD <= 4'b0;
            out_ID_RF_enable <= 1'b0;
        end
        else begin 
            out_DataMemory <= DataMemoryOutput;
            out_RD <= RD;
            out_ID_RF_enable <= ID_RF_enable;
        end
    end
endmodule






//------------------------------Phase 4----------------------------------------//

//Binary Decoder Module
module Binary_Decoder (
  input [3:0] D,
  input LE,
  output reg [15:0] O
  );

    
  always @(*) begin
    if (LE == 1'b1) begin
          case (D)
              4'b0000: O = 16'b0000000000000001; // Enable Register 0
              4'b0001: O = 16'b0000000000000010; // Enable Register 1
              4'b0010: O = 16'b0000000000000100; // Enable Register 2
              4'b0011: O = 16'b0000000000001000; // Enable Register 3
              4'b0100: O = 16'b0000000000010000; // Enable Register 4
              4'b0101: O = 16'b0000000000100000; // Enable Register 5
              4'b0110: O = 16'b0000000001000000; // Enable Register 6
              4'b0111: O = 16'b0000000010000000; // Enable Register 7
              4'b1000: O = 16'b0000000100000000; // Enable Register 8
              4'b1001: O = 16'b0000001000000000; // Enable Register 9
              4'b1010: O = 16'b0000010000000000; // Enable Register 10
              4'b1011: O = 16'b0000100000000000; // Enable Register 11
              4'b1100: O = 16'b0001000000000000; // Enable Register 12
              4'b1101: O = 16'b0010000000000000; // Enable Register 13
              4'b1110: O = 16'b0100000000000000; // Enable Register 14
              4'b1111: O = 16'b1000000000000000; // Enable Register 15
          
      endcase
      end else 
          O = 16'b0000000000000000;
  end    
  endmodule


//Register module
module Register (
  output reg [31:0] O,
  input [31:0] PW,
  input LE, Clk
);
    
  always @ (posedge Clk)
    if (LE) 
      O = PW;
  
endmodule


//Multiplexer module
module Multiplexer (
  output reg [31:0] Z,
  input [3:0] S,
  input [31:0] o0, o1, o2, o3, o4, o5, o6, o7, o8, o9, o10, o11, o12, o13, o14, o15
);
  
  always @ (*)
    begin
    case(S)
    4'b0000: Z = o0;
    4'b0001: Z = o1;
    4'b0010: Z = o2;
    4'b0011: Z = o3;
    4'b0100: Z = o4;
    4'b0101: Z = o5;
    4'b0110: Z = o6;
    4'b0111: Z = o7;
    4'b1000: Z = o8;
    4'b1001: Z = o9;
    4'b1010: Z = o10;
    4'b1011: Z = o11;
    4'b1100: Z = o12;
    4'b1101: Z = o13;
    4'b1110: Z = o14;
    4'b1111: Z = o15;
 	
    endcase
    end
    endmodule


//Register File Module
module Three_port_register_file (
  input [3:0] RA, RB, RD, RW,   // 4-bit registers
  input [31:0] PW,              // Write value
  input [31:0] PC,              // PC value 
  input Clk, LE,                 // Clock and Load Enable
  output [31:0] PA, PB, PD     // Register output values
);

  wire [31:0] R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15;
  wire [15:0] O; 

  // Instantiate the Binary Decoder
  Binary_Decoder BD (RW, LE, O);

  // Instantiate Registers
  Register Regs0 (R0, PW, O[0], Clk);
  Register Regs1 (R1, PW, O[1], Clk);
  Register Regs2 (R2, PW, O[2], Clk);
  Register Regs3 (R3, PW, O[3], Clk);
  Register Regs4 (R4, PW, O[4], Clk);
  Register Regs5 (R5, PW, O[5], Clk);
  Register Regs6 (R6, PW, O[6], Clk);
  Register Regs7 (R7, PW, O[7], Clk);
  Register Regs8 (R8, PW, O[8], Clk);
  Register Regs9 (R9, PW, O[9], Clk);
  Register Regs10 (R10, PW, O[10], Clk);
  Register Regs11 (R11, PW, O[11], Clk);
  Register Regs12 (R12, PW, O[12], Clk);
  Register Regs13 (R13, PW, O[13], Clk);
  Register Regs14 (R14, PW, O[14], Clk);
  Register Regs15 (R15, PC, 1'b1, Clk);

  // Instantiate Multiplexers for outputs
  Multiplexer MuxA (PA, RA, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15);
  Multiplexer MuxB (PB, RB, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15);
  Multiplexer MuxD (PD, RD, R0, R1, R2, R3, R4, R5, R6, R7, R8, R9, R10, R11, R12, R13, R14, R15);

endmodule



module mux_4x1 (
  input [1:0] S, 
  input [31:0] A, B, C, D,
  output reg [31:0] Y
);
  
  always @(S, A, B, C, D) begin
    case (S)
        2'b00: Y = A;
        2'b01: Y = B;
        2'b10: Y = C;
        2'b11: Y = D;
    endcase
  end
endmodule
 
module alu (input [31:0] A, B, input Cin, input [3:0] Op, 
            output reg [31:0] Out, output reg Z, N, C, V);
  
  always @(A, B, Cin, Op) begin
    case (Op)
      4'b0000: begin
        {C, Out} = A + B;
        V = ~(A[31] ^ B[31]) & (A[31] ^ Out[31]);
        end
      4'b0001: begin
        {C, Out} = A + B + Cin;
        V = ~(A[31] ^ B[31]) & (A[31] ^ Out[31]);
        end
      4'b0010: begin
        {C, Out} = A - B;
        V = (A[31] ^ B[31]) & (A[31] ^ Out[31]);
        end
      4'b0011: begin
        {C, Out} = A - B - Cin;
        V = (A[31] ^ B[31]) & (A[31] ^ Out[31]);
        end
      4'b0100: begin
        {C, Out} = B - A;
        V = (B[31] ^ A[31]) & (B[31] ^ Out[31]);
        end
      4'b0101: begin
        {C, Out} = B - A - Cin;
        V = (B[31] ^ A[31]) & (B[31] ^ Out[31]);
        end
      4'b0110: begin
        Out = A & B;
        C = 0;
        V = 0;
        end
      4'b0111: begin
        Out = A | B;
        C = 0;
        V = 0;
        end
      4'b1000: begin 
        Out = A ^ B;
        C = 0;
        V = 0;
        end
      4'b1001: begin
        Out = A;
        C = 0;
        V = 0;
        end
      4'b1010: begin
        Out = B;
        C = 0;
        V = 0;
        end
      4'b1011: begin
        Out = ~B;
        C = 0;
        V = 0;
        end
      4'b1100: begin
        Out = A & (~B);
        C = 0;
        V = 0;
        end
    endcase
    
    if (Out == 0) Z = 1;
    else Z = 0;

    N = Out[31];
  end
endmodule

module shifter (input [31:0] Rm, input [11:0] I, input [1:0] AM, 
                output reg [31:0] N);
  
  always @(Rm, I, AM) begin
    case(AM)
      2'b00: N = ({24'h000, I[7:0]} >> (2 * I[11:8])) | ({24'h000, I[7:0]} << (32 - (2 * I[11:8])));
      2'b01: N = Rm;
      2'b10: N = {20'b00000000000000000000, I};
      2'b11: begin
        case (I[6:5])
          2'b00: N = Rm << I[11:7]; 						   // LSL
          2'b01: N = Rm >> I[11:7]; 					   	   // LSR
          2'b10: N = Rm >>> I[11:7]; 						   // LSR
          2'b11: N = (Rm >> I[11:7]) | (Rm << (32 - I[11:7])); // ROR
        endcase
      end
    endcase
  end
endmodule

    
