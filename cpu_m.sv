import ex_type_pkg::*;
module cpu_m
#(
  parameter int unsigned DW = 1 , // data width
  parameter int unsigned AW = 1   // address width
 )
 (
  output logic halt  , // cpu halt
  input  logic rst_  , // cpu_test reset (asynch low)
  input  logic clk   , // clockgen clock
  input  logic clk2  , // clockgen clock / 2
  input  logic fetch   // clockgen clock / 4
 ) ;

  timeunit        1ns ;
  timeprecision 100ps ;

  wire  [DW-1:0]    data    ; // bidirectional bus
  logic [DW-1:0]    alu_out ; // alu to bus driver and accumulator
  logic [DW-1:0]    accum   ; // accumulator to alu
  logic [AW-1:0]    pc_addr ; // program counter to mux
  logic [DW-1:0]    ir_out  ; // instruction register to alu, pc, mux
  opcode_e opcode  ; // instruction register bits (high bits)
  logic [AW-1:0]    ir_addr ; // instruction register bits (low  bits)
  logic [AW-1:0]    addr    ; // mux to memory
  logic             zero    ; // alu to control
  logic             load_ac ; // control to accumulator
  logic             mem_rd  ; // control to memory
  logic             mem_wr  ; // control to memory
  logic             inc_pc  ; // control to program counter
  logic             load_pc ; // control to program counter
  logic             load_ir ; // control to instruction register
  logic             alu_clk ; // glue logic = clk | clk2 | fetch
  logic             enable  ; // bus driver enable

  assign opcode  = opcode_e '(ir_out[7:5]) ;
  assign ir_addr = ir_out[4:0] ;

  register_m #(DW) accumulator
  (
    .q   (accum  ),
    .d   (alu_out),
    .clk          ,
    .enb (load_ac),
    .rst_
  ) ;

  register_m #(DW) instruction_register
  (
    .q   (ir_out)  ,
    .d   (data)    ,
    .clk           ,
    .enb (load_ir) ,
    .rst_
  ) ;

  counter_m #(AW) program_counter
  (
    .count (pc_addr) ,
    .data  (ir_addr) ,
    .clk   (inc_pc)  ,
    .load  (load_pc) ,
    .rst_
  ) ;

  // clk     _-_-_-_-_-_-_-_-
  // clk2    --__--__--__--__
  // fetch   ----____----____
  // phase   0123456701234567
  // alu_clk ------_-------_-

  nand (alu_clk, ~clk, ~clk2, ~fetch);

  alu_m #(DW) alu
  (
    .out (alu_out) ,
    .zero          ,
    .clk (alu_clk) ,
    .accum         ,
    .data          ,
    .opcode
  ) ;

  // clk      : _-_-_-_-_-_-_-_-
  // clk2     : --__--__--__--__
  // fetch    : ----____----____
  // phase    : 0123456701234567
  // mem_rd     _---_???_---_??? (if alu operation)
  // data_en_ : ------??------?? (if not alu operation)

  nand (data_en_, ~fetch, ~mem_rd, ~clk2);
  bufif0 driver_[DW-1:0] (data, alu_out, data_en_);

  mux_m #(AW) mux // select pc during fetch
  (
    .out    (addr),
    .data_a (pc_addr),
    .data_b (ir_addr),
    .sel_a  (fetch) 
  ) ;

  memory_m #(DW,AW) memory
  (
    .data          ,
    .addr          ,
    .read  (mem_rd),
    .write (mem_wr) 
  ) ;

  control_m control
  (
    .load_ac ,
    .mem_rd  ,
    .mem_wr  ,
    .inc_pc  ,
    .load_pc ,
    .load_ir ,
    .halt    ,
    .opcode  ,
    .zero    ,
    .rst_    ,
    .clk     ,
    .clk2    ,
    .fetch    
  ) ;

endmodule : cpu_m
