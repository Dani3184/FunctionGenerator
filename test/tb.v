`timescale 1ns/1ps

//Author: Daniel Roberto Garcia Miranda
//University: Universidad Mayor de San Andres, La Paz Bolivia
//Career: Physics

module tb;
    reg clk = 0;
    reg rst_n = 0;
    reg ena = 1;
    reg [7:0] ui_in = 0;
    wire [7:0] uo_out;

    // Unit Under Test instantiation
    tt_um_gen_onda uut (
        .clk(clk), .rst_n(rst_n), .ena(ena), .ui_in(ui_in), .uo_out(uo_out),
        .uio_in(8'b0), .uio_out(), .uio_oe()
    );

    // Clock generation (50MHz)
    always #10 clk = ~clk;

    // Task to set inputs and display status
    task set_mode;
        input [7:0] mode;
        input [1023:0] name;
        begin
            @(negedge clk); 
            ui_in = mode;
            $display("--- TIME: %0t --- MODE: %0s --- ui_in: %h", $time, name, mode);
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        // System Reset
        rst_n = 0; repeat(10) @(posedge clk); rst_n = 1;
        repeat(5) @(posedge clk);
        
        // TEST 1: All Waveforms (Freq=00, Amp=100%)
        set_mode(8'b00_111_000, "SINE");      repeat(1024) @(posedge clk);
        set_mode(8'b00_111_001, "SAWTOOTH");  repeat(1024) @(posedge clk);
        set_mode(8'b00_111_010, "SQUARE");    repeat(1024) @(posedge clk);
        set_mode(8'b00_111_011, "TRIANGLE");  repeat(1024) @(posedge clk);
        set_mode(8'b00_111_100, "QUADRATIC"); repeat(1024) @(posedge clk);

        // TEST 2: Amplitude Sweep (Sine Wave)
        set_mode(8'b00_000_000, "SINE 12.5%"); repeat(1024) @(posedge clk);
        set_mode(8'b00_001_000, "SINE 25%");   repeat(1024) @(posedge clk);
        set_mode(8'b00_010_000, "SINE 50%");   repeat(1024) @(posedge clk);

        // TEST 3: Frequency Sweep (Square Wave)
        set_mode(8'b00_111_010, "SQ FREQ 00 (SLOW)");   repeat(1024) @(posedge clk);
        set_mode(8'b01_111_010, "SQ FREQ 01 (MEDIUM)"); repeat(1024) @(posedge clk);
        set_mode(8'b10_111_010, "SQ FREQ 10 (HIGH)");   repeat(1024) @(posedge clk);
        set_mode(8'b11_111_010, "SQ FREQ 11 (MAX)");    repeat(1024) @(posedge clk);

        $display(">>> ALL SIMULATIONS FINISHED <<<");
        $finish;
    end
endmodule
