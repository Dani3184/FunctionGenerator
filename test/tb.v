`timescale 1ns/1ps

module tb;

reg clk = 0;
reg rst_n = 0;
reg [7:0] ui_in = 0;
wire [7:0] uo_out;

// Instancia
tt_um_gen_onda uut (
    .clk(clk),
    .rst_n(rst_n),
    .ui_in(ui_in),
    .uo_out(uo_out)
);

// Clock 100MHz
always #5 clk = ~clk;


initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb);
end

// Test principal
initial begin
    // Reset
    rst_n = 0;
    #20;
    rst_n = 1;
//Funciones
    
    // SENO
    ui_in = 8'b000_100_01; // func=000, amp=4, freq=1
    #5000;

    // SIERRA
    ui_in = 8'b001_111_10; // amp alta, freq media
    #5000;

    // CUADRADA
    ui_in = 8'b010_111_11;
    #5000;

    // TRIANGULAR
    ui_in = 8'b011_011_10;
    #5000;

    // CUADRÁTICA
    ui_in = 8'b100_111_01;
    #5000;

// Otra frecuencia
    ui_in[5:0] = 6'b000100; // seno + amp fija

    ui_in[7:6] = 2'b00; #4000;
    ui_in[7:6] = 2'b01; #4000;
    ui_in[7:6] = 2'b10; #4000;
    ui_in[7:6] = 2'b11; #4000;

    // =====================
    // SWEEP DE AMPLITUD
    // =====================
    ui_in[7:6] = 2'b01; // freq fija
    ui_in[2:0] = 3'b000; // seno

    ui_in[5:3] = 3'b001; #3000;
    ui_in[5:3] = 3'b010; #3000;
    ui_in[5:3] = 3'b100; #3000;
    ui_in[5:3] = 3'b111; #3000;

    // =====================
    $finish;
end

endmodule