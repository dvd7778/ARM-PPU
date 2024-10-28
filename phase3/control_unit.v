// Control unit
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
      end
        
      //  BL and B
      3'b101: begin
        B_instr = 1;
        BL_instr = instr[24]; 
      end
    endcase
  end
endmodule