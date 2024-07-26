module control_unit(
    input is_branch,
    input [31:0] instruction,
    input [5:0] op,
    input [5:0] func,
    input [31:0] status, //Status register
    
    output rf_wena, //Register file write enable     
    output hi_wena, //HI write enable
    output lo_wena, //LO write enable
    output dmem_wena, //Data memory write enable
    output rf_rena1, //Register file read enable 1
    output rf_rena2, //Register file read enable 2
    output clz_ena, //Count leading zeros enable
    output mul_ena, //Multiplication enable
    output div_ena, //Division enable
    output dmem_ena, //Data memory enable
    output [1:0] dmem_w_cs, //Data memory write size - Word or Halfword or Byte
    output [1:0] dmem_r_cs, //Data memory read size - Word or Halfword or Byte
    output ext16_sign, //Sign extension for 16-bit immediate
    output cutter_sign, //either the byte or the halfword that will be cut is signed or not
    output mul_sign,  
    output div_sign, 
    output [3:0] aluc, //ALU control code
    output [4:0] rd, //Destination register
    output mfc0, //Move from coprocessor 0
    output mtc0, //Move to coprocessor 0
    output eret, //Exception return
    output exception,
    output [4:0] cp0_addr, //Coprocessor 0 address
    output [4:0] cause,
    output ext5_mux_sel, //Sign extension for 5-bit immediate
    output cutter_mux_sel,
    output alu_mux1_sel,       
    output [1:0] alu_mux2_sel,
    output [1:0] hi_mux_sel, //Selects between Division Remainder or Multiplication Upper Result or RS for the (mthi) instruction
    output [1:0] lo_mux_sel, //Selects between Division Quotient or Multiplication Lower Result or RS for the (mtlo) instruction
    output [2:0] cutter_sel,
    output [2:0] rf_mux_sel,
    output [2:0] pc_mux_sel //Select between Jump, Branch, Exception Return, PC+4, and CP0
    );



    wire Addi = (op == 6'b001000); //Add Immediate
    wire Addiu = (op == 6'b001001); //Add Immediate Unsigned
    wire Andi = (op == 6'b001100); //And Immediate
    wire Ori = (op == 6'b001101); //Or Immediate
    wire Sltiu = (op == 6'b001011); //Set Less Than Immediate Unsigned
    wire Lui = (op == 6'b001111); //Load Upper Immediate
    wire Xori = (op == 6'b001110); //Xor Immediate
    wire Slti = (op == 6'b001010); //Set Less Than Immediate
    wire Addu = (op == 6'b000000 && func==6'b100001); //Add Unsigned
    wire And = (op == 6'b000000 && func == 6'b100100); //And
    wire Beq = (op == 6'b000100); //Branch if Equal
    wire Bne = (op == 6'b000101); //Branch if Not Equal
    wire J = (op == 6'b000010); //Jump
    wire Jal = (op == 6'b000011); //Jump and Link
    wire Jr = (op == 6'b000000 && func == 6'b001000); //Jump Register
    wire Lw = (op == 6'b100011); //Load Word
    wire Xor = (op == 6'b000000 && func == 6'b100110); //Xor
    wire Nor = (op == 6'b000000 && func == 6'b100111); //Nor
    wire Or = (op == 6'b000000 && func == 6'b100101); //Or
    wire Sll = (op == 6'b000000 && func == 6'b000000); //Shift Left Logical
    wire Sllv = (op == 6'b000000 && func == 6'b000100); //Shift Left Logical Variable
    wire Sltu = (op == 6'b000000 && func == 6'b101011); //Set Less Than Unsigned
    wire Sra = (op == 6'b000000 && func == 6'b000011); //Shift Right Arithmetic
    wire Srl = (op == 6'b000000 && func == 6'b000010); //Shift Right Logical
    wire Subu = (op == 6'b000000 && func == 6'b100011); 
    wire Sw = (op == 6'b101011); //Store Word
    wire Add = (op == 6'b000000 && func == 6'b100000); //Add
    wire Sub = (op == 6'b000000 && func == 6'b100010); //Subtract
    wire Slt = (op == 6'b000000 && func == 6'b101010); //Set Less Than
    wire Srlv = (op == 6'b000000 && func == 6'b000110); //Shift Right Logical Variable
    wire Srav = (op == 6'b000000 && func == 6'b000111); //Shift Right Arithmetic Variable
    

    wire Clz = (op == 6'b011100 && func == 6'b100000); //Count Leading Zeros
    wire Divu = (op == 6'b000000 && func == 6'b011011); //Divide Unsigned
    wire Eret = (op == 6'b010000 && func == 6'b011000); //Exception Return //Different signal than the output signal (eret)
    wire Jalr = (op == 6'b000000 && func == 6'b001001); //Jump and Link Register
    wire Lb = (op == 6'b100000); //Load Byte
    wire Lbu = (op == 6'b100100); //Load Byte Unsigned
    wire Lhu = (op == 6'b100101); //Load Halfword Unsigned
    wire Sb = (op == 6'b101000); //Store Byte
    wire Sh = (op == 6'b101001); //Store Halfword
    wire Lh = (op == 6'b100001); //Load Halfword
    wire Mfc0 = (instruction[31:21] == 11'b01000000000 && instruction[10:3]==8'b00000000); //Move from Coprocessor 0
    wire Mfhi = (op == 6'b000000 && func == 6'b010000); //Move from HI
    wire Mflo = (op == 6'b000000 && func == 6'b010010); //Move from LO
    wire Mtc0 = (instruction[31:21] == 11'b01000000100 && instruction[10:3]==8'b00000000); //Move to Coprocessor 0
    wire Mthi = (op == 6'b000000 && func == 6'b010001); //Move to HI
    wire Mtlo = (op == 6'b000000 && func == 6'b010011); //Move to LO
    wire Mul = (op == 6'b011100 && func == 6'b000010); //Multiply
    wire Multu = (op == 6'b000000 && func == 6'b011001); //Multiply Unsigned
    wire Syscall = (op == 6'b000000 && func== 6'b001100); //System Call
    wire Teq = (op == 6'b000000 && func == 6'b110100);  //Trap if equal (Trap = Software Exception)
    wire Bgez = (op == 6'b000001); //Branch if greater than or equal to zero
    wire Break = (op == 6'b000000 && func == 6'b001101); //Breakpoint
    wire Div = (op == 6'b000000 && func == 6'b011010); //Divide


/*
We chose to go with the continous assignment instead of using combinational always and case statements because of:
1- Using continuous assignments and boolean expressions can make the control signals easier to read and understand.
2- This style avoids deeply nested case or if statements, which can become hard to read and maintain. 
3- Continuous assignments can often directly map to combinational logic gates, potentially leading to more optimized hardware synthesis. 
4- In continuous assignments, all the conditions are evaluated in parallel, which can be more efficient in terms of timing and resource usage.
*/

    assign rf_rena1 = Addi|Addiu|Andi|Ori|Sltiu|Xori|Slti|Addu|And|Beq|Bne|Jr|Lw|Xor|Nor|Or|Sllv|Sltu|Subu|Sw|Add|Sub|Slt|Srlv|Srav|Clz|Divu|Jalr|Lb|Lbu|Lhu|Sb|Sh|Lh|Mul|Multu|Teq|Div;
    assign rf_rena2 = Addu | And | Beq | Bne | Xor | Nor | Or | Sll | Sllv | Sltu | Sra | Srl | Subu | Sw | Add | Sub | Slt | Srlv | Srav | Divu | Sb | Sh | Mtc0 | Mul | Multu | Teq | Div;



    assign hi_wena = Div | Divu | Multu | Mthi | Mul;
    assign lo_wena = Div | Divu | Multu | Mtlo | Mul;
    assign rf_wena = Addi | Addiu | Andi | Ori | Sltiu | Lui | Xori | Slti | Addu | And | Xor | Nor | Or | Sll | Sllv | Sltu | Sra | Srl | Subu | Add | Sub | Slt | Srlv | Srav | Lb | Lbu | Lh | Lhu | Lw | Mfc0 | Clz | Jal | Jalr | Mfhi | Mflo | Mul;
    assign clz_ena = Clz;
    assign mul_ena = Mul | Multu;
    assign div_ena = Div | Divu;                                     


    assign dmem_wena = Sb | Sh | Sw;
    assign dmem_ena = Lw | Sw | Sb | Sh | Lb | Lh | Lhu | Lbu;
    assign dmem_w_cs[1] = Sh | Sb; //00: No write operation, 01: SW, 10: SH, 11: SB //
    assign dmem_w_cs[0] = Sw | Sb; ///////////////////////////
    assign dmem_r_cs[1] = Lh | Lb | Lhu | Lbu; //00: No Read operation, 01: LW, 10: LH, 11: LB //
    assign dmem_r_cs[0] = Lw | Lb | Lbu;     


    assign cutter_sign = Lb+Lh;
    assign mul_sign = Mul;
    assign div_sign = Div;
    assign ext16_sign = Addi+Addiu+Sltiu+Slti;
    

    assign ext5_mux_sel = Sllv+Srav+Srlv;


    assign alu_mux1_sel = ~(Sll+Srl+Sra+Div+Divu+Mul+Multu+J+Jr+Jal+Jalr+Mfc0+Mtc0+Mfhi+Mflo+Mthi+Mtlo+Clz+Eret+Syscall+Break);
    assign alu_mux2_sel[1] = Bgez;
    assign alu_mux2_sel[0] = Slti+Sltiu+Addi+Addiu+Andi+Ori+Xori+Lb+Lbu+Lh+Lhu+Lw+Sb+Sh+Sw+Lui;


    assign aluc[3] = Slt+Sltu+Sllv+Srlv+Srav+Lui+Srl+Sra+Slti+Sltiu+Sll;
    assign aluc[2] = And+Or+Xor+Nor+Sll+Srl+Sra+Sllv+Srlv+Srav+Andi+Ori+Xori;
    assign aluc[1] = Add+Sub+Xor+Nor+Slt+Sltu+Sll+Sllv+Addi+Xori+Beq+Bne+Slti+Sltiu+Bgez+Teq; // For Beq and Bne, we will perform a Sub operation
    assign aluc[0] = Subu+Sub+Or+Nor+Slt+Sllv+Srlv+Sll+Srl+Slti+Ori+Beq+Bne+Bgez+Teq;
    

    assign cutter_mux_sel = ~(Sb+Sh+Sw);
    assign cutter_sel[2] = Sh; // To cut the data_in and take the lower 16 bits
    assign cutter_sel[1] = Lb+Lbu+Sb; // To cut the data_in and take the lower 8 bits
    assign cutter_sel[0] = Lh+Lhu+Sb;


    assign rf_mux_sel[2] = ~(Beq+Bne+Bgez+Div+Divu+Sb+Multu+Sh+Sw+J+Jr+Jal+Jalr+Mfc0+Mtc0+Mflo+Mthi+Mtlo+Clz+Eret+Syscall+Teq+Break);
    assign rf_mux_sel[1] = Mul+Mfc0+Mtc0+Clz+Mfhi;
    assign rf_mux_sel[0] = ~(Beq+Bne+Bgez+Div+Divu+Multu+Lb+Lbu+Lh+Lhu+Lw+Sb+Sh+Sw+J+Mtc0+Mfhi+Mflo+Mthi+Mtlo+Clz+Eret+Syscall+Teq+Break);
    

    assign pc_mux_sel[2] = Eret+(Beq&&is_branch)+(Bne&&is_branch)+(Bgez&&is_branch);
    assign pc_mux_sel[1] = ~(J+Jr+Jal+Jalr+pc_mux_sel[2]);
    assign pc_mux_sel[0] = Eret+exception+Jr+Jalr;


    assign hi_mux_sel[1] = Mthi;
    assign hi_mux_sel[0] = Mul+Multu;


    assign lo_mux_sel[1] = Mtlo;
    assign lo_mux_sel[0] = Mul+Multu;


// For rd, we will take the rd if the instruction is a R-type, else if it is an I-type, we will take the rt, and if it's J-type, we will not care about it 
    assign rd = (Add+Addu+Sub+Subu+And+Or+Xor+Nor+Slt+Sltu+Sll+Srl+Sra+Sllv+Srlv+Srav+Clz+Jalr+Mfhi+Mflo+Mul) ? 
                   instruction[15:11] : (( Addi+Addiu+Andi+Ori+Xori+Lb+Lbu+Lh+Lhu+Lw+Slti+Sltiu+Lui+Mfc0) ? 
                   instruction[20:16] : (Jal?5'd31:5'b0));


    assign mfc0 = Mfc0;
    assign mtc0 = Mtc0;
    assign cp0_addr = instruction[15:11]; //rd is the one in coprocessor 0
    assign exception = status[0] && ((Syscall && status[1]) || (Break && status[2]) || (Teq && status[3]));
    assign eret = Eret;
    assign cause = Break ? 5'b01001 : (Syscall ? 5'b01000 : (Teq ? 5'b01101 : 5'b00000)); //Break Cause: 0X00000024 ---- System Call Cause: 0X00000020 ---- Trap Cause: 0X00000034


endmodule