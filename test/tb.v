`timescale 1ns/1ps

module tb;

reg clk = 0;
reg rst_n = 0;
reg [7:0] ui_in = 0;
wire [7:0] uo_out;

// DUT
tt_um_gen_onda uut (
    .clk(clk),
    .rst_n(rst_n),
    .ena(1'b1),   // ✅ FIX CLAVE
    .ui_in(ui_in),
    .uo_out(uo_out),
    .uio_in(8'b0),
    .uio_out(),
    .uio_oe()
);

// Clock 100 MHz
always #5 clk = ~clk;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb);
end

initial begin
    rst_n = 0;
    #20;
    rst_n = 1;

    // Waveforms
    ui_in = 8'b000_100_01; #5000;
    ui_in = 8'b001_111_10; #5000;
    ui_in = 8'b010_111_11; #5000;
    ui_in = 8'b011_011_10; #5000;
    ui_in = 8'b100_111_01; #5000;

    // Frequency sweep
    ui_in[5:0] = 6'b000100;

    ui_in[7:6] = 2'b00; #4000;
    ui_in[7:6] = 2'b01; #4000;
    ui_in[7:6] = 2'b10; #4000;
    ui_in[7:6] = 2'b11; #4000;

    // Amplitude sweep
    ui_in[7:6] = 2'b01;
    ui_in[2:0] = 3'b000;

    ui_in[5:3] = 3'b001; #3000;
    ui_in[5:3] = 3'b010; #3000;
    ui_in[5:3] = 3'b100; #3000;
    ui_in[5:3] = 3'b111; #3000;

    $finish;
end

endmodule


