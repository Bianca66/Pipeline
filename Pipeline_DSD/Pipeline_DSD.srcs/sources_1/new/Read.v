`timescale 1ns / 1ps

module Read #(// General Parameters
               parameter D_SIZE = 32,
               parameter A_SIZE = 10)
              (// General
               input               clk,
               input               rst,
               // Input <- Instr Reg
               input        [15:0] instr_rd,
               // Input <- Reg Set
               input  [D_SIZE-1:0] op1_rs,
               input  [D_SIZE-1:0] op2_rs,
               // Input <- DataForwarding
               input               df1,
               input               df2,
               // Input <- Execute
               input [D_SIZE-1:0] result_ex,
               // Output -> Reg Set
               output        [2:0] addr_op1,
               output        [2:0] addr_op2,
               output reg          reg_re_rs,
               // Output -> Rd2Ex 
               output       [15:0] instr_rd2ex,
               output        [2:0] dest_reg,
               output [D_SIZE-1:0] op1,
               output [D_SIZE-1:0] op2
               //
              );
    //Regs
    reg        [2:0] addr_op1_reg;
    reg        [2:0] addr_op2_reg;
    reg        [2:0] dest_reg_reg;
    //
    reg [D_SIZE-1:0] op1_reg;
    reg [D_SIZE-1:0] op2_reg;     
    
    //Assign
    assign addr_op1 = addr_op1_reg;
    assign addr_op2 = addr_op2_reg;
    assign      op1 = op1_reg;
    assign      op2 = op2_reg;
    assign dest_reg = dest_reg_reg;
    //
    assign instr_rd2ex = instr_rd;
    
    always @(*)
    begin
        if(~rst)
        begin
            addr_op1_reg <= 0;
            addr_op2_reg <= 0;
            dest_reg_reg <= 0;
            op1_reg      <= 0;
            op2_reg      <= 0;
            reg_re_rs    <= 0;
        end
        else
        begin
            case(instr_rd[15:14])
                2'b11:
                begin
                    case(instr_rd[15:9])
                        `NOP:
                        begin
                            reg_re_rs    <= 0;
                        end
                        `SHIFTR, `SHIFTRA, `SHIFTL:
                        begin
                            addr_op1_reg <= instr_rd[8:6];
                            dest_reg_reg <= instr_rd[8:6];
                            op1_reg      <= (df1)? result_ex : op1_rs;
                            op2_reg      <= (df2)? result_ex : {{(D_SIZE-6){instr_rd[5]}}, instr_rd[5:0]};
                            reg_re_rs    <= 1;
                        end
                        default:
                        begin
                            addr_op1_reg <= instr_rd[5:3];
                            addr_op2_reg <= instr_rd[2:0];
                            dest_reg_reg <= instr_rd[8:6];
                            op1_reg      <= (df1)? result_ex : op1_rs;
                            op2_reg      <= (df2)? result_ex : op2_rs; 
                            reg_re_rs    <= 1;
                        end
                    endcase //endcase for AL, NOP, HALT instruction 
                end //end for class 1 instructions
                2'b01:
                begin
                    case(instr_rd[15:12])  
                        `JMP:
                        begin
                            addr_op2_reg <= instr_rd[2:0];
                            op2_reg      <= op2_rs;
                            reg_re_rs    <= 1;
                        end
                        `JMPcond:
                        begin
                            addr_op1_reg <= instr_rd[8:6];
                            addr_op2_reg <= instr_rd[2:0];
                            op1_reg      <= op1_rs;
                            op2_reg      <= op2_rs;
                            reg_re_rs    <= 1;
                        end
                        `JMPRcond:
                        begin
                            addr_op1_reg <= instr_rd[8:6];
                            op1_reg      <= op1_rs;
                            reg_re_rs    <= 1;
                        end
                    endcase //for JUMPS instr.
                end
                2'b10:
                begin
                    case(instr_rd[15:11])
                        `STORE:
                        begin
                            addr_op1_reg <= instr_rd[10:8];
                            addr_op2_reg <= instr_rd[ 2:0];
                            op1_reg      <= op1_rs;
                            op2_reg      <= op2_rs;
                            reg_re_rs    <= 1;
                        end
                        `LOAD:
                        begin
                            dest_reg_reg <= instr_rd[10:8];
                            addr_op2_reg <= instr_rd[ 2:0];
                            op2_reg      <= op2_rs;
                            reg_re_rs    <= 1;
                        end
                        `LOADC:
                        begin
                            dest_reg_reg <= instr_rd[10:8]; 
                            addr_op1_reg <= instr_rd[10:8];
                            reg_re_rs    <= 1;
                        end
                    endcase //endcase LOAD, LOADC, STORE
                end 
            endcase //endcase for instructions
        end
    end
    
endmodule