`timescale 1ns / 1ps

module Execute #( // General Parameter
                parameter D_SIZE = 32,
                parameter A_SIZE = 10)
               ( // General
               input               clk,
               input               rst,
               // Input -> Rd2Ex
               input        [15:0] instr_ex,
               input  [D_SIZE-1:0] op1_ex,
               input  [D_SIZE-1:0] op2_ex,
               input         [2:0] dest_reg_ex,
               // Output -> Fetch
               output reg          jmp_sel,
               output reg          jmpr_sel,
               output [A_SIZE-1:0] jmp,
               output [A_SIZE-1:0] jmp_offset,
               // Output -> Ex2WB
               output [D_SIZE-1:0] result,
               output        [2:0] dest_reg,
               output reg          reg_we_en,
               // Output -> Memory
               output reg          mem_re,
               output reg          mem_we,
               output [A_SIZE-1:0] addr_mem,
               output [D_SIZE-1:0] dout_mem
               );
    
    // Regs
    reg        [2:0] dest_reg_reg;
    reg [D_SIZE-1:0] result_reg;
    reg [A_SIZE-1:0] jmp_reg;
    reg [A_SIZE-1:0] jmp_offset_reg;
    reg [D_SIZE-1:0] addr_mem_reg;
    reg [D_SIZE-1:0] dout_mem_reg;
    
    //Assign 
    assign dest_reg   = dest_reg_reg;
    assign result     = result_reg;
    assign jmp        = jmp_reg;
    assign jmp_offset = jmp_offset_reg;
    assign addr_mem   = addr_mem_reg;
    assign dout_mem   = dout_mem_reg;
    
    always @(*)
    begin
        if(~rst)
        begin
            result_reg     <= 0;
            dest_reg_reg   <= 0;
            reg_we_en      <= 0;
            jmp_sel        <= 0;
            jmpr_sel       <= 0;
            jmp_reg        <= 0;
            jmp_offset_reg <= 0;
            mem_re         <= 0;
            mem_we         <= 0;
            addr_mem_reg   <= 0;
            dout_mem_reg   <= 0;
        end
        else
        begin
            dest_reg_reg <= dest_reg_ex;
            case(instr_ex[15:14])
                2'b11:
                begin
                    reg_we_en      <= 1;
                    jmp_sel        <= 0;
                    jmpr_sel       <= 0;
                    case(instr_ex[15:9])
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
                2'b01:
                begin
                    case(instr_ex[15:12])  
                        `JMP:
                        begin
                            jmp_sel  <= 1;
                            jmpr_sel <= 0;
                            jmp_reg  <= op2_ex[(A_SIZE-1):0];
                        end
                        `JMPR:
                        begin
                            jmp_sel  <= 0;
                            jmpr_sel <= 1;
                            jmp_offset_reg  <= {{(A_SIZE-6){instr_ex[5]}}, instr_ex[5:0]};
                        end
                        `JMPcond:
                        begin
                            jmpr_sel <= 0;
                            jmp_reg  <= op2_ex[(A_SIZE-1):0];
                            case(instr_ex[11:9])
                            `N:
                            begin
                                jmp_sel <= (op1_ex < 0)? 1 : 0; 
                            end
                            `NN:
                            begin
                                jmp_sel <= (op1_ex >= 0)? 1 : 0; 
                            end
                            `Z:
                            begin
                                jmp_sel <= (op1_ex == 0)? 1 : 0; 
                            end
                            `NZ:
                            begin
                                jmp_sel <= (op1_ex != 0)? 1 : 0; 
                            end
                            endcase
                        end
                        `JMPRcond:
                        begin
                            jmp_sel <= 0;
                            jmp_offset_reg  <= {{(A_SIZE-6){instr_ex[5]}}, instr_ex[5:0]};
                            case(instr_ex[11:9])
                            `N:
                            begin
                                jmpr_sel <= (op1_ex < 0)? 1 : 0; 
                            end
                            `NN:
                            begin
                                jmpr_sel <= (op1_ex >= 0)? 1 : 0; 
                            end
                            `Z:
                            begin
                                jmpr_sel <= (op1_ex == 0)? 1 : 0; 
                            end
                            `NZ:
                            begin
                                jmpr_sel <= (op1_ex != 0)? 1 : 0; 
                            end
                            endcase
                        end
                    endcase //for JUMPS instr.
                
                end
                2'b10:
                begin
                    jmp_sel  <= 0;
                    jmpr_sel <= 0;
               
                    case(instr_ex[15:11])
                        `STORE:
                        begin
                            reg_we_en    <= 0;
                            mem_we       <= 1;
                            mem_re       <= 0;
                            addr_mem_reg <= op1_ex[(A_SIZE-1):0];
                            dout_mem_reg <= op2_ex;
                        end
                        `LOAD:
                        begin
                            reg_we_en    <= 1;
                            mem_we       <= 0;
                            mem_re       <= 1;
                            addr_mem_reg <= op1_ex[(A_SIZE-1):0];
                        end
                        `LOADC:
                        begin
                            reg_we_en    <= 1;
                            result_reg   <= {op1_ex[31:8],instr_ex[7:0]};
                        end
                    endcase
                  end
            endcase //endcase for instructions
        end
    end

endmodule
