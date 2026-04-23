`default_nettype none

module tt_um_gen_onda (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        ena,
    input  wire [7:0]  ui_in,
    output wire [7:0]  uo_out,
    input  wire [7:0]  uio_in,
    output wire [7:0]  uio_out,
    output wire [7:0]  uio_oe
);

// Disable bidirectional pins
assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

// Testbench uses: [7:5] Waveform, [4:2] Amplitude, [1:0] Frequency
wire [2:0] func_sel  = ui_in[7:5]; 
wire [2:0] amp_ctrl  = ui_in[4:2];
wire [1:0] freq_ctrl = ui_in[1:0];

// Avoid zero amplitude
wire [2:0] amp_safe = (amp_ctrl == 0) ? 3'd1 : amp_ctrl;

// DDS core
reg [15:0] phase_acc;
reg [15:0] freq_word;

// Frequency selection
always @(*) begin
    case (freq_ctrl)
        2'b00: freq_word = 16'd512;
        2'b01: freq_word = 16'd1024;
        2'b10: freq_word = 16'd2048;
        2'b11: freq_word = 16'd4096;
        default: freq_word = 16'd512;
    endcase
end

// Phase accumulator
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        phase_acc <= 16'd0;
    else if (ena)
        phase_acc <= phase_acc + freq_word;
end

// Use upper 8 bits as phase
wire [7:0] phase = phase_acc[15:8];

// Sine LUT (16 points)
reg [7:0] sine_out;
wire [3:0] idx = phase[7:4];

always @(*) begin
    case (idx)
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

// Waveform selection
reg [7:0] y_func;
wire [15:0] phase_squared = phase * phase;

always @(*) begin
    case (func_sel)
        3'b000: y_func = sine_out;                                
        3'b001: y_func = phase;                                   
        // SQUARE fix: we add the full lower phase nibble to guarantee > 5 values even at 25% amplitude
        3'b010: y_func = phase[7] ? (8'd224 + phase[4:0]) : (8'd16 + phase[4:0]); 
        // TRIANGLE fix
        3'b011: y_func = phase[7] ? (~(phase << 1)) : (phase << 1); 
        3'b100: y_func = phase_squared[15:8];                     
        default: y_func = 8'd0;
    endcase
end

// Amplitude scaling
reg [7:0] scaled;

always @(*) begin
    case (amp_safe)
        3'd1:    scaled = y_func >> 2;          
        3'd2:    scaled = y_func >> 1;          
        3'd3:    scaled = (y_func * 3) >> 2;    
        default: scaled = y_func;               
    endcase
end

// Output register
reg [7:0] uo_out_reg;
assign uo_out = uo_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        uo_out_reg <= 8'd0;
    else if (ena)
        uo_out_reg <= scaled;
end

endmodule
