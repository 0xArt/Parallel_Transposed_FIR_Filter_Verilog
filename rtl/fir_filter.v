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
// Description: Piplined Parallel Transposed FIR Filter
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fir_filter
#(parameter NUM_TAPS = 60, 
  parameter DATA_WIDTH = 16, 
  parameter COEF_WIDTH = 16, 
  parameter PORT_A_WIDTH = 18,
  parameter PORT_B_WIDTH = 18)
(
        input  wire                            i_clk,
        input  wire                            i_rst,
        input  wire signed [DATA_WIDTH-1:0]    i_data, 
        output reg signed [PORT_A_WIDTH+PORT_B_WIDTH-1:0]    o_data = 0
);


integer i,j;

reg signed [PORT_A_WIDTH-1:0] dsp_port_a [NUM_TAPS-1:0]; 
//extend input data to PORT_A_WIDTH bits for PORTA of DSP48 SLICE
always@(posedge i_clk) begin
    if(i_rst)begin
        dsp_port_a[i] <= 0;
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

reg signed [COEF_WIDTH-1:0]  fir_coefficients [NUM_TAPS-1:0];
initial begin
    $readmemh("FIR_LPF_COEFF.mem", fir_coefficients);
end

reg signed [PORT_B_WIDTH-1:0] dsp_port_b [NUM_TAPS-1:0]; 
//extend coeffecient data to PORT_B_WIDTH bits for PORTA of DSP48 SLICE
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
        o_data <= dsp_accum_register[0];
    end
end




endmodule
