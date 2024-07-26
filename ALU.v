module alu(
    input [31:0] a, // 32-bit operands
    input [31:0] b, // 32-bit operands
    input [3:0] aluc, // ALU control code
    output [31:0] r, // 32-bit result
    output zero, // set if result is zero
    output carry,
    output negative, // set if result is negative
    output overflow // set if overflow
    );



    parameter Addu = 4'b0000;    
    parameter Add = 4'b0010; // Add & Addi
    parameter Subu = 4'b0001;    
    parameter Sub = 4'b0011; // Will be also used for Beq and Bne
    parameter And = 4'b0100; // And & Andi
    parameter Or = 4'b0101; // Or & Ori    
    parameter Xor = 4'b0110; // Xor & Xori
    parameter Nor = 4'b0111; // Nor & Nori
    parameter Lui1 = 4'b1000;
    parameter Lui2 = 4'b1001;    
    parameter Slt = 4'b1011; //Slt & Slti
    parameter Sltu = 4'b1010; //Sltu & Sltiu
    parameter Sra = 4'b1100; //Sra & Srav
    parameter Sll = 4'b1110; //Sll & Sllv
    parameter Srl = 4'b1101; //Srl & Srlv
    parameter Slr = 4'b1111; //Never Used but just to make sure the code is clean and there are no unassigned cases


    reg [32:0] result;
    reg if_same_signal;
    reg flag;


    always @ (*) begin
        case(aluc)
            Addu: result = a + b;
            Add: begin
                result = $signed(a) + $signed(b); // The $signed function converts a and b to signed values before performing the addition.
                if_same_signal = ~(a[31] ^ b[31]); //to see if the operands have the same sign
                flag = (if_same_signal && result[31] != a[31]) ? 1 : 0;
            end
            

            Subu: result = a - b;
            Sub: begin
                result = $signed(a) - $signed(b);
                if_same_signal = ~(a[31] ^ b[31]);
                flag = (~if_same_signal && result[31] != a[31]) ? 1 : 0;
            end

            And: result = a & b;
            Or: result = a | b;
            Xor: result = a ^ b;
            Nor: result = ~(a | b);

            Lui1: result = {b[15:0], 16'b0};
            Lui2: result = {b[15:0], 16'b0}; //Same as Lui1

            Slt: result = ($signed(a) < $signed(b)) ? 1 : 0; //Set less than - set if a is less than b
            Sltu: result =  (a < b) ? 1 : 0; //Same but for unsigned

            Sra: result = $signed(b) >>> a; //Shift right arithmetic
            Sll: result = b << a; //Shift left logical
            Slr: result = b << a; //Same as Sll
            Srl: result = b >> a; //Shift right logical

        endcase
    end
    

    assign r = result[31:0];
    assign carry = (aluc == Addu | aluc == Subu | aluc == Sltu | aluc == Sra | aluc == Srl | aluc == Sll) ? result[32] : 1'bz; 
    assign zero = (r == 32'b0) ? 1 : 0; 
    assign negative = result[31];
    assign overflow = (aluc == Add | aluc == Sub) ? flag : 1'bz; 
    

endmodule