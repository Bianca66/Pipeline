`timescale 1ns / 1ps

module execute #( // General Parameter
                parameter D_SIZE = 32,
                parameter A_SIZE = 10)
               ( // General
               input              clk,
               input              rst,
               // Input -> Rd2Ex
               //     - control signals
               input              alu_en_ex,
               //input            shift_en_ex,
               input              reg_we_ex,
               input              mem_we_ex,
               input              mem_re_ex,
               input              loadc_en_ex,
               input              jmp_sel_ex,
               input              jmpr_sel_ex,
               //     - operands
               input [A_SIZE-1:0] jmp_offset_ex,
               input [D_SIZE-1:0] op1_ex,
               input [D_SIZE-1:0] op2_ex,
               input        [6:0] alu_cmd_ex,
               input        [2:0] dest_reg_ex,
               // Ouput -> Jump Control
               output              jmp_sel,
               output              jmpr_sel,
               output [A_SIZE-1:0] jmp,
               output [A_SIZE-1:0] jmp_offset,
               // Output -> Memory
               output              mem_re,
               output              mem_we,
               output [A_SIZE-1:0] addr_mem,
               output [D_SIZE-1:0] dout_mem,
               // Output -> Write Back
               output              reg_we,
               output              load_en,
               output [D_SIZE-1:0] result,
               output        [2:0] dest_reg,
               // Output 
               output              clear
               );
    
    //Regs;
    reg [D_SIZE-1:0] result_reg;
    //
    reg              clear_reg;
    reg [A_SIZE-1:0] jmp_reg;
    reg [A_SIZE-1:0] jmp_offset_reg;
    
    // Output -> Jump Control           
    assign jmp_sel    = jmp_sel_ex;
    assign jmpr_sel   = jmpr_sel_ex;
    assign jmp        = jmp_reg;
    assign jmp_offset = jmp_offset_reg;
    
    // Output -> Memory
    assign mem_re   = mem_re_ex;
    assign mem_we   = mem_we_ex;
    assign addr_mem = op1_ex[(A_SIZE-1):0];
    assign dout_mem = op2_ex;
    
    // Output -> Write Back
    assign reg_we   = reg_we_ex;
    assign load_en  = mem_re_ex;
    assign dest_reg = dest_reg_ex;
    assign result   = result_reg;
    //
    assign clear = clear_reg;
    //
    
    always @(*)
    begin
        if(~rst)
        begin
            result_reg     <= 0;
            clear_reg      <= 0;
            jmp_reg        <= 0;
        end
        else
        begin 
            if(jmp_sel_ex || jmpr_sel_ex)
            begin   
                clear_reg      <= 1;
                jmp_reg        <= op2_ex[(A_SIZE-1):0];
                jmp_offset_reg <= jmp_offset_ex;
            end
            else if (alu_en_ex)
            begin
                case(alu_cmd_ex)
                    `ADD:  
                    begin
                        result_reg <= op1_ex + op2_ex;
                    end
                    `ADDF:
                    begin
                        result_reg <= op1_ex + op2_ex;
                    end
                    `SUB:
                    begin
                        result_reg <= op1_ex - op2_ex;
                    end
                    `SUBF:
                    begin
                        result_reg <= op1_ex - op2_ex;
                    end
                    `AND:
                    begin
                        result_reg <= op1_ex & op2_ex;
                    end
                    `OR:
                    begin
                        result_reg <= op1_ex | op2_ex;
                    end
                    `XOR:
                    begin
                        result_reg <= op1_ex ^ op2_ex;
                    end
                    `NAND:
                    begin
                        result_reg <= ~(op1_ex & op2_ex);
                    end
                    `NOR:
                    begin
                        result_reg <= ~(op1_ex | op2_ex);
                    end
                    `NXOR:
                    begin
                        result_reg <= ~(op1_ex ^ op2_ex);
                    end
                    `SHIFTR:
                    begin
                        result_reg <= op1_ex >> op2_ex;
                    end
                    `SHIFTRA:
                    begin
                        result_reg <= op1_ex >>> op2_ex;
                    end
                    `SHIFTL:
                    begin
                        result_reg <= op1_ex << op2_ex;
                    end
                endcase //endcase for alu op
            end
            else if(loadc_en_ex)
            begin
                result_reg <= op1_ex;
            end
        end
    end

endmodule
