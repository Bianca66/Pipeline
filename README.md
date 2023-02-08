# Pipeline
In this project, it was implemented a 4 stages pipeline RISC processor for operations on integers.
# Simple Risc Processor Microarchitecture

The processor has four stages of pipeline: Fetch, Read, Execute, and WriteBack. The Fetch stage reads instructions from the program memory and keeps and updates the program counter. The Read stage reads the operands from the register set. The execution step gives the memory address for load/store instructions, executes the actual computation for the arithmetic logical instructions, delivers the data needed for the store instruction and transmits it to the memory (data out). The write-back stage retrieves the data for a load instruction from the memory output and transfers the result to the register set (data in). 

<img src="https://github.com/Bianca66/Pipeline/blob/main/img/schematic.png" width="800"/>

In order to keep a steady rate of instructions, the data dependencies are solved through data forwarding from the output of the execution stage to the read stage to the instruction that needs the previous result. However, if a LOAD instruction is in the execution stage and its result is to be used by an instruction that is already in the read stage, this last instruction must be stalled for one cycle (and the PC kept at its current value) until the LOAD instruction is in the write-back stage when it receives data from memory and may forward it to the stalled instruction. Between the LOAD instruction and the stalled instruction NOP is inserted.

All jump instructions are carried out during the execution step, after which the target address is loaded onto the PC if a leap is necessary. Additionally, if the leap is chosen, NOPs must be used in place of the more recent instructions that have already been collected. The target address computation for relative jumps must add the offset to the location where the jump instruction was fetched rather than the current PC value.

|Data Width|32 b|
| :- | :- |
|Address Width|10 b|
|General Purpose Registers|8 (R0 – R7)|
|Data Memory|1024 x 32b|
|Instruction Memory|1024 x 16 b|
|Instruction Size|16 b|
# Instruction Set Architecture

<img src="https://github.com/Bianca66/Pipeline/blob/main/img/instr1.png" width="800"/>
<img src="https://github.com/Bianca66/Pipeline/blob/main/img/instr2.png" width="800"/>
<img src="https://github.com/Bianca66/Pipeline/blob/main/img/instr3.png" width="800"/>
<img src="https://github.com/Bianca66/Pipeline/blob/main/img/instr4.png" width="800"/>
<img src="https://github.com/Bianca66/Pipeline/blob/main/img/instr5.png" width="800"/>

##
