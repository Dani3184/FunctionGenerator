`timescale 1ns/1ps

module tb;
reg clk = 0;
reg rst_n = 0;
reg [7:0] ui_in = 0;
wire [7:0] uo_out;

tt_um_gen_onda uut (
    .clk(clk), .rst_n(rst_n), .ena(1'b1),
    .ui_in(ui_in), .uo_out(uo_out),
    .uio_in(8'b0), .uio_out(), .uio_oe()
);

always #10 clk = ~clk; // 50MHz o 100MHz, da igual para funcional

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb);
    rst_n = 0; #40; rst_n = 1;

    // Waveforms: Freq=00, Amp=111 (7), Func=0..4
    ui_in = 8'b00_111_000; #5000; // Sine
    ui_in = 8'b00_111_001; #5000; // Saw
    ui_in = 8'b00_111_010; #5000; // Square
    ui_in = 8'b00_111_011; #5000; // Triangle
    ui_in = 8'b00_111_100; #5000; // Quad
    
    $finish;
end
endmodule
