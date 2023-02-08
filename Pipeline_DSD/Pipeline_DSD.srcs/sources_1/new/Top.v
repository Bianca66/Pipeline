`timescale 1ns/1ps

module top #(// General Parameters
             parameter D_SIZE = 32,
             parameter A_SIZE = 10)
             (
             // General
             input 		rst,   // active 0
             input		clk,
             // Program memory
             output [A_SIZE-1:0] pc,
             input        [15:0] instruction
             );
             
     // Instruction Register
    reg [15:0] instr_reg;
    // Read to Execute Register
    reg [82:0] rd2ex_reg;
    // Execute to Write Back Register
    reg [100:0] ex2wb_reg;  
    // Register Set
    reg [D_SIZE-1:0] R [7:0];    
    // Memory
    reg [D_SIZE-1:0] mem [10:0];
    
     // Intermediate Variables
    reg [D_SIZE-1:0] op1_rs;
    reg [D_SIZE-1:0] op2_rs;
    reg [D_SIZE-1:0] data_in_mem;
    
    // Iterator
    integer i;  
    
    //Wire
    //FETCH
    wire [A_SIZE-1:0] pc_out;
    //READ
    wire        [2:0] addr_op1;
    wire        [2:0] addr_op2;
    wire       [15:0] instr_rd2ex;
    wire        [2:0] dest_reg;
    wire [D_SIZE-1:0] op1;
    wire [D_SIZE-1:0] op2;
    // EXECUTE
    wire              jmp_sel_f;
    wire              jmpr_sel_f;
    wire [A_SIZE-1:0] jmp_f;
    wire [A_SIZE-1:0] jmp_offset_f;
    wire [D_SIZE-1:0] result_ex2wb;
    wire        [2:0] dest_reg_ex2wb;
    wire              reg_we_en_ex2wb;
    wire              mem_re;
    wire              mem_we;
    wire [A_SIZE-1:0] addr_mem;
    wire [D_SIZE-1:0] dout_mem;
    //WRITE BACK
    wire [A_SIZE-1:0] addr_mem_mem;
    wire              mem_re_en;
    wire [D_SIZE-1:0] result_rs;
    wire        [2:0] dest_rs;
    wire              reg_we_rs;
    wire              reg_re_rs;
    //DataForwarding
    wire df1;
    wire df2;
    wire stall;
    
    Fetch Fetch (// General
                 .clk       (clk),
                 .rst       (rst),
                 // Input <- Jump Control
                 .jmp_sel   (jmp_sel_f),
                 .jmpr_sel  (jmpr_sel_f),
                 .jmp       (jmp_f),
                 .jmp_offset(jmp_offset_f),
                 // Input <- Control
                 .stall     (stall),
                 // Output -> Program Memory
                 .pc_out    (pc_out)
                  );
             
    always @(posedge clk or negedge rst)
    begin
        if(~rst)
        begin
            instr_reg <= 0;
        end
        else if(jmp_sel_f || jmpr_sel_f)
        begin
            instr_reg <= `NOP;
        end
        else if(stall)
        begin
            instr_reg <= instr_reg;
        end
        else 
        begin
            instr_reg <= instruction;
        end
    end           
    
    Read Read (// General
               .clk        (clk),
               .rst        (rst),
               // Input <- Instr Reg
               .instr_rd   (instr_reg),
               // Input <- Reg Set
               .op1_rs     (op1_rs),
               .op2_rs     (op2_rs),
               // Input <- DataForwarding
               .df1        (df1),
               .df2        (df2),
               // Input <- Execute
               .result_ex  (result_ex2wb),
               // Output -> Reg Set
               .addr_op1   (addr_op1),
               .addr_op2   (addr_op2),
               .reg_re_rs  (reg_re_rs),
               // Output -> Rd2Ex 
               .instr_rd2ex(instr_rd2ex),
               .dest_reg   (dest_reg),
               .op1        (op1),
               .op2        (op2)
              );
              
    always@(*)
    begin
        if(~rst)
        begin
            for (i = 0; i <= 7; i = i + 1)
                begin
                    R[i] <= 0;
                end 
            op1_rs <= 0;
            op2_rs <= 0;
        end
        if(reg_we_rs)
        begin
             R[dest_rs] <= result_rs;
        end
        if(reg_re_rs)
        begin
            op1_rs <= R[addr_op1];
            op2_rs <= R[addr_op2];
        end
    end
    
    reg       [15:0] rd2ex_instr_rd2ex;
    reg        [2:0] rd2ex_dest_reg;
    reg [D_SIZE-1:0] rd2ex_op1;
    reg [D_SIZE-1:0] rd2ex_op2;
    
