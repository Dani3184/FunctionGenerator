`timescale 1ns/1ps

module tb;

reg clk = 0;
reg rst_n = 0;
reg [7:0] ui_in = 0;
wire [7:0] uo_out;

tt_um_gen_onda uut (
    .clk(clk),
    .rst_n(rst_n),
    .ena(1'b1),  
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(8'b0),
    .uio_out(),
    .uio_oe()
);

always #5 clk = ~clk;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb);
end

initial begin
    rst_n = 0;
    #20;
    rst_n = 1;

    // --- Waveforms Test ---
    // Format: 8'b[Freq][Amp][Func]
    ui_in = 8'b00_100_000; #5000; // Sine, Amp 100, Freq 00
    ui_in = 8'b00_100_001; #5000; // Saw, Amp 100, Freq 00
    ui_in = 8'b00_100_010; #5000; // Square, Amp 100, Freq 00
    ui_in = 8'b00_100_011; #5000; // Triangle, Amp 100, Freq 00
    ui_in = 8'b00_100_100; #5000; // Quadratic, Amp 100, Freq 00

    // --- Frequency sweep ---
    ui_in[2:0] = 3'b001; // Fix to Sawtooth
    ui_in[5:3] = 3'b100; // Fix Amplitude

    ui_in[7:6] = 2'b00; #4000;
    ui_in[7:6] = 2'b01; #4000;
    ui_in[7:6] = 2'b10; #4000;
    ui_in[7:6] = 2'b11; #4000;

    // --- Amplitude sweep ---
    ui_in[7:6] = 2'b01; // Fix Frequency
    ui_in[2:0] = 3'b000; // Fix to Sine

    ui_in[5:3] = 3'b001; #3000;
    ui_in[5:3] = 3'b010; #3000;
    ui_in[5:3] = 3'b100; #3000;
    ui_in[5:3] = 3'b111; #3000;

    $finish;
end

endmodule
