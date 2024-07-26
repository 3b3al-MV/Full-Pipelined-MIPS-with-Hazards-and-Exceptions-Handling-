/*This module counts the zero at the beginning of the data_in*/

/*It's for CLZ which is an MIPS32 instruction used to calculate # of 0 bits in register respectively.
It does not belong to MIPS IV ISA but usually modeled as it does not contradict MIPS IV.*/

module leading_0_counter(
    input [31:0] data_in,
    input ena,
    output [31:0] data_out
    );
    
    reg [31:0] count;

    always @(*) 
    begin
        if (ena == 1'b1) begin
            for (count = 0; count < 32 && data_in[31 - count] != 1; count = count)
                count = count + 1;
        end
    end 

    assign data_out = count;

endmodule