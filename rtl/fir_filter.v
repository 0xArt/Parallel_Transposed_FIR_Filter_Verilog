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


(* use_dsp = "yes" *)module fir_filter
#(parameter NUM_TAPS     = 60, 
  parameter DATA_WIDTH   = 16, 
  parameter COEF_WIDTH   = 16, 
  parameter PORT_A_WIDTH = 16,
  parameter PORT_B_WIDTH = 16)
(
        input  wire                          i_clk,
        input  wire                          i_rst,
        input  wire signed [DATA_WIDTH-1:0]  i_data, 
        output reg  signed [DATA_WIDTH-1:0]  o_data = 0
);


integer i,j;

reg signed [PORT_A_WIDTH-1:0] dsp_port_a [NUM_TAPS-1:0]; 
//extend input data to PORT_A_WIDTH bits for PORTA of DSP48 SLICE
always@(posedge i_clk) begin
    if(i_rst)begin
        for(i=0; i<NUM_TAPS; i=i+1)begin
            dsp_port_a[i] <= 0;
        end
    end
    else begin
        for(i=0; i<NUM_TAPS; i=i+1)begin
            for(j=0; j< PORT_A_WIDTH; j=j+1)begin
                if(j<(DATA_WIDTH-1))begin
                    dsp_port_a[i][j] <= i_data[j];
                end
                else begin
                    //twos compliment extension must fill new width with sign bit
                     dsp_port_a[i][j] <= i_data[DATA_WIDTH-1];
                end
            end
        end
    end
end


/*
sim only
reg signed [COEF_WIDTH-1:0]  fir_coefficients [NUM_TAPS-1:0];
initial begin
    $readmemh("FIR_LPF_COEFF.mem", fir_coefficients);
end
*/

//1MHz cutoff Blackman 1.15 fixed point
wire signed [COEF_WIDTH-1:0]  fir_coefficients [NUM_TAPS-1:0];
assign fir_coefficients[0]  = 16'h0000; 
assign fir_coefficients[1]  = 16'h0000; 
assign fir_coefficients[2]  = 16'hFFFE; 
assign fir_coefficients[3]  = 16'hFFFC; 
assign fir_coefficients[4]  = 16'hFFFA; 
assign fir_coefficients[5]  = 16'hFFF7; 
assign fir_coefficients[6]  = 16'hFFF5; 
assign fir_coefficients[7]  = 16'hFFF4; 
assign fir_coefficients[8]  = 16'hFFF6; 
assign fir_coefficients[9]  = 16'hFFFB; 
assign fir_coefficients[10] = 16'h0006; 
assign fir_coefficients[11] = 16'h0019; 
assign fir_coefficients[12] = 16'h0035; 
assign fir_coefficients[13] = 16'h005D; 
assign fir_coefficients[14] = 16'h0093; 
assign fir_coefficients[15] = 16'h00D8; 
assign fir_coefficients[16] = 16'h012D; 
assign fir_coefficients[17] = 16'h0193; 
assign fir_coefficients[18] = 16'h0208; 
assign fir_coefficients[19] = 16'h028C; 
assign fir_coefficients[20] = 16'h031B; 
assign fir_coefficients[21] = 16'h03B2; 
assign fir_coefficients[22] = 16'h044D; 
assign fir_coefficients[23] = 16'h04E5; 
assign fir_coefficients[24] = 16'h0576; 
assign fir_coefficients[25] = 16'h05FA; 
assign fir_coefficients[26] = 16'h066B; 
assign fir_coefficients[27] = 16'h06C5; 
assign fir_coefficients[28] = 16'h0703; 
assign fir_coefficients[29] = 16'h0723; 
assign fir_coefficients[30] = 16'h0723; 
assign fir_coefficients[31] = 16'h0703; 
assign fir_coefficients[32] = 16'h06C5; 
assign fir_coefficients[33] = 16'h066B; 
assign fir_coefficients[34] = 16'h05FA; 
assign fir_coefficients[35] = 16'h0576; 
assign fir_coefficients[36] = 16'h04E5; 
assign fir_coefficients[37] = 16'h044D; 
assign fir_coefficients[38] = 16'h03B2; 
assign fir_coefficients[39] = 16'h031B; 
assign fir_coefficients[40] = 16'h028C; 
assign fir_coefficients[41] = 16'h0208; 
assign fir_coefficients[42] = 16'h0193; 
assign fir_coefficients[43] = 16'h012D; 
assign fir_coefficients[44] = 16'h00D8; 
assign fir_coefficients[45] = 16'h0093; 
assign fir_coefficients[46] = 16'h005D; 
assign fir_coefficients[47] = 16'h0035; 
assign fir_coefficients[48] = 16'h0019; 
assign fir_coefficients[49] = 16'h0006; 
assign fir_coefficients[50] = 16'hFFFB; 
assign fir_coefficients[51] = 16'hFFF6; 
assign fir_coefficients[52] = 16'hFFF4; 
assign fir_coefficients[53] = 16'hFFF5; 
assign fir_coefficients[54] = 16'hFFF7; 
assign fir_coefficients[55] = 16'hFFFA; 
assign fir_coefficients[56] = 16'hFFFC; 
assign fir_coefficients[57] = 16'hFFFE; 
assign fir_coefficients[58] = 16'h0000; 
assign fir_coefficients[59] = 16'h0000;


reg signed [PORT_B_WIDTH-1:0] dsp_port_b [NUM_TAPS-1:0]; 
//extend coeffecient data to PORT_B_WIDTH bits for PORTB of DSP48 SLICE
always@(posedge i_clk) begin
    if(i_rst)begin
        for(i=0; i<NUM_TAPS; i=i+1)begin
            dsp_port_b[i] <= 0;
        end
    end
    else begin
        for(i=0; i<NUM_TAPS; i=i+1)begin
            for(j=0; j< PORT_B_WIDTH; j=j+1)begin
                if(j<(COEF_WIDTH-1))begin
                    dsp_port_b[i][j] <= fir_coefficients[i][j];
                end
                else begin
                    //twos compliment extension must fill new width with sign bit
                     dsp_port_b[i][j] <= fir_coefficients[i][COEF_WIDTH-1];
                end
            end
        end
    end
end


//multiplication stages
reg signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0] dsp_mult_register [NUM_TAPS-1:0];
always@(posedge i_clk) begin
    if(i_rst)begin
        for(i=0; i<NUM_TAPS; i=i+1)begin
            dsp_mult_register[i] <= 0;
        end
    end
    else begin
        for(i=0; i<NUM_TAPS; i=i+1)begin
            dsp_mult_register[i] <= dsp_port_a[i]*dsp_port_b[i];
        end
    end
end

//accumulation stages
reg signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0] dsp_accum_register [NUM_TAPS-1:0];
always@(posedge i_clk) begin
    if(i_rst)begin
        for(i=0; i<NUM_TAPS; i=i+1)begin
            dsp_accum_register[i] <= 0;
        end
    end
    else begin
        for(i=0; i<NUM_TAPS; i=i+1)begin
            if(i == (NUM_TAPS-1))begin
                dsp_accum_register[i] <= dsp_mult_register[i];
            end
            else begin
                dsp_accum_register[i] <= dsp_mult_register[i]+dsp_accum_register[i+1];
            end
        end
    end
end


//output stage
always@(posedge i_clk)begin
    if(i_rst)begin
        o_data <= 0;
    end
    else begin
        //we are using 1.15 fixed point coeffecients so we need to divide by 2^15 to interpret our result
        o_data <= (dsp_accum_register[0] >> (COEF_WIDTH-1));
    end 
end




endmodule
