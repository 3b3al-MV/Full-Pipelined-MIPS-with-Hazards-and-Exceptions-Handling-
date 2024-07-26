//Coprcessor0 Module

/*CP0 is responsible for handling exceptions, managing status
and control registers, and providing system control capabilities.*/


module cp0(
    input clk,
    input rst,
    input mfc0, //cpu instruction - Move from coprocessor 0
    input mtc0, //cpu instruction - Move to coprocessor 0
    input [31:0] pc,
    input [4:0] addr, //specifies CP0 reg to write or read from
    input [31:0] wdata, //data to be written to CP0 reg
    input exception, //instruction syscall,break,teq
    input eret, //exception return
    input [4:0] cause,

    output [31:0] rdata, //data from CP0 reg for GP reg
    output [31:0] status,
    output [31:0] exc_addr //Exception address, used to determine where to jump in case of an exception - Used to update the PC at the beginning of an exception
    );


    reg [31:0] register [31:0]; //CP0 registers - same size as the register file
    reg [31:0] temp_status; //Temporary register to store the status register value during exception handling.
    integer i;

    always @ (posedge clk or negedge rst) 
    begin
        if (~rst) begin
            for(i = 0; i < 32; i = i + 1) begin
                if(i == 12) //12 is the index of the Status Register
                    register[i] <= 32'h0000000f; //Least 4 bits Interrupt Masking
                else
                    register[i] <= 0;
            end
            temp_status <= 0;
        end

        else begin
            if(mtc0)
                register[addr] <= wdata; //synchronous write

            else if(exception) begin
                // We put the pc not the pc+4 as I will repeat the same instruction I was performing when the exception occured
                register[14] = pc; //14 is the index of the EPC (Exception Program Counter)
                temp_status = register[12];
                register[12] = register[12] << 5;
                register[13] = {25'b0, cause, 2'b0}; //Cause will be put in bit [6:2]
            end

            else if(eret) 
                register[12] = temp_status;
        end 
    end

    assign exc_addr = eret ? register[14] : 32'h00400004; //32'h00400004 is start of the program pc + 4
    assign rdata = mfc0 ? register[addr] : 32'h0; //asynchronous read
    assign status = register[12];

endmodule