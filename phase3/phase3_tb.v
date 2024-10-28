module PF3_ControlUnit_tb;
  
  //Register_PC
  reg LE, Clr, Clk;
  wire [7:0] Q;
  
   //ROM
  integer fi, code;
  reg [7:0]Address;
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
  reg CU_MUX_E;
  wire [3:0] CU_MUX_out_ALU_op;
  wire [1:0] CU_MUX_out_AM;
  wire CU_MUX_out_B_instr, CU_MUX_out_BL_instr, CU_MUX_out_S, CU_MUX_out_load_instr, CU_MUX_out_RF_enable, CU_MUX_out_size, CU_MUX_out_RW, CU_MUX_out_E;
  
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
  
  //Pipeline Register ID/EX
  wire [7:0] EX_next_pc_out;
  wire [31:0] EX_PA_out;
  wire [31:0] EX_PB_out;
  wire [31:0] EX_PD_out;
  wire [3:0] EX_RD_out;
  wire [11:0] EX_immediate_out;
  wire [3:0] EX_ALU_op;
  wire [1:0] EX_AM;
  wire EX_S;
  wire EX_load_instr;
  wire EX_RF_enable;
  wire EX_size;
  wire EX_RW;
  wire EX_E;
  
  //Pipeline Register EX/MEM
  wire [31:0] Data_Mem_Out;
  wire [31:0] Data_Mem_Add_Out;
  wire [3:0] RD_Out;
  wire MEM_load_instr;
  wire MEM_RF_enable;
  wire MEM_Size;
  wire MEM_RW;
  wire MEM_E;
  
  
  //Pipeline Register MEM/WB
  wire [31:0] out_DataMemory;
  wire [3:0] out_WB_RD;
  wire out_ID_RF_enable;
  
  //Instance 
  Register_PC PC(result, LE, Clr, Clk, Q);
  
  ROM rom(Q, I);
  
  Adder adder(Q, 8'b00000100, result);
  
  Pipeline_Register_IF_ID IF_ID(I, result, Clr, Clk, LE,
                                I23_0, output_NextPC, I19_16,
                                I3_0, I15_12, I31_28, I11_0,
                                I31_0);
  
  control_unit CU (I31_0, ALU_op, AM, B_instr, BL_instr, S, load_instr, RF_enable, size, RW, E);
 
  CU_mux_2x1 CU_mux (ALU_op, AM, B_instr, BL_instr, S, load_instr, RF_enable, size, RW, E, 4'b0, 2'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, CU_MUX_E, CU_MUX_out_ALU_op, CU_MUX_out_AM, CU_MUX_out_B_instr, CU_MUX_out_BL_instr, CU_MUX_out_S, CU_MUX_out_load_instr, CU_MUX_out_RF_enable, CU_MUX_out_size, CU_MUX_out_RW, CU_MUX_out_E);
  
  Pipeline_register_ID_EX ID_EX(Clr, Clk, output_NextPC, 32'b0, 32'b0, 32'b0, 4'b0, 12'b0, CU_MUX_out_ALU_op, CU_MUX_out_AM, CU_MUX_out_S, CU_MUX_out_load_instr, CU_MUX_out_RF_enable, CU_MUX_out_size, CU_MUX_out_RW, CU_MUX_out_E, EX_next_pc_out, EX_PA_out, EX_PB_out, EX_PD_out, EX_RD_out, EX_immediate_out, EX_ALU_op, EX_AM, EX_S, EX_load_instr, EX_RF_enable, EX_size, EX_RW, EX_E);
  
  Pipeline_Register_EX_MEM EX_MEM (32'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, EX_RD_out, EX_load_instr, EX_RF_enable, EX_size, EX_RW, EX_E, Clr, Clk, Data_Mem_Out, Data_Mem_Add_Out, RD_Out, MEM_load_instr, MEM_RF_enable, MEM_Size, MEM_RW, MEM_E);
  
  Pipeline_Register_MEM_WB MEM_WB (32'b0, EX_RD_out, EX_RF_enable, Clr, Clk, out_DataMemory, out_WB_RD, out_ID_RF_enable);
  
  initial begin
    fi = $fopen("input.txt","r");
    
    Address = 8'b0;
    while(!$feof(fi)) begin
      code = $fscanf(fi, "%b", data);
      rom.Mem[Address] = data;
      Address = Address + 1;
    end
    $fclose(fi);
    
    $display("CLK|Keyword| PC|opcode|am|b|bl|s|load|rf_e|size|rw|e|EX_opcode|EX_am|EX_s|EX_load|EX_rf_e|EX_size|EX_rw|EX_e|MEM_load|MEM_rf_e|MEM_size|MEM_rw|MEM_e|WB_rf_e        		Time");
  end
  
  reg [8*6-1:0] keyword;
  
  
  always @(posedge Clk) begin
    if (BL_instr)
      keyword = "BL";
    else if (B_instr)
      keyword = "B";
    else if (load_instr) begin
      if (I31_0[22])
      	keyword = "LDRB";
      else
        keyword = "LDR";
    end
    else if (E == 1) begin
      if (I31_0[22])
      	keyword = "STRB";
      else
        keyword = "STR";
    end
    else begin
      case (I31_0[24:21])
        4'b0000:
          keyword = "AND";
        4'b0001:
          keyword = "EOR";
        4'b0010:
          keyword = "SUB";
        4'b0011:
          keyword = "RSB";
        4'b0100:
          keyword = "ADD";
        4'b0101:
          keyword = "ADC";
        4'b0110:
          keyword = "SBC";
        4'b0111:
          keyword = "RSC";
        4'b1000:
          keyword = "TST";
        4'b1001:
          keyword = "TEQ";
        4'b1010:
          keyword = "CMP";
        4'b1011:
          keyword = "CMN";
        4'b1100:
          keyword = "ORR";
        4'b1101:
          keyword = "MOV";
        4'b1110:
          keyword = "BIC";
        4'b1111:
          keyword = "MVN";
      endcase
    end
    
    case (I31_0[31:28])
      4'b0000:
        keyword = {keyword, "EQ"};
      4'b0001:
        keyword = {keyword, "NE"};
      4'b0010:
        keyword = {keyword, "CS"};
      4'b0011:
        keyword = {keyword, "CC"};
      4'b0100:
        keyword = {keyword, "MI"};
      4'b0101:
        keyword = {keyword, "PL"};
      4'b0110:
        keyword = {keyword, "VS"};
      4'b0111:
        keyword = {keyword, "VC"};
      4'b1000:
        keyword = {keyword, "HI"};
      4'b1001:
        keyword = {keyword, "LS"};
      4'b1010:
        keyword = {keyword, "GE"};
      4'b1011:
        keyword = {keyword, "LT"};
      4'b1100:
        keyword = {keyword, "GT"};
      4'b1101:
        keyword = {keyword, "LE"};
    endcase
    
    if (S)
      keyword = {keyword, "S"};
    
    if (CU_MUX_E == 1 || I31_0[31:0] == 32'b0)
      keyword = "NOP";
  end
  
  
  initial #40 $finish;

  initial fork
    Clk = 0;
    Clr = 1;
    LE = 1;
    CU_MUX_E = 0;
    
    repeat (20) #2 Clk = ~Clk;
    #3 Clr = 0;
    #32 CU_MUX_E = 1;
  join

    initial begin
      $monitor("%b    %s %d   %b %b %b  %b %b    %b    %b    %b  %b %b      %b    %b    %b       %b       %b       %b     %b    %b        %b        %b        %b      %b     %b       %b    %d", Clk, keyword, Q, ALU_op, AM, B_instr, BL_instr, S, load_instr, RF_enable, size, RW, E, EX_ALU_op, EX_AM, EX_S, EX_load_instr, EX_RF_enable, EX_size, EX_RW, EX_E, MEM_load_instr, MEM_RF_enable, MEM_Size, MEM_RW, MEM_E, out_ID_RF_enable, $time);
    end

endmodule
