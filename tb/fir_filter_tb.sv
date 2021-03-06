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


module fir_filter_tb(

    );
    
    
    reg clk = 0;
    reg rst = 0;    
    wire signed [15:0] sine_wave;
    reg [31:0] phase_step = 16'd50;
    wire signed [15:0] filtered_sine_wave;

        
    //clock gen
    always begin
        #10
        clk = ~clk;
    end
    
    integer i;

    
    initial begin
    
        rst = 1;
        @(posedge clk);
        @(posedge clk);
        rst = 0;
        @(posedge clk);
        
        //sweep up in frequency
        for(i=32'h000FFFFF; i<32'hFFFFFFFF; i=i+32'h00100000)begin
            phase_step = i;
            repeat (500)begin
                @(posedge clk);
            end 
        end
        $stop;

    end
    
    

    sine_wave_gen_quarter sine_wave_gen_quarter_inst(
        .i_clk(clk),
        .i_rst(rst),
        .i_phase_step(phase_step),
        .o_gen_out(sine_wave)
    );
    
    
    
    fir_filter fir_filter_inst(
         .i_clk(clk)
        ,.i_rst(rst)
        ,.i_data(sine_wave)
        ,.o_data(filtered_sine_wave)
    );
    
    

endmodule
