`timescale 1ns / 1ps
`default_nettype none
//Author: Daniel Roberto Garcia Miranda
//University: Universidad Mayor de San Andres, La Paz Bolivia
//Career: Physics
//Date: April 24th, 2026
module tt_um_gen_onda (
    input  wire        clk,      
    input  wire        rst_n,    
    input  wire        ena,      
    input  wire [7:0]  ui_in,    // Mapping: [Freq(7:6) | Amp(5:3) | Func(2:0)]
    output wire [7:0]  uo_out,   
    input  wire [7:0]  uio_in,   
    output wire [7:0]  uio_out,  
    output wire [7:0]  uio_oe    
);

assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

wire [1:0] freq_ctrl = ui_in[7:6];
wire [2:0] amp_ctrl  = ui_in[5:3];
wire [2:0] func_sel  = ui_in[2:0];

// DDS Core (Phase Accumulator)
reg [15:0] phase_acc;
reg [15:0] freq_word;

// Frequency control word selection
always @(*) begin
    case (freq_ctrl)
        2'b00: freq_word = 16'd128;  
        2'b01: freq_word = 16'd512;
        2'b10: freq_word = 16'd1024;
        2'b11: freq_word = 16'd4096;
        default: freq_word = 16'd128;
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) phase_acc <= 16'd0;
    else if (ena) phase_acc <= phase_acc + freq_word;
end

wire [7:0] phase = phase_acc[15:8];

// Sine LUT module
reg [7:0] sine_out;
always @(*) begin
    case (phase[7:4])
        4'h0: sine_out = 8'd128; 4'h1: sine_out = 8'd176;
        4'h2: sine_out = 8'd218; 4'h3: sine_out = 8'd245;
        4'h4: sine_out = 8'd255; 4'h5: sine_out = 8'd245;
        4'h6: sine_out = 8'd218; 4'h7: sine_out = 8'd176;
        4'h8: sine_out = 8'd128; 4'h9: sine_out = 8'd80;
        4'hA: sine_out = 8'd38;  4'hB: sine_out = 8'd11;
        4'hC: sine_out = 8'd0;   4'hD: sine_out = 8'd11;
        4'hE: sine_out = 8'd38;  4'hF: sine_out = 8'd80;
        default: sine_out = 8'd128;
    endcase
end

// Waveform Selector
reg [7:0] y_func;
always @(*) begin
    case (func_sel)
        3'b000: y_func = sine_out; // Sine (LUT)
        
        // Square Wave based on Phase MSB
        3'b010: begin 
            if (phase < 8'd128)
                y_func = 8'hFF; // High for first half
            else
                y_func = 8'h00; // Low for second half
        end
        
        // Triangle Wave logic
        3'b011: y_func = phase[7] ? (~(phase << 1)) : (phase << 1);
        
        // Sawtooth Wave
        3'b001: y_func = phase; 
        
        // Quadratic Wave (Parabolic shape)
        3'b100: begin 
            // 16-bit intermediate calculation to avoid overflow before shift
            y_func = ( ({8'b0, phase} * {8'b0, phase}) >> 8 );
        end
        
        default: y_func = sine_out;
    endcase
end

// Amplitude Scaling Logic
reg [7:0] scaled;
always @(*) begin
    case (amp_ctrl)
        3'b000:  scaled = y_func >> 3; // 12.5%
        3'b001:  scaled = y_func >> 2; // 25%
        3'b010:  scaled = y_func >> 1; // 50%
        3'b111:  scaled = y_func;      // 100%
        default: scaled = y_func;
    endcase
end

// Registered Output
reg [7:0] uo_out_reg;
assign uo_out = uo_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) uo_out_reg <= 8'd0;
    else if (ena) uo_out_reg <= scaled;
end

endmodule
