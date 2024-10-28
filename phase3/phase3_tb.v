// Code your testbench here
// or browse Examples
module PF3_ControlUnit_tb;
  
  //Register_PC
  reg LE, Clr, Clk;
  wire [7:0] Q;
  
   //ROM
  integer fi, code;
  reg [7:0]A;
  wire [31:0]I;
  reg [31:0]data;
  
  //CU signals
  wire [3:0] ALU_op;
  wire [1:0] AM;
  wire B_instr;
  wire BL_instr;
  wire S;
  wire load_instr;
  wire RF_enable;
  wire size;
  wire RW;
  wire E;
  
  //CU/MUX signals
  reg CU_MUX_S;
  
  //Adder
  wire [7:0] result;
  
  //Pipeline Register IF/ID
  wire [23:0] I23_0;
  wire [7:0] output_NextPC;
  wire [3:0] I19_16;
  wire [3:0] I3_0;
  wire [3:0] I15_12;
  wire [3:0] I31_28;
  wire [11:0] I11_0;
  wire [31:0] I31_0; 
  
//   //Pipeline Register ID/EX
//   reg clr;
//   reg clk;
//   reg [31:0] next_pc_in;
//   reg [31:0] PA_in;
//   reg [31:0] PB_in;
//   reg [31:0] PD_in;
//   reg [3:0] RD_in;
//   reg [11:0] immediate_in;
//   reg [3:0] ID_ALU_op;
//   reg [1:0] ID_AM;
//   reg ID_S;
//   reg ID_load_instr;
//   reg ID_RF_enable;
//   reg ID_size;
//   reg ID_RW;
//   reg ID_E;
//   wire [31:0] next_pc_out;
//   wire [31:0] PA_out;
//   wire [31:0] PB_out;
//   wire [31:0] PD_out;
//   wire [3:0] RD_out;
//   wire [11:0] immediate_out;
//   wire [3:0] EX_ALU_op;
//   wire [1:0] EX_AM;
//   wire EX_S;
//   wire EX_load_instr;
//   wire EX_RF_enable;
//   wire EX_size;
//   wire EX_RW;
//   wire EX_E;
  
//   //Pipeline Register EX/MEM
//   wire [31:0] Data_Mem_Out;
//   wire [31:0] Data_Mem_Add_Out;
//   wire [3:0] RD_Out;
//   wire MEM_load_instr;
//   wire MEM_RF_enable;
//   wire MEM_Size;
//   wire MEM_RW;
//   wire MEM_E;
//   reg [31:0] PD;
//   reg ALU_Out;
//   reg Z_Flag;
//   reg N_Flag;
//   reg C_Flag;
//   reg V_Flag;
//   reg EX_RD;
//   reg EX_load_instr;
//   reg EX_RF_enable;
//   reg EX_Size;
//   reg EX_RW;
//   reg EX_E;
//   reg Clr, Clk;
  
//   //Pipeline Register MEM/WB
//   reg [31:0] DataMemoryOutput;
//   reg [3:0] RD;
//   reg ID_RF_enable;
//   reg Clr, Clk;

//   wire [31:0] out_DataMemory;
//   wire [4:0] out_RD;
//   wire out_ID_RF_enable;
  
  //Instance 
  Register_PC PC(result, LE, Clr, Clk, Q);
  
  ROM rom(Q, I);
  
  Adder adder(Q, 8'b00000100, result);
  
  Pipeline_Register_IF_ID IF_ID(I, result, Clr, Clk, LE,
                                I23_0, output_NextPC, I19_16,
                                I3_0, I15_12, I31_28, I11_0,
                                I31_0);
  
  control_unit CU (I31_0, ALU_op, AM, B_instr, BL_instr, S, load_instr, RF_enable, size, RW, E);
  
  CU_mux_2x1 CU_mux (ALU_op, AM, B_instr, BL_instr, load_instr, RF_enable, size, RW, E, 4'b0, 					  2'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, CU_MUX_S);
//   initial begin
//     fi = $fopen("input.txt","r");
//     A = 7'b0;
    
//     while(!$feof(fi))begin
//       code = $fscanf(fi, "%b", data);
//       rom.Mem[A] = data;
//       A = A + 1;
//       end
//     $fclose(fi);
    
//     A = 0;
//     $display("  A | I        |                 Time");
//     end
  
//     initial begin
//       A = 0;
//       repeat(3) #1 A = A + 4;
//     end
  
//     initial begin
//       $monitor("%d | %h | ", A, I, $time);
//     end
    

endmodule
