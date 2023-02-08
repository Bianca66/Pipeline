`timescale 1ns / 1ps

module DataForwarding #(// General Parameters
                         parameter D_SIZE = 32,
                         parameter A_SIZE = 10)
                         (// General 
                         input               clk,
                         input               rst,    
                         // Input <- Read
                         input         [2:0] addr_op1_rd2ex,
                         input         [2:0] addr_op2_rd2ex, 
                         input         [2:0] dest_rd2ex,
                         input  [A_SIZE-1:0] addr_mem,
                         input               reg_re,
                         // Input <- Ex2Wb 
                         input         [2:0] dest_reg_wb,
                         input               reg_we,
                         input               mem_we,
                         input               mem_re,
                         // Output -> READ
                         output                df1,
                         output                df2,
                         output reg            stall
                         );
    
    //
    reg df1_reg;
    reg df2_reg;
    reg stall_reg;
    
    //reg df_dest_reg;
    assign df1     = df1_reg;
    assign df2     = df2_reg;
    //assign df_dest = df_dest_reg;
    
    always @(*)
    begin
        if(~rst)
        begin
            df1_reg     <= 0;
            df2_reg     <= 0;
            stall       <= 0;
        end
        else 
        begin
            if ((reg_we == 1) && (reg_re == 1))
            begin
                df1_reg <= (addr_op1_rd2ex == dest_reg_wb)? 1 : 0;  
                df2_reg <= (addr_op2_rd2ex == dest_reg_wb)? 1 : 0;  
            end
            if((mem_re == 1)&&(reg_we == 1)&&((addr_op1_rd2ex == dest_reg_wb)||(addr_op2_rd2ex == dest_reg_wb)))
            begin
                stall <= 1;
            end
            else
                stall <= 0;
        end
   end             
endmodule
