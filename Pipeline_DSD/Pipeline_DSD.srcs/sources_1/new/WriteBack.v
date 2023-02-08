`timescale 1ns / 1ps

module WriteBack #(// General Parameters
                    parameter D_SIZE = 32,
                    parameter A_SIZE = 10)
                   (// General
                    input               clk,
                    input               rst,
                    // Input <- Ex2Wb
                    input  [D_SIZE-1:0] result,
                    input         [2:0] dest_reg,
                    input               reg_we_en,
                    input  [A_SIZE-1:0] addr,
                    input               mem_re, 
                    // Input <- Memory
                    input  [D_SIZE-1:0] data_in,
                    // Output -> Memory
                    output [A_SIZE-1:0] addr_mem,
                    output              mem_re_en,
                    // Output -> Register Set
                    output [D_SIZE-1:0] result_rs,
                    output        [2:0] dest_rs,
                    output              reg_we_rs
                   );
                   
    //Regs
    reg [D_SIZE-1:0] result_reg;
    reg [A_SIZE-1:0] addr_mem_reg;
    reg        [2:0] dest_rs_reg;
    reg              reg_we_rs_reg;   
    reg              mem_re_en_reg;   
    
    assign result_rs = result_reg;
    assign dest_rs   = dest_reg;
    assign reg_we_rs = reg_we_en;
    
    assign addr_mem = addr_mem_reg;
    assign mem_re_en = mem_re_en_reg;
    
    always @(*)
    begin
        if(~rst)
        begin
            result_reg    <= 0;
            dest_rs_reg   <= 0;
            reg_we_rs_reg <= 0;   
            addr_mem_reg  <= 0;
            mem_re_en_reg <= 0;
        end
        else
        begin
            result_reg    <= (mem_re)? data_in : result;
            dest_rs_reg   <= dest_reg;
            addr_mem_reg  <= addr;
            mem_re_en_reg <= mem_re;
        end
    end
    
endmodule
