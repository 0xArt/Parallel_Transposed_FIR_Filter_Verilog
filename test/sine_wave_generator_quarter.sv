`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
// 
// Create Date: 07/05/2021 07:07:53 PM
// Design Name: 
// Module Name: sine_wave_generator_quarter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Use a quarter wave lookup table to generate a sine wave
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module sine_wave_generator_quarter#(
    parameter ROM_DEPTH         = 32768,
    parameter ROM_WIDTH         = 16,
    parameter PHASE_STEP_WIDTH  = 32
)(
    input   wire                                clock,
    input   wire                                reset_n,
    input   wire                                enable,
    input   wire        [PHASE_STEP_WIDTH-1:0]  phase_step,

    output  reg signed  [ROM_WIDTH-1:0]         generated_wave,
    output  reg                                 generated_wave_valid
);

reg signed [ROM_WIDTH-1:0] memory [ROM_DEPTH-1:0];
initial begin
    $readmemh("./test/16x32768_sine_lut_quarter.mem", memory);
end

logic           [PHASE_STEP_WIDTH-1:0]          _accumulator;
reg             [PHASE_STEP_WIDTH-1:0]          accumulator;
logic           [$clog2(ROM_DEPTH)-1+2:0]       index;
logic                                           reverse;
logic                                           invert;
logic           [$clog2(ROM_DEPTH)-1:0]         look_up_table_index;
logic signed    [ROM_WIDTH-1:0]                 _generated_wave;
logic                                           _generated_wave_valid;

always_comb begin
    _generated_wave_valid   = 0;
    index                   = accumulator[PHASE_STEP_WIDTH-1:(PHASE_STEP_WIDTH-1) - ($clog2(ROM_DEPTH)-1+2)];
    reverse                 = index[$clog2(ROM_DEPTH)];
    invert                  = index[$clog2(ROM_DEPTH)+1];

    if  (enable) begin
        _accumulator            = accumulator + phase_step;
        _generated_wave_valid   = 1;
    end

    if (reverse) begin
        look_up_table_index =   (ROM_DEPTH-1) - index[$clog2(ROM_DEPTH)-1:0];
    end
    else begin
        look_up_table_index =   index[$clog2(ROM_DEPTH)-1:0];
    end

    if (invert) begin
        _generated_wave = -memory[look_up_table_index];
    end
    else begin
        _generated_wave = memory[look_up_table_index];
    end
end

always_ff @(posedge clock or negedge reset_n) begin
    if (!reset_n) begin
        accumulator             <= 0;
        generated_wave          <= 0;
        generated_wave_valid    <= 0;
    end
    else begin
        accumulator             <= _accumulator;
        generated_wave          <= _generated_wave;
        generated_wave_valid    <= _generated_wave_valid;
    end
end

endmodule