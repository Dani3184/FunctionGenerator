`timescale 1ns/1ps

module tb;

reg clk = 0;
reg rst_n = 0;
reg [7:0] ui_in = 0;
wire [7:0] uo_out;

// DUT instance
tt_um_gen_onda uut (
    .clk(clk),
    .rst_n(rst_n),
    .ui_in(ui_in),
    .uo_out(uo_out)
);

// 100 MHz clock
always #5 clk = ~clk;

// Dump waveforms
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb);
end

// Main test sequence
initial begin
    // Reset
    rst_n = 0;
    #20;
    rst_n = 1;

    // =====================
    // Waveform tests
    // =====================

    ui_in = 8'b000_100_01; #5000; // Sine
    ui_in = 8'b001_111_10; #5000; // Sawtooth
    ui_in = 8'b010_111_11; #5000; // Square
    ui_in = 8'b011_011_10; #5000; // Triangle
    ui_in = 8'b100_111_01; #5000; // Quadratic

    // =====================
    // Frequency sweep
    // =====================
    ui_in[5:0] = 6'b000100; // Sine + fixed amplitude

    ui_in[7:6] = 2'b00; #4000;
    ui_in[7:6] = 2'b01; #4000;
    ui_in[7:6] = 2'b10; #4000;
    ui_in[7:6] = 2'b11; #4000;

    // =====================
    // Amplitude sweep
    // =====================
    ui_in[7:6] = 2'b01; // Fixed frequency
    ui_in[2:0] = 3'b000; // Sine

    ui_in[5:3] = 3'b001; #3000;
    ui_in[5:3] = 3'b010; #3000;
    ui_in[5:3] = 3'b100; #3000;
    ui_in[5:3] = 3'b111; #3000;

    $finish;
end

endmodule


endmodule
