module memory_m
#(
  parameter int unsigned DWIDTH = 8, // Data Width
  parameter int unsigned AWIDTH = 5 // Width
  
 )
 ( 
  
  input  logic [AWIDTH-1:0] addr,
  inout  logic [DWIDTH-1:0] data,
  
  input  logic         read,
  input  logic         write 
  
 ) ;

  timeunit        1ns ;
  timeprecision 100ps ;
  
  logic [DWIDTH-1:0] mem [2**AWIDTH-1:0];
  
  assign data = (read == 1'b1) ?  mem[addr] : 'bz;
 
  always_ff@(posedge write) mem[addr] <= data;

endmodule : memory_m

