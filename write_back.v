`timescale 1ns / 1ps

module write_back #(// General Parameters
                    parameter D_SIZE = 32,
                    parameter A_SIZE = 10)
                   (// General
                    input               clk,
                    input               rst,
                    // Input <- Execute
                    input               reg_we_wb,
                    input               load_en_wb,
                    input  [D_SIZE-1:0] result_wb,
                    input         [2:0] dest_reg_wb,
                    // Input <- Memory 
                    input  [D_SIZE-1:0] data_in,
                    // Output -> Data Forwarding
                    output [D_SIZE-1:0] result_rs,
                    output        [2:0] dest_rs,
                    output              reg_we_rs
                   );
                   
    //Regs
    reg [D_SIZE-1:0] result_reg;
    reg        [2:0] dest_rs_reg;
    reg              reg_we_rs_reg;
    
    //Output -> Data Forwarding
    assign result_rs = result_reg;
    assign dest_rs   = dest_rs_reg;
    assign reg_we_rs = reg_we_rs_reg;
    
    always @(*)
    begin
        if(~rst)
        begin
            result_reg    <= 0;
            dest_rs_reg   <= 0;
            reg_we_rs_reg <= 0;
        end 
        else
        begin
            result_reg    <= (load_en_wb)? data_in : result_wb;
            dest_rs_reg   <= dest_reg_wb;
            reg_we_rs_reg <= reg_we_wb;
        end
    end
    
endmodule
