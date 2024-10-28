module ROM(input[7:0]A, output reg[31:0]I);
  reg[7:0] Mem[0:255];
      
  always @(A)begin
    I <= {Mem[A], Mem[A+1], Mem[A+2], Mem[A+3]};
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
          default
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
  	input [7:0] D,
    input LE, Clr, Clk,
    output reg [7:0] Q
);
  
  always @ (posedge Clk) begin//rising edge triggered
    if (Clr) Q <= 8'b00000000;
    else if (LE) Q <= D;
  end
  
endmodule

module mux_2x1 (
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
  input [7:0] A,
  input [7:0] B,
  output reg [7:0] result
);
  always @(A, B)
      result = A + B;
endmodule

//Pipeline Register IF/ID
module Pipeline_Register_IF_ID (input [31:0] InstuctionMemoryOut,
                                input [7:0] NextPC, 
                                input  Clr, Clk, E,
  								output reg [23:0] I23_0,
                                output reg [7:0] output_NextPC,
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
  input [7:0] next_pc_in,
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
  output reg [7:0] next_pc_out,
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
                                input ALU_Out,
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
