import ex_type_pkg::* ;

module alu_m
#(
  parameter int unsigned W = 1 // Width
 )
 ( 
  input  logic [W-1:0] data    , // data input
  input  logic [W-1:0] accum    , // accum input
  input  logic [2:0] opcode    , // opcode input
  input  logic         clk,    // clock
  
  output logic [W-1:0] out    , // register data output
  output logic zero    
  
 ) ;

  timeunit        1ns ;
  timeprecision 100ps ;
  
  always_comb if(accum == 0) zero <= 1'b1; else zero <= 1'b0;
  
  always_ff@(negedge clk) begin
    posedge 
    case(opcode)
      
      HLT: out <= accum;
      SKZ: out <= accum;
      ADD: out <= data + accum;
      AND: out <= data & accum;
      XOR: out <= data ^ accum;
      LDA: out <= data;
      STO: out <= accum;
      JMP: out <= accum;
      
    endcase
  end

endmodule : alu_m
