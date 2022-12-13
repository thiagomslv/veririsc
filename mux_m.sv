module mux_m
#(
  parameter int unsigned W = 1 // Width
)
(
  input logic [W-1:0] data_a,
  input logic [W-1:0] data_b,
  input logic sel_a,
  output logic [W-1:0] out
  
);

timeunit        1ns ;
timeprecision 100ps ;

always_comb if(sel_a == 1) out = data_a; else out = data_b;


endmodule : mux_m  