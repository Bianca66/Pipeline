`timescale 1ns / 1ps

module fetch #(// General Parameters
               parameter D_SIZE = 32,
               parameter A_SIZE = 10)
              (// General
               input              clk,
               input              rst,
               // Imputs <- Program Memory
               //input       [15:0] instruction,
               // Input <- Jump Control
               input              jmp_sel,
               input              jmpr_sel,
               input [A_SIZE-1:0] jmp,
               input [A_SIZE-1:0] jmp_offset,
               // Input <- Data Forwarding
               input              freeze,
               // Input <- Read
               input              en_write_pc,
               // Output -> Program Memory
               output [A_SIZE-1:0] pc_out
               // Output -> Read
               //output      [15:0] instr_ir
              );

    // Program Counter reg
    reg [A_SIZE-1:0] pc;
    
    // Regs
    //reg       [15:0] instr_reg; 
   
    //
    assign   pc_out = pc;
    //assign instr_ir = instr_reg;
    
    always @(posedge clk or negedge rst)
    begin
        if (~rst)
        begin
            pc        <= 0;
        end
        /*else if (freeze)
        begin
            pc        <= pc;
        end
        */
        else
        begin
            if (en_write_pc)
            begin
                if(jmpr_sel)
                begin
                    pc <= pc + jmp_offset;
                end
                else if(jmp_sel)
                begin
                    pc <= jmp;
                end
                else
                    pc <= pc + 1;
            end
            else if (~en_write_pc)
            begin
                pc <= pc;
                //instr_reg = {`NOP,    9'b000000000};
            end
            else if (freeze)
                pc <= pc;
         end
    end
    
endmodule