// Pipeline ID/EX
module pipeline_register_ID_EX(
  input clr,
  input clk,
  input [3:0] ID_ALU_op,
  input [1:0] ID_AM,
  input ID_S,
  input ID_load_instr,
  input ID_RF_enable,
  input ID_size,
  input ID_RW,
  input ID_E,
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
