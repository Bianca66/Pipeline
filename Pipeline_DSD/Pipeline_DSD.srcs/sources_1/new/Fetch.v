`timescale 1ns / 1ps

module Fetch #(// General Parameters
               parameter D_SIZE = 32,
               parameter A_SIZE = 10)
              (// General
               input              clk,
               input              rst,
               // Input <- Jump Control
               input              jmp_sel,
               input              jmpr_sel,
               input [A_SIZE-1:0] jmp,
               input [A_SIZE-1:0] jmp_offset,
               // Input <- Control
               input              stall,
               // Output -> Program Memory
               output [A_SIZE-1:0] pc_out
              );
              
    reg [A_SIZE-1:0] pc_reg;
    
    assign pc_out = pc_reg;
    
    always @(posedge clk or negedge rst)
    begin
        if(~rst)    
        begin
            pc_reg <= 0;
        end
        
        else if(jmp_sel)
        begin
            pc_reg <= jmp;
        end
        
        else if(jmpr_sel)
        begin
            pc_reg <= pc_reg + jmp_offset;
        end
        
        else if (stall)
        begin
            pc_reg <= pc_reg;
        end
        
        else
        begin
            pc_reg <= pc_reg + 1;
        end
    end

endmodule