`timescale 1ns / 1ps
`include "opcode.v"
module read #(// General Parameters
               parameter D_SIZE = 32,
               parameter A_SIZE = 10)
              (// General
              input              clk,
              input              rst,
              // Input <- Instruction Register
              input       [15:0] instr_rd,
              // Input Reg Set
              input [D_SIZE-1:0] op1_rs,
              input [D_SIZE-1:0] op2_rs,
              // Input <- Data Forwarding + Jump Control
              input        clear,
              // Input <- Data Forwarding
              input        freeze,
              input        df1,
              input        df2,
              // Input <- Execute
              input [D_SIZE-1:0] result_ex,
              // Output -> Fetch
              output       en_write_pc,
              // Output -> Data Forwarding
              output [2:0] addr_op1,
              output [2:0] addr_op2,
              output       reg_we_en,
              output       reg_re_en,
              // Output -> Execute
              //  - control signals
              output       alu_en,
              //output       shift_en,
              output       mem_re,
              output       mem_we,
              output       loadc_en,
              output       jmp_sel,
              output       jmpr_sel,
              //  -operands
              output [A_SIZE-1:0] jmp_offset,
              output [D_SIZE-1:0] op1,
              output [D_SIZE-1:0] op2,
              //  - destination
              output        [2:0] dest_reg,
              //  -alu_operation
              output        [6:0] alu_cmd
              );

    reg       en_write_pc_reg;
    // Output -> Data Forwarding
    reg [2:0] addr_op1_reg;
    reg [2:0] addr_op2_reg;
    reg       reg_we_en_reg;
    reg       reg_re_en_reg;
    // Output -> Execute
    //  - control signals
    reg       alu_en_reg;
    reg       mem_re_reg;
    reg       mem_we_reg;
    reg       loadc_en_reg;
    reg       jmp_sel_reg;
    reg       jmpr_sel_reg;
    //  -operands
    reg [A_SIZE-1:0] jmp_offset_reg; 
    reg [D_SIZE-1:0] op1_reg;
    reg [D_SIZE-1:0] op2_reg;
    //  - destination
    reg        [2:0] dest_reg_reg;
    //  -alu_operation
    reg        [6:0] alu_cmd_reg;
    
    // Output -> FETCH
    assign en_write_pc = en_write_pc_reg;
    // Output -> Data Forwarding
    assign  addr_op1 = addr_op1_reg;
    assign  addr_op2 = addr_op2_reg;
    assign reg_we_en = reg_we_en_reg;
    assign reg_re_en = reg_re_en_reg;
    // Output -> Execute
    //  - control signals
    assign   alu_en = alu_en_reg;
    //assign shift_en = shift_en_reg;
    assign   mem_re = mem_re_reg;
    assign   mem_we = mem_we_reg;
    assign loadc_en = loadc_en_reg;
    assign  jmp_sel = jmp_sel_reg;
    assign jmpr_sel = jmpr_sel_reg;
    //  -operands
    assign jmp_offset = jmp_offset_reg; 
    assign        op1 = op1_reg;
    assign        op2 = op2_reg;
    //  - destination
    assign   dest_reg = dest_reg_reg;
    //  -alu_operation
    assign    alu_cmd = alu_cmd_reg;
    
    always @(*)
    begin
        if(~rst)
        begin
            en_write_pc_reg <= 1;
            // Output -> Data Forwarding
            addr_op1_reg    <= 0;
            addr_op2_reg    <= 0;
            reg_we_en_reg   <= 0;
            reg_re_en_reg   <= 0;
            // Output -> Execute
            //  - control signals
            alu_en_reg      <= 0;
            mem_re_reg      <= 0;
            mem_we_reg      <= 0;
            loadc_en_reg    <= 0;
            jmp_sel_reg     <= 0;
            jmpr_sel_reg    <= 0;
            //  -operands
            jmp_offset_reg  <= 0;
            op1_reg         <= 0;
            op2_reg         <= 0;
            //  - destination
            dest_reg_reg    <= 0;
            //  -alu_operation
            alu_cmd_reg     <= 0;

        end
        else if(clear)
        begin
            en_write_pc_reg <= 1;
            // Output -> Data Forwarding
            addr_op1_reg    <= 0;
            addr_op2_reg    <= 0;
            reg_we_en_reg   <= 0;
            reg_re_en_reg   <= 0;
            // Output -> Execute
            //  - control signals
            alu_en_reg      <= 0;
            mem_re_reg      <= 0;
            mem_we_reg      <= 0;
            loadc_en_reg    <= 0;
            jmp_sel_reg     <= 0;
            jmpr_sel_reg    <= 0;
            //  -operands
            jmp_offset_reg  <= 0;
            op1_reg         <= 0;
            op2_reg         <= 0;
            //  - destination
            dest_reg_reg    <= 0;
            //  -alu_operation
            alu_cmd_reg     <= 0;

        end
        else
        begin
            case(instr_rd[15:14])
                2'b11:
                begin
                    mem_re_reg      <= 0;
                    mem_we_reg      <= 0;
                    loadc_en_reg    <= 0;
                    jmp_sel_reg     <= 0;
                    jmpr_sel_reg    <= 0;
                    case(instr_rd[15:9])
                        `NOP:
                        begin
                            en_write_pc_reg <= 1; 
                            reg_we_en_reg   <= 0;
                            reg_re_en_reg   <= 0;
                            alu_en_reg      <= 0;
                        end
                        `HALT:
                        begin
                            en_write_pc_reg <= 0; 
                            reg_we_en_reg   <= 0;
                            reg_re_en_reg   <= 0;
                            alu_en_reg      <= 0;
                        end
                        `SHIFTR, `SHIFTRA, `SHIFTL:
                        begin
                            // control signals
                            en_write_pc_reg <= 1; 
                            reg_we_en_reg   <= 1;
                            reg_re_en_reg   <= 1;
                            alu_en_reg      <= 1;
                            alu_cmd_reg     <= instr_rd[15:9];
                            // operands
                            dest_reg_reg    <= instr_rd[8:6];
                            addr_op1_reg    <= instr_rd[8:6];
                            op1_reg         <= (df1)? result_ex : op1_rs;
                            op2_reg         <= (df2)? result_ex : {{(D_SIZE-6){instr_rd[5]}}, instr_rd[5:0]};
                        end
                        default: //ALU op. without SHIFTS
                        begin
                            // control signals
                            en_write_pc_reg <= 1; 
                            reg_we_en_reg   <= 1;
                            reg_re_en_reg   <= 1;
                            alu_en_reg      <= 1;
                            alu_cmd_reg     <= instr_rd[15:9];
                            // operands
                            dest_reg_reg    <= instr_rd[8:6];
                            addr_op1_reg    <= instr_rd[5:3];
                            addr_op2_reg    <= instr_rd[2:0];
                            op1_reg         <= (df1)? result_ex : op1_rs;
                            op2_reg         <= (df2)? result_ex : op2_rs;
                        end
                    endcase //for HALT, NOP and ALU instr.
                    
                end
                2'b01:
                begin
                    reg_we_en_reg   <= 0;
                    reg_re_en_reg   <= 1;
                    alu_en_reg      <= 0;
                    //shift_en_reg    <= 0;
                    mem_re_reg      <= 0;
                    mem_we_reg      <= 0;
                    loadc_en_reg    <= 0;
                   
                    case(instr_rd[15:12])
                        
                        `JMP:
                        begin
                            jmp_sel_reg     <= 1;
                            jmpr_sel_reg    <= 0;
                            addr_op2_reg    <= instr_rd[2:0];
                            op2_reg         <= op2_rs;
                            en_write_pc_reg <= 0;
                        end
                        `JMPR:
                        begin
                            jmp_sel_reg     <= 0;
                            jmpr_sel_reg    <= 1;
                            jmp_offset_reg  <= {{(A_SIZE-6){instr_rd[5]}}, instr_rd[5:0]};
                            en_write_pc_reg <= 0;
                        end
                        `JMPcond:
                        begin
                            jmpr_sel_reg    <= 0;
                            addr_op1_reg    <= instr_rd[8:6];
                            addr_op2_reg    <= instr_rd[2:0];
                            op1_reg         <= op1_rs;
                            op2_reg         <= op2_rs;
                            case(instr_rd[11:9])
                            `N:
                            begin
                                jmp_sel_reg <= (op1_rs < 0)? 1 : 0; 
                            end
                            `NN:
                            begin
                                jmp_sel_reg <= (op1_rs >= 0)? 1 : 0; 
                            end
                            `Z:
                            begin
                                jmp_sel_reg <= (op1_rs == 0)? 1 : 0; 
                            end
                            `NZ:
                            begin
                                jmp_sel_reg <= (op1_rs != 0)? 1 : 0; 
                            end
                        endcase// endcase cond.
                            
                        end
                        `JMPRcond:
                        begin
                            jmp_sel_reg     <= 0;
                            addr_op1_reg    <= instr_rd[8:6];
                            op1_reg         <= op1_rs;
                            jmp_offset_reg  <= {{(A_SIZE-6){instr_rd[5]}}, instr_rd[5:0]};
                            case(instr_rd[11:9])
                            `N:
                            begin
                                jmpr_sel_reg <= (op1_rs < 0)? 1 : 0; 
                            end
                            `NN:
                            begin
                                jmpr_sel_reg <= (op1_rs >= 0)? 1 : 0; 
                            end
                            `Z:
                            begin
                                jmpr_sel_reg <= (op1_rs == 0)? 1 : 0; 
                            end
                            `NZ:
                            begin
                                jmpr_sel_reg <= (op1_rs != 0)? 1 : 0; 
                            end
                        endcase// endcase cond.
                        end
                    endcase //for JUMPS instr.
                end
                2'b10:
                begin
                    en_write_pc_reg <= 1;
                    alu_en_reg      <= 0;
                    jmp_sel_reg     <= 0;
                    jmpr_sel_reg    <= 0;
                    
                    case(instr_rd[15:11])
                        `STORE:
                        begin
                            // control signals
                            reg_we_en_reg   <= 0;
                            reg_re_en_reg   <= 1;
                            mem_re_reg      <= 0;
                            mem_we_reg      <= 1;
                            loadc_en_reg    <= 0;   
                            // operands
                            addr_op1_reg    <= instr_rd[10:8];
                            addr_op2_reg    <= instr_rd[ 2:0];
                            op1_reg         <= op1_rs;
                            op2_reg         <= op2_rs;
                        end
                        `LOAD:
                        begin
                            // control signals
                            reg_we_en_reg   <= 1;
                            reg_re_en_reg   <= 1;
                            mem_re_reg      <= 1;
                            mem_we_reg      <= 0;
                            loadc_en_reg    <= 0;   
                            // operands
                            dest_reg_reg    <= instr_rd[10:8];
                            addr_op1_reg    <= instr_rd[ 2:0];
                            op1_reg         <= op1_rs; 
                        end
                        `LOADC:
                        begin
                            // control signals
                            reg_we_en_reg   <= 1;
                            reg_re_en_reg   <= 1;
                            mem_re_reg      <= 0;
                            mem_we_reg      <= 0;
                            loadc_en_reg    <= 1;   
                            // operands
                            dest_reg_reg    <= instr_rd[10:8];
                            addr_op1_reg    <= instr_rd[10:8];
                            op1_reg         <= {op1_rs[31:8],instr_rd[7:0]};  
                        end
                    endcase //endcase LOAD, LOADC, STORE
                end
            endcase
        end
    end
        
endmodule
