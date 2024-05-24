`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:     www.circuitden.com
// Engineer:    Artin Isagholian
//              artinisagholian@gmail.com
// 
// Create Date: 10/14/2021 01:42:11 PM
// Design Name: 
// Module Name: fir_filter_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module testbench;

localparam  CLOCK_FREQUENCY             =   100_000_000;
localparam  CLOCK_PERIOD                =   1e9/CLOCK_FREQUENCY;
localparam  ROM_DEPTH                   =   32768;
localparam  ROM_WIDTH                   =   16;
localparam  PHASE_STEP_WIDTH            =   32;
localparam  COEFFECIENT_WIDTH           =   16;
localparam  FIR_FILTER_NUMBER_OF_TAPS   =   60;


logic                           clock                   = 0;
logic                           reset_n                 = 1;
logic [PHASE_STEP_WIDTH-1:0]    test_phase_step         = 888;
integer                         i;
logic [16:0]                    test_output;


initial begin
    clock   =   0;

    forever begin
        #(CLOCK_PERIOD/2);
        clock   =   ~clock;
    end
end

initial begin
    reset_n =   0;
    repeat(100) @(posedge clock);
    reset_n =   1;
end

initial begin
    wait(reset_n);
    repeat(100) @(posedge clock);
    
    //sweep up in frequency
    //-3dB point with 2MHz cutoff Blackman filter occurs at 'h62fffff
    for (i=32'h000FFFFF; i<32'hFFFFFFFF; i=i+32'h00100000) begin
        test_phase_step = i;

        repeat(500) @(posedge clock);
    end
    $stop();
end


wire                            sine_wave_generator_quarter_clock;
wire                            sine_wave_generator_quarter_reset_n;
wire                            sine_wave_generator_enable;
wire    [PHASE_STEP_WIDTH-1:0]  sine_wave_generator_quarter_phase_step;

wire    [ROM_WIDTH-1:0]         sine_wave_generator_quarter_generated_wave;
wire                            sine_wave_generator_generated_wave_valid;

sine_wave_generator_quarter #(
    .ROM_DEPTH          (ROM_DEPTH),
    .ROM_WIDTH          (ROM_WIDTH),
    .PHASE_STEP_WIDTH   (PHASE_STEP_WIDTH)
)
sine_wave_generator_quarter(
    .clock                  (sine_wave_generator_quarter_clock),
    .reset_n                (sine_wave_generator_quarter_reset_n),
    .enable                 (sine_wave_generator_enable),
    .phase_step             (sine_wave_generator_quarter_phase_step),

    .generated_wave         (sine_wave_generator_quarter_generated_wave),
    .generated_wave_valid   (sine_wave_generator_generated_wave_valid)
);


wire                                    fir_filter_clock;
wire                                    fir_filter_reset_n;
wire [ROM_WIDTH-1:0]                    fir_filter_data;
wire                                    fir_filter_enable;

wire [ROM_WIDTH+COEFFECIENT_WIDTH-1:0]  fir_filter_filtered_data;
wire                                    fir_filter_filtered_data_valid;

fir_filter #(
    .NUM_TAPS       (FIR_FILTER_NUMBER_OF_TAPS),
    .DATA_WIDTH     (ROM_WIDTH),
    .COEF_WIDTH     (COEFFECIENT_WIDTH),
    .PORT_A_WIDTH   (ROM_WIDTH),
    .PORT_B_WIDTH   (ROM_WIDTH)
)
fir_filter(
    .clock                  (fir_filter_clock),
    .reset_n                (fir_filter_reset_n),
    .data                   (fir_filter_data),
    .enable                 (fir_filter_enable),

    .filtered_data          (fir_filter_filtered_data),
    .filtered_data_valid    (fir_filter_filtered_data_valid)
);


assign fir_filter_clock                         = clock;
assign fir_filter_reset_n                       = reset_n;
assign fir_filter_data                          = sine_wave_generator_quarter_generated_wave;
assign fir_filter_enable                        = sine_wave_generator_generated_wave_valid;

assign sine_wave_generator_quarter_clock        = clock;
assign sine_wave_generator_quarter_reset_n      = reset_n;
assign sine_wave_generator_enable               = 1;
assign sine_wave_generator_quarter_phase_step   = test_phase_step;

assign test_output                              = fir_filter_filtered_data;

endmodule