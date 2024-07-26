/*This module is responsible for determining if a branch
should be taken based on the given instruction and data.*/

module branch_comparator(
    input clk,
    input rst,
    input [31:0] data_in1, 
    input [31:0] data_in2,
    input [5:0] op,
    input [5:0] func,
    input exception,
    output reg is_branch //A flag indicating whether a branch should be taken.
    );

/* Unconditional jumps (J, JAL, JR, JALR): Sets is_branch to 1 to indicate a branch.
Exceptions: Sets is_branch to 1 to handle exceptions.*/

	always @ (*) begin
	    if(~rst)
	        is_branch <= 1'b0;

		else if(op == 6'b000100) //Beq
			is_branch <= (data_in1 == data_in2) ? 1'b1 : 1'b0;

        else if(op == 6'b000101) //Bne
			is_branch <= (data_in1 != data_in2) ? 1'b1 : 1'b0;

		else if(op == 6'b000001) //Bgez - Branch if greater than or equal to zero
			is_branch <= (data_in1 >= 0) ? 1'b1 : 1'b0;	

		else if(op == 6'b000000 && func == 6'b110100) //Teq - Trap if equal (Trap = Software Exception)
			is_branch <= (data_in1 == data_in2) ? 1'b1 : 1'b0;

		else if(op == 6'b000010) //J
			is_branch <= 1'b1;

	    else if(op == 6'b000011) //Jal - Jump and Link
	        is_branch <= 1'b1;

	    else if(op == 6'b000000 && func == 6'b001000) //Jr - Jump Register
            is_branch <= 1'b1;

        else if(op == 6'b000000 && func == 6'b001001) //Jalr - Jump and Link Register
            is_branch <= 1'b1;

        else if(exception) 
            is_branch <= 1'b1;

        else
            is_branch <= 1'b0;
	end      


endmodule