//    always @(posedge clk or negedge rst)
//    begin
//        if(~rst)
//        begin
//            rd2ex_reg <= 0;
//        end
//        else
//        begin
//            rd2ex_reg <= {instr_rd2ex, dest_reg, op1, op2};
//        end
//    end
    
     always @(posedge clk or negedge rst)
      begin
          if(~rst)
          begin
              rd2ex_instr_rd2ex <= 0;
              rd2ex_dest_reg    <= 0;
              rd2ex_op1         <= 0;
              rd2ex_op2         <= 0;
          end
          else if(stall)
          begin
              rd2ex_instr_rd2ex <= rd2ex_instr_rd2ex;
              rd2ex_dest_reg    <= rd2ex_dest_reg;
              rd2ex_op1         <= rd2ex_op1;
              rd2ex_op2         <= rd2ex_op2;
          end
          else
          begin
              rd2ex_instr_rd2ex <= instr_rd2ex;
              rd2ex_dest_reg    <= dest_reg;
              rd2ex_op1         <= op1;
              rd2ex_op2         <= op2;
          end
      end
    
    Execute Execute ( // General
                     .clk        (clk),
                     .rst        (rst),
                     // Input -> Rd2Ex
                     .instr_ex   (rd2ex_instr_rd2ex),
                     .dest_reg_ex(rd2ex_dest_reg),
                     .op1_ex     (rd2ex_op1),
                     .op2_ex     (rd2ex_op2),
                     // Output -> Fetch
                    .jmp_sel     (jmp_sel_f),
                    .jmpr_sel    (jmpr_sel_f),
                    .jmp         (jmp_f),
                    .jmp_offset  (jmp_offset_f),
                    // Output -> Ex2WB
                    .result      (result_ex2wb),
                    .dest_reg    (dest_reg_ex2wb),
                    .reg_we_en   (reg_we_en_ex2wb),
                    // Output -> Memory
                    .mem_re      (mem_re),
                    .mem_we      (mem_we),
                    .addr_mem    (addr_mem),
                    .dout_mem    (dout_mem)
                    );
                    
//      always @(posedge clk or negedge rst)
//      begin
//          if(~rst)
//          begin
//              ex2wb_reg <= 0;
//          end
//          else
//          begin
//              ex2wb_reg <= {result_ex2wb, dest_reg_ex2wb, reg_we_en_ex2wb, addr_mem, mem_re};
//              if(mem_re)
//                data_in_mem <= mem[addr_mem_mem];
//              if(mem_we)
//                mem[addr_mem] <= dout_mem;
//          end
//      end
      
      reg [D_SIZE-1:0] reg_result;
      reg        [2:0] reg_dest;
      reg              reg_reg_we;
      reg [A_SIZE-1:0] reg_addr_mem;
      reg              reg_mem_re;
      
      always @(posedge clk or negedge rst)
      begin
          if(~rst)
          begin
              reg_result <= 0;
              reg_dest   <= 0;
              reg_reg_we <= 0;
              reg_mem_re <= 0;
          end
          else
          begin
              reg_result   <= result_ex2wb;
              reg_dest     <= dest_reg_ex2wb;
              reg_reg_we   <= reg_we_en_ex2wb;
              reg_addr_mem <= addr_mem;
              reg_mem_re   <= mem_re;
          end
      end
      
      always @(posedge clk)
      begin
        if(mem_re)
            data_in_mem <= mem[addr_mem_mem];
        if(mem_we)
            mem[addr_mem] <= dout_mem;
      end
               
      WriteBack WriteBack (// General
                          .clk      (clk),
                          .rst      (rst),
                          // Input <- Ex2Wb
                          .result   (reg_result),
                          .dest_reg (reg_dest),
                          .reg_we_en(reg_reg_we),
                          .addr     (reg_addr_mem),
                          .mem_re   (reg_mem_re), 
                          // Input <- Memory
                          .data_in  (data_in_mem),
                          // Output -> Memory
                          .addr_mem (addr_mem_mem),
                          .mem_re_en(mem_re_en),
                          // Output -> Register Set
                          .result_rs(result_rs),
                          .dest_rs  (dest_rs),
                          .reg_we_rs(reg_we_rs)
                          );
       
       DataForwarding DataFd (// General Parameters
                              .clk(clk),
                              .rst(rst),    
                              // Input <- Read
                              .addr_op1_rd2ex(addr_op1),
                              .addr_op2_rd2ex(addr_op2), 
                              .dest_rd2ex    (dest_reg),
                              .reg_re        (reg_re_rs),
                              // Input <- Ex2Wb 
                              .dest_reg_wb   (rd2ex_dest_reg),
                              .reg_we        (reg_reg_we),
                              .mem_we        (mem_we),
                              .mem_re        (reg_mem_re),
                              .addr_mem      (addr_mem),
                              // Output -> READ
                              .df1           (df1),
                              .df2           (df2),
                              .stall         (stall)
                              );
                         
       assign pc = pc_out;
endmodule