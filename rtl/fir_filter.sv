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
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
(* use_dsp = "yes" *)
module fir_filter#(
    parameter NUM_TAPS     = 60, 
    parameter DATA_WIDTH   = 16, 
    parameter COEF_WIDTH   = 16, 
    parameter PORT_A_WIDTH = 16,
    parameter PORT_B_WIDTH = 16
)(
        input  wire                                     clock,
        input  wire                                     reset_n,
        input  wire signed [DATA_WIDTH-1:0]             data, 

        output reg  signed [DATA_WIDTH+COEF_WIDTH-1:0]  filtered_data
);

integer i;
integer j;
integer k;
integer x;

logic   signed [PORT_A_WIDTH-1:0]               _dsp_port_a         [NUM_TAPS-1:0]; 
reg     signed [PORT_A_WIDTH-1:0]               dsp_port_a          [NUM_TAPS-1:0]; 
logic   signed [PORT_B_WIDTH-1:0]               _dsp_port_b         [NUM_TAPS-1:0]; 
reg     signed [PORT_B_WIDTH-1:0]               dsp_port_b          [NUM_TAPS-1:0]; 
logic   signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0]  _dsp_mult_register  [NUM_TAPS-1:0];
reg     signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0]  dsp_mult_register   [NUM_TAPS-1:0];
logic   signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0]  _dsp_accum_register [NUM_TAPS-1:0];
reg     signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0]  dsp_accum_register  [NUM_TAPS-1:0];
logic   signed [DATA_WIDTH+COEF_WIDTH-1:0]      _filtered_data;
logic   signed [COEF_WIDTH-1:0]                 fir_coefficients    [NUM_TAPS-1:0];


//sim use only
initial begin
    $readmemh("FIR_LPF_COEFF.mem", fir_coefficients);
end


/*
//synthesis use
//2MHz cutoff Blackman 1.15 fixed point
assign fir_coefficients[0]  = 16'h0000; 
assign fir_coefficients[1]  = 16'h0001; 
assign fir_coefficients[2]  = 16'h0003; 
assign fir_coefficients[3]  = 16'h0008; 
assign fir_coefficients[4]  = 16'h000F; 
assign fir_coefficients[5]  = 16'h0019; 
assign fir_coefficients[6]  = 16'h0027; 
assign fir_coefficients[7]  = 16'h003A; 
assign fir_coefficients[8]  = 16'h0051; 
assign fir_coefficients[9]  = 16'h006E; 
assign fir_coefficients[10] = 16'h0091; 
assign fir_coefficients[11] = 16'h00BC; 
assign fir_coefficients[12] = 16'h00ED; 
assign fir_coefficients[13] = 16'h0126; 
assign fir_coefficients[14] = 16'h0166; 
assign fir_coefficients[15] = 16'h01AD; 
assign fir_coefficients[16] = 16'h01FB; 
assign fir_coefficients[17] = 16'h024E; 
assign fir_coefficients[18] = 16'h02A5; 
assign fir_coefficients[19] = 16'h02FF; 
assign fir_coefficients[20] = 16'h0359; 
assign fir_coefficients[21] = 16'h03B3; 
assign fir_coefficients[22] = 16'h040A; 
assign fir_coefficients[23] = 16'h045C; 
assign fir_coefficients[24] = 16'h04A7; 
assign fir_coefficients[25] = 16'h04E9; 
assign fir_coefficients[26] = 16'h0520; 
assign fir_coefficients[27] = 16'h054B; 
assign fir_coefficients[28] = 16'h0568; 
assign fir_coefficients[29] = 16'h0576; 
assign fir_coefficients[30] = 16'h0576; 
assign fir_coefficients[31] = 16'h0568; 
assign fir_coefficients[32] = 16'h054B; 
assign fir_coefficients[33] = 16'h0520; 
assign fir_coefficients[34] = 16'h04E9; 
assign fir_coefficients[35] = 16'h04A7; 
assign fir_coefficients[36] = 16'h045C; 
assign fir_coefficients[37] = 16'h040A; 
assign fir_coefficients[38] = 16'h03B3; 
assign fir_coefficients[39] = 16'h0359; 
assign fir_coefficients[40] = 16'h02FF; 
assign fir_coefficients[41] = 16'h02A5; 
assign fir_coefficients[42] = 16'h024E; 
assign fir_coefficients[43] = 16'h01FB; 
assign fir_coefficients[44] = 16'h01AD; 
assign fir_coefficients[45] = 16'h0166; 
assign fir_coefficients[46] = 16'h0126; 
assign fir_coefficients[47] = 16'h00ED; 
assign fir_coefficients[48] = 16'h00BC; 
assign fir_coefficients[49] = 16'h0091; 
assign fir_coefficients[50] = 16'h006E; 
assign fir_coefficients[51] = 16'h0051; 
assign fir_coefficients[52] = 16'h003A; 
assign fir_coefficients[53] = 16'h0027; 
assign fir_coefficients[54] = 16'h0019; 
assign fir_coefficients[55] = 16'h000F; 
assign fir_coefficients[56] = 16'h0008; 
assign fir_coefficients[57] = 16'h0003; 
assign fir_coefficients[58] = 16'h0001; 
assign fir_coefficients[59] = 16'h0000;
*/

always_comb begin
    _dsp_port_a         = dsp_port_a;
    _dsp_port_b         = dsp_port_b;
    _dsp_mult_register  = dsp_mult_register;
    _dsp_accum_register = dsp_accum_register;
    //we are using 1.15 fixed point coeffecients so we need to divide by 2^15 to interpret our result
    _filtered_data      = (dsp_accum_register[0] >> (COEF_WIDTH-1));

    //extend input data to PORT_A_WIDTH bits for PORTA of DSP48 SLICE
    for (i=0; i<NUM_TAPS; i=i+1) begin
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


always_ff @(posedge clock or negedge reset_n) begin
    if(!reset_n)begin
        filtered_data               <= 0;

        for(x=0; x<NUM_TAPS; x=x+1)begin
            dsp_port_a[x]           <= 0;
            dsp_port_b[x]           <= 0;
            dsp_mult_register[x]    <= 0;
            dsp_accum_register[x]   <= 0;
        end
    end
    else begin
        dsp_port_a                  <= _dsp_port_a;
        dsp_port_b                  <= _dsp_port_b;
        dsp_mult_register           <= _dsp_mult_register;
        dsp_accum_register          <= _dsp_accum_register;
        filtered_data               <= _filtered_data;
    end
end




endmodule
