
`timescale 1ns / 1ps

module data_forwarding #(// General Parameters
                         parameter D_SIZE = 32,
                         parameter A_SIZE = 10)
                         (// General 
                         input               clk,
                         input               rst,    
                         // Input <- Read
                         input         [2:0] addr_op1_rd2ex,
                         input         [2:0] addr_op2_rd2ex, 
                         input         [2:0] dest_rd2ex,
                         input               reg_re_en,
                         // Input <- Ex2Wb 
                         input         [2:0] dest_reg_wb,
                         input               reg_we_wb,
                         input               loadc_en,
                         input               mem_re_en,
                         // Output -> READ
                         output              clear,
                         output              freeze, 
                         output                df1,
                         output                df2
                         //output                df_dest
                         );
    
    //
    reg df1_reg;
    reg df2_reg;
    reg clear_reg;
    reg freeze_reg;
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
            clear_reg   <= 0;
            freeze_reg  <= 0;
        end
        else if ((reg_we_wb == 1) && (reg_re_en == 1))
            begin
                df1_reg <= (addr_op1_rd2ex == dest_reg_wb)? 1 : 0;  
                df2_reg <= (addr_op2_rd2ex == dest_reg_wb)? 1 : 0;  
            end
        else if (((loadc_en == 1) && (mem_re_en == 1))/*&&((addr_op1_rd2ex == dest_reg_wb)||(addr_op2_rd2ex == dest_reg_wb))*/)
        begin
            clear_reg  <= 1;
            freeze_reg <= 1;
        end
   end             
endmodule
