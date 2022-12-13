import ex_type_pkg::* ;
typedef enum logic [2:0] {HLT, SKZ, ADD, AND, XOR, LDA, STO, JMP} opcode_e;
module control_m( 
  
  input  logic    [2:0]opcode  , // opcode
  input  logic         zero  , // zero
  input  logic         rst_ , // reset (asynch low)
  input  logic         clk  , // clock
  input  logic         clk2  , // clock2
  input  logic         fetch ,  // fetch
  
  output reg load_ac,
  output reg mem_rd,
  output reg mem_wr,
  output reg inc_pc,
  output reg load_pc,
  output reg load_ir,
  output reg halt
 ) ;

  timeunit        1ns ;
  timeprecision 100ps ;
  
  logic [2:0]phase;
  logic [2:0]next_phase;

  
  
  always_ff@(clk, negedge rst_)begin
  
    if(rst_ == 1'b0) phase <= 0; else if (clk2 && fetch || phase != 3'd0) phase <= next_phase;
  end
  
  always_comb begin
    
    case(phase)
      
      3'd0: begin
        
        load_ac = 1'b0;
        mem_rd = 1'b0;
        mem_wr = 1'b0;
        inc_pc = 1'b0;
        load_pc = 1'b0;
        load_ir = 1'b0;
        halt = 1'b0;
        next_phase = 3'd1;
        
      end
      
      3'd1: begin
        
        load_ac = 1'b0;
        mem_rd = 1'b1;
        mem_wr = 1'b0;
        inc_pc = 1'b0;
        load_pc = 1'b0;
        load_ir = 1'b0;
        halt = 1'b0;
        next_phase = 3'd2;
        
      end
      
      3'd2: begin
        
        load_ac = 1'b0;
        mem_rd = 1'b1;
        mem_wr = 1'b0;
        inc_pc = 1'b0;
        load_pc = 1'b0;
        load_ir = 1'b1;
        halt = 1'b0;
        next_phase = 3'd3;
        
      end
      
      3'd3: begin
        
        load_ac = 1'b0;
        mem_rd = 1'b1;
        mem_wr = 1'b0;
        inc_pc = 1'b0;
        load_pc = 1'b0;
        load_ir = 1'b1;
        halt = 1'b0;
        next_phase = 3'd4;
        
      end
      
      3'd4: begin
        
        load_ac = 1'b0;
        mem_rd = 1'b0;
        mem_wr = 1'b0;
        inc_pc = 1'b1;
        load_pc = 1'b0;
        load_ir = 1'b0;
        halt = (opcode == HLT);
        next_phase = 3'd5;
        
      end
      
      3'd5: begin
        
        load_ac = 1'b0;
        mem_rd = (opcode == ADD || opcode == AND
        || opcode == XOR || opcode == LDA);
        mem_wr = 1'b0;
        inc_pc = 1'b0;
        load_pc = 1'b0;
        load_ir = 1'b0;
        halt = 1'b0;
        next_phase = 3'd6;
        
      end
      
      3'd6: begin
        
        load_ac = (opcode == ADD || opcode == AND
        || opcode == XOR || opcode == LDA);
        mem_rd = (opcode == ADD || opcode == AND
        || opcode == XOR || opcode == LDA);
        mem_wr = 1'b0;
        inc_pc = ((opcode == SKZ) && (zero == 1));
        load_pc = (opcode == JMP);
        load_ir = 1'b0;
        halt = 1'b0;
        next_phase = 3'd7;
        
      end
      
      3'd7: begin
        
        load_ac = (opcode == ADD || opcode == AND
        || opcode == XOR || opcode == LDA);
        mem_rd = (opcode == ADD || opcode == AND
        || opcode == XOR || opcode == LDA);
        mem_wr = (opcode == STO);
        inc_pc = ((opcode == JMP) || ( ( (opcode == SKZ) && (zero == 1)) ));
        load_pc = (opcode == JMP);
        load_ir = 1'b0;
        halt = 1'b0;
        next_phase = 3'd0;
        
      end     
      
    endcase
    
  end

endmodule : control_m

