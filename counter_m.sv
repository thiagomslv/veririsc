module counter_m
#(
  parameter int unsigned W = 5 // Width
 )
 ( 
  output logic [W-1:0] count    , // register data output
  input  logic [W-1:0] data    , // data input
  
  input  logic         rst_ , // reset (asynch low)
  input  logic         clk,    // clock
  input  logic         load    // data
 ) ;

  timeunit        1ns ;
  timeprecision 100ps ;
  
  always_ff@(posedge clk, negedge rst_) begin
    
    if(rst_ == 1'b0) count <= 0;
    
    else if(load == 1'b1) count <= data; else count <= count + 1;
    
  end
  
endmodule : counter_m

