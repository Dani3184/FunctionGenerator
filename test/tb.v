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
    #10;

    // =====================
    // Waveform tests
    // =====================

    ui_in = 8'b11_100_000; #100; // Sine
    ui_in = 8'b11_100_001; #100; // Sawtooth
    ui_in = 8'b11_100_010; #100; // Square
    ui_in = 8'b11_100_011; #100; // Triangle
    ui_in = 8'b11_100_100; #120; // Quadratic

    // =====================
    // Frequency sweep
    // =====================
    ui_in[5:0] = 6'100000; // Sine + fixed amplitude

    ui_in[7:6] = 2'b00; #40;
    ui_in[7:6] = 2'b01; #40;
    ui_in[7:6] = 2'b10; #40;
    ui_in[7:6] = 2'b11; #40;

    // =====================
    // Amplitude sweep
    // =====================
    ui_in[7:6] = 2'b01; // Fixed frequency
    ui_in[2:0] = 3'b000; // Sine

    ui_in[5:3] = 3'b001; #30;
    ui_in[5:3] = 3'b010; #30;
    ui_in[5:3] = 3'b100; #30;
    ui_in[5:3] = 3'b111; #30;

    $finish;
end

endmodule


endmodule
