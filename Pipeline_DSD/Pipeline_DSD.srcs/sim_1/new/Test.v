`timescale 1ns / 1ps

module test();
    // General Parameters
    parameter D_SIZE = 32;
    parameter A_SIZE = 10;
    //
    reg                clk;
    reg                rst;
    reg         [15:0] instruction;
    wire  [A_SIZE-1:0] pc;
  
    
    // Program Memory
    reg [15:0] prog_mem [0:1023];
    
    top  lala(.clk(clk),
              .rst(rst),
              .instruction(instruction),
              .pc(pc)
              );
   
    initial 
    begin
        forever
        #10 clk = ~clk;
    end
    
    
    initial
    begin
        clk         = 0;
        rst         = 0;
        instruction = 0;
        
        prog_mem[0]   = {`NOP,    9'b000000000};
        prog_mem[1]   = {`LOADC, `R0, 8'b00000001};
        prog_mem[2]   = {`LOADC, `R1, 8'b00000010};
        prog_mem[3]   = {`LOADC, `R2, 8'b00000011};
        prog_mem[4]   = {`LOADC, `R3, 8'b00000100};
        prog_mem[5]   = {`LOADC, `R4, 8'b00000101};
        prog_mem[6]   = {`LOADC, `R5, 8'b00000111};
        prog_mem[7]   = {`LOADC, `R6, 8'b00001000};
        prog_mem[8]   = {`LOADC, `R7, 8'b00001001};
        prog_mem[9]   = {`ADD,   `R0, `R1, `R2};
        prog_mem[10]  = {`SUB,   `R3, `R4, `R5};
        prog_mem[11]  = {`AND,   `R6, `R1, `R2};
        prog_mem[12]  = {`OR,    `R7, `R2, `R4};
        prog_mem[13]  = {`XOR,   `R0, `R1, `R2};
        prog_mem[14]  = {`NAND,  `R3, `R4, `R5};
        prog_mem[15]  = {`NOR,   `R6, `R1, `R2};
        prog_mem[16]  = {`NXOR,  `R7, `R2, `R4};
        prog_mem[17]  = {`SHIFTR, `R3, 6'b000010};
        prog_mem[18]  = {`SHIFTRA,`R7, 6'b000010};
        prog_mem[19]  = {`SHIFTL, `R6, 6'b000101};
        prog_mem[20]  = {`STORE, `R1, 5'b00000, `R3};
        prog_mem[21]  = {`LOAD,  `R5, 5'b00000, `R1};
        prog_mem[22]  = {`STORE, `R4, 5'b00000, `R0};
        prog_mem[23]  = {`NOP,    9'b000000000};
        prog_mem[24]  = {`NOP,    9'b000000000};
        prog_mem[25]  = {`NOP,    9'b000000000};
        prog_mem[26]  = {`NOP,    9'b000000000};
        prog_mem[27]  = {`NOP,    9'b000000000};
        prog_mem[28]  = {`NOP,    9'b000000000};
        ////
        prog_mem[29]  = {`LOADC, `R0, 8'b00000001};
        prog_mem[30]  = {`ADD,   `R0, `R0, `R0};
        prog_mem[31]  = {`ADD,   `R1, `R0, `R2};
        ///
        //prog_mem[32]  = {`LOAD,  `R2, 5'b00000, `R1};
        //prog_mem[33]  = {`ADD,   `R3, `R2, `R2};
        ///
        prog_mem[32]  = {`JMP,9'b000000000, `R2};
        prog_mem[33]  = {`NOP,    9'b000000000};
//        prog_mem[34]  = {`NOP,    9'b000000000};
        
//        prog_mem[24]  = {`LOAD,  `R7, 5'b00000, `R4};
//        //
//        prog_mem[25]  = {`JMP,9'b000000000, `R2};
//        prog_mem[26]  = {`NOP,    9'b000000000};
        //
        //prog_mem[26]  = {`LOADC, `R0, 8'b00000001};
        //prog_mem[26]  = {`ADD,   `R0, `R0, `R0};
        //prog_mem[27]  = {`ADD,   `R1, `R0, `R2};
        //prog_mem[28]  = {`AND,   `R1, `R7, `R0};
        //
        //prog_mem[25]  = {`ADD,   `R1, `R2, `R0};
        //prog_mem[26]  = {`LOAD,  `R4, 5'b00000, `R1};
        //prog_mem[27]  = {`STORE, `R4, 5'b00000, `R1};
        //

        
        //prog_mem[28]  = {`NOP,    9'b000000000};
        //prog_mem[28]  = {`NOP,    9'b000000000};
        //prog_mem[29]  = {`NOP,    9'b000000000};
        //prog_mem[26]  = {`JMPcond,`NN, `R0, 3'b000, `R7};
        //prog_mem[26]  = {`JMP,9'b000000000, `R2};
        //prog_mem[26] = {`JMPRcond,`Z, `R0, 6'b000110};
//        prog_mem[26]  = {`ADD,   `R0, `R1, `R2};
//        prog_mem[27]  = {`SUB,   `R3, `R4, `R5};
//        prog_mem[28]  = {`AND,   `R6, `R1, `R2};
//        prog_mem[29]  = {`OR,    `R7, `R2, `R4};
//        prog_mem[30]  = {`XOR,   `R0, `R1, `R2};


        //prog_mem[0] = {`LOADC, `R1, 8'b00000011};
        //prog_mem[1] = {`LOADC, `R2, 8'b00000011};
        //prog_mem[2] = {`LOADC, `R0, 8'b00000001};
        //prog_mem[3] = {`LOADC, `R3, 8'b00000100};
        //prog_mem[4] = {`LOADC, `R5, 8'b00000101};
        //prog_mem[5] = {`ADD, `R4, `R1, `R2};
        //prog_mem[6] = {`SUB, `R3, `R3, `R0};
        //prog_mem[7] = {`JMPcond, `NZ, `R3, 3'b000, `R5};
        //prog_mem[8] = {`HALT,  9'b000000000};
        /*
        prog_mem[0]  = {`NOP,    9'b000000000};
        prog_mem[1]  = {`NOP,    9'b000000000};
        prog_mem[2]  = {`SHIFTR, `R4, 6'b000011};
        prog_mem[3]  = {`ADD,    `R2, `R0, `R1};
        prog_mem[4]  = {`SUB,    `R5, `R7, `R6};
        prog_mem[5]  = {`LOADC, `R7, 8'b00000101};
        prog_mem[6]  = {`STORE, `R1, 5'b00000, `R3};
        prog_mem[7]  = {`LOAD,  `R5, 5'b00000, `R1};
        prog_mem[8]  = {`ADD,    `R2, `R6, `R1};
        prog_mem[9]  = {`ADD,    `R3, `R2, `R1};
        prog_mem[10] = {`LOADC, `R5, 8'b00000101};
        prog_mem[11]  = {`ADD,   `R1, `R3, `R5};
        prog_mem[12] = {`HALT,  9'b000000000};
        */
        //prog_mem[8]  = {`JMP,    9'b000000000, `R3};
        //prog_mem[9]  = {`LOADC, `R0, 8'b00000101};
        //prog_mem[10] = {`LOADC, `R6, 8'b00001101};
        //prog_mem[11] = {`SUB,    `R5, `R7, `R6};
        
        /*
        prog_mem[3]  = {`ADDF,   `R3, `R0, `R1};
        
        prog_mem[5]  = {`SUBF,   `R3, `R0, `R1};
        prog_mem[6]  = {`AND,    `R4, `R0, `R1};
        prog_mem[7]  = {`OR,     `R4, `R0, `R6};
        prog_mem[8]  = {`XOR,    `R5, `R3, `R1};
        prog_mem[9]  = {`NAND,   `R4, `R0, `R1};
        prog_mem[10] = {`NOR,    `R4, `R0, `R1};
        prog_mem[11] = {`NXOR,   `R4, `R0, `R1};
        prog_mem[12] = {`SHIFTR, `R0, 6'b001001};
        prog_mem[13] = {`SHIFTL, `R0, 6'b000011};
        prog_mem[14] = {`SHIFTRA,`R0, 6'b000111};
        prog_mem[15] = {`LOAD,  `R5, 5'b00000, `R2};
        prog_mem[16] = {`LOADC, `R7, 8'b10000101};
        prog_mem[17] = {`STORE, `R2, 5'b00000, `R0};
        prog_mem[18] = {`JMP,9'b000000000, `R0};
        prog_mem[19] = {`JMPR, 6'b000000, 6'b011001};
        prog_mem[20] = {`JMPcond,`Z, `R0, 3'b000, `R7};
        prog_mem[21] = {`JMPcond,`NZ, `R0, 3'b000, `R7};
        prog_mem[22] = {`JMPcond,`N, `R0, 3'b000, `R7};
        prog_mem[23] = {`JMPcond,`NN, `R0, 3'b000, `R7};
        prog_mem[24] = {`JMPRcond,`Z, `R0, 6'b000010};
        prog_mem[25] = {`JMPRcond,`NZ, `R0, 6'b000010};
        prog_mem[26] = {`JMPRcond,`N, `R0, 6'b000010};
        prog_mem[27] = {`JMPRcond,`NN, `R0, 6'b000010};
        
        */
     end
     
      initial 
        begin
            #91
            rst = 1;
            instruction = prog_mem[pc];
            while(instruction[15:9] != `HALT)
            begin
                @pc;
                instruction = prog_mem[pc];
            end
            #900 
            $stop;
        end
     
    
endmodule
