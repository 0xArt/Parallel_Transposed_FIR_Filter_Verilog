`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
//
// Create Date: 10/14/2021 12:54:10 PM
// Design Name: 
// Module Name: fir_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Pipelined Parallel Transposed FIR Filter
// Based on https://github.com/DHMarinov/Parallel-FIR-Filter
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
(* use_dsp = "yes" *)
module fir_filter#(
    parameter NUM_TAPS          = 60, 
    parameter DATA_WIDTH        = 16, 
    parameter COEF_WIDTH        = 16,
    parameter FRACTION_WIDTH    = 15, 
    parameter PORT_A_WIDTH      = 16,
    parameter PORT_B_WIDTH      = 16
)(
        input  wire                                                     clock,
        input  wire                                                     reset_n,
        input  wire signed [DATA_WIDTH-1:0]                             data, 
        input  wire                                                     enable,

        output reg  signed [DATA_WIDTH+COEF_WIDTH-FRACTION_WIDTH-1:0]   filtered_data,
        output reg                                                      filtered_data_valid
);

integer i;
integer j;
integer k;
integer x;

logic   signed [PORT_A_WIDTH-1:0]                           _dsp_port_a         [NUM_TAPS-1:0]; 
reg     signed [PORT_A_WIDTH-1:0]                           dsp_port_a          [NUM_TAPS-1:0]; 
logic   signed [PORT_B_WIDTH-1:0]                           _dsp_port_b         [NUM_TAPS-1:0]; 
reg     signed [PORT_B_WIDTH-1:0]                           dsp_port_b          [NUM_TAPS-1:0]; 
logic   signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0]              _dsp_mult_register  [NUM_TAPS-1:0];
reg     signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0]              dsp_mult_register   [NUM_TAPS-1:0];
logic   signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0]              _dsp_accum_register [NUM_TAPS-1:0];
reg     signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0]              dsp_accum_register  [NUM_TAPS-1:0];
logic   signed [DATA_WIDTH+COEF_WIDTH-FRACTION_WIDTH-1:0]   _filtered_data;
logic   signed [COEF_WIDTH-1:0]                             fir_coefficients    [NUM_TAPS-1:0];
logic                                                       _filtered_data_valid;


//sim use only
initial begin
    $readmemh("FIR_LPF_COEFF.mem", fir_coefficients);
end


/*
//synthesis use
//2MHz cutoff Blackman 1.15 fixed point
assign fir_coefficients[0]  = 16'h0000; 
assign fir_coefficients[1]  = 16'h0000; 
assign fir_coefficients[2]  = 16'hFFFF; 
assign fir_coefficients[3]  = 16'hFFFF; 
assign fir_coefficients[4]  = 16'hFFFF; 
assign fir_coefficients[5]  = 16'h0001; 
assign fir_coefficients[6]  = 16'h0004; 
assign fir_coefficients[7]  = 16'h000B; 
assign fir_coefficients[8]  = 16'h0015; 
assign fir_coefficients[9]  = 16'h0024; 
assign fir_coefficients[10] = 16'h003A; 
assign fir_coefficients[11] = 16'h0057; 
assign fir_coefficients[12] = 16'h007E; 
assign fir_coefficients[13] = 16'h00B0; 
assign fir_coefficients[14] = 16'h00EC; 
assign fir_coefficients[15] = 16'h0135; 
assign fir_coefficients[16] = 16'h0189; 
assign fir_coefficients[17] = 16'h01E9; 
assign fir_coefficients[18] = 16'h0254; 
assign fir_coefficients[19] = 16'h02C7; 
assign fir_coefficients[20] = 16'h0340; 
assign fir_coefficients[21] = 16'h03BD; 
assign fir_coefficients[22] = 16'h0439; 
assign fir_coefficients[23] = 16'h04B2; 
assign fir_coefficients[24] = 16'h0523; 
assign fir_coefficients[25] = 16'h0588; 
assign fir_coefficients[26] = 16'h05DE; 
assign fir_coefficients[27] = 16'h0622; 
assign fir_coefficients[28] = 16'h0650; 
assign fir_coefficients[29] = 16'h0668; 
assign fir_coefficients[30] = 16'h0668; 
assign fir_coefficients[31] = 16'h0650; 
assign fir_coefficients[32] = 16'h0622; 
assign fir_coefficients[33] = 16'h05DE; 
assign fir_coefficients[34] = 16'h0588; 
assign fir_coefficients[35] = 16'h0523; 
assign fir_coefficients[36] = 16'h04B2; 
assign fir_coefficients[37] = 16'h0439; 
assign fir_coefficients[38] = 16'h03BD; 
assign fir_coefficients[39] = 16'h0340; 
assign fir_coefficients[40] = 16'h02C7; 
assign fir_coefficients[41] = 16'h0254; 
assign fir_coefficients[42] = 16'h01E9; 
assign fir_coefficients[43] = 16'h0189; 
assign fir_coefficients[44] = 16'h0135; 
assign fir_coefficients[45] = 16'h00EC; 
assign fir_coefficients[46] = 16'h00B0; 
assign fir_coefficients[47] = 16'h007E; 
assign fir_coefficients[48] = 16'h0057; 
assign fir_coefficients[49] = 16'h003A; 
assign fir_coefficients[50] = 16'h0024; 
assign fir_coefficients[51] = 16'h0015; 
assign fir_coefficients[52] = 16'h000B; 
assign fir_coefficients[53] = 16'h0004; 
assign fir_coefficients[54] = 16'h0001; 
assign fir_coefficients[55] = 16'hFFFF; 
assign fir_coefficients[56] = 16'hFFFF; 
assign fir_coefficients[57] = 16'hFFFF; 
assign fir_coefficients[58] = 16'h0000; 
assign fir_coefficients[59] = 16'h0000;
*/

always_comb begin
    _dsp_port_a             = dsp_port_a;
    _dsp_port_b             = dsp_port_b;
    _dsp_mult_register      = dsp_mult_register;
    _dsp_accum_register     = dsp_accum_register;
    //we are using 1.15 fixed point coeffecients so we need to divide by 2^15 to normalize and interpret our result
    //this removes the 15 bits of fractional data and just leave us with the integer portion
    _filtered_data          = (dsp_accum_register[0] >> FRACTION_WIDTH);
    _filtered_data_valid    = 0;

    if (enable) begin
        _filtered_data_valid    = 1;

        for (i=0; i<NUM_TAPS; i=i+1) begin
            //extend input data to PORT_A_WIDTH bits for PORTA of DSP48 SLICE
            for (j=0; j < PORT_A_WIDTH; j = j+ 1) begin
                if (j < (DATA_WIDTH-1)) begin
                    _dsp_port_a[i][j]   = data[j];
                end
                else begin
                    //twos compliment extension must fill new width with sign bit
                    _dsp_port_a[i][j]   = data[DATA_WIDTH-1];
                end
            end

            for (k=0; k < PORT_B_WIDTH; k=k+1) begin
                //extend coeffecient data to PORT_B_WIDTH bits for PORTB of DSP48 SLICE
                if (k < (COEF_WIDTH-1))begin
                    _dsp_port_b[i][k]   = fir_coefficients[i][k];
                end
                else begin
                    //twos compliment extension must fill new width with sign bit
                    _dsp_port_b[i][k]   = fir_coefficients[i][COEF_WIDTH-1];
                end
            end

            _dsp_mult_register[i]       = dsp_port_a[i] * dsp_port_b[i];

            if(i == (NUM_TAPS-1))begin
                _dsp_accum_register[i]  = dsp_mult_register[i];
            end
            else begin
                _dsp_accum_register[i]  = dsp_mult_register[i] + dsp_accum_register[i+1];
            end
        end
    end

end


always_ff @(posedge clock or negedge reset_n) begin
    if(!reset_n)begin
        filtered_data               <= 0;
        filtered_data_valid         <= 0;

        for (x=0; x<NUM_TAPS; x=x+1) begin
            dsp_port_a[x]           <= 0;
            dsp_port_b[x]           <= 0;
            dsp_mult_register[x]    <= 0;
            dsp_accum_register[x]   <= 0;
        end
    end
    else begin
        filtered_data               <= _filtered_data;
        filtered_data_valid         <= _filtered_data_valid;
        dsp_port_a                  <= _dsp_port_a;
        dsp_port_b                  <= _dsp_port_b;
        dsp_mult_register           <= _dsp_mult_register;
        dsp_accum_register          <= _dsp_accum_register;
    end
end




endmodule
