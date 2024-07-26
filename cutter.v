//This module is a cutter for Sb, Sh, Lb, Lh intructions

module cutter(
    input [31:0] data_in,
    input [2:0] sel, //Connected the cutter_sel signal that comes from the control unit
    input sign,
    output [31:0] data_out
    );
    
    reg [31:0] temp;
    
    always @ (*) begin
        case(sel)
            // Handle 16-bit halfword with optional sign extension for Lh or Lhu
            3'b001: temp <= {(sign && data_in[15]) ? 16'hffff : 16'h0000, data_in[15:0]};
            // Handle 8-bit byte with optional sign extension for Lb and Lbu
            3'b010: temp <= {(sign && data_in[7]) ? 24'hffffff : 24'h000000, data_in[7:0]};
            // Handle 8-bit byte without sign extension for Sb
            3'b011: temp <= {24'h000000, data_in[7:0]}; 
            // Handle 16-bit halfword without sign extension for Sh
            3'b100: temp <= {16'h0000, data_in[15:0]};
            default: temp <= data_in;
        endcase
    end
    
    assign data_out = temp;
    
endmodule