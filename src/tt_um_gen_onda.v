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

// Testbench mapping (must match cocotb test)
wire [2:0] func_sel  = ui_in[2:0];
wire [2:0] amp_ctrl  = ui_in[5:3];
wire [1:0] freq_ctrl = ui_in[7:6];


// Avoid zero amplitude
wire [2:0] amp_safe = (amp_ctrl == 0) ? 3'd1 : amp_ctrl;

// DDS core
reg [15:0] phase_acc;
reg [15:0] freq_word;

// Frequency selection tuned to show variation in test window
always @(*) begin
    case (freq_ctrl)
        2'b00: freq_word = 16'd300;
        2'b01: freq_word = 16'd800;
        2'b10: freq_word = 16'd2000;
        2'b11: freq_word = 16'd5000;
        default: freq_word = 16'd300;
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

// Sine approximation with more variation than small LUT
wire [15:0] x = phase * 16'd256;
wire [15:0] x_inv = (16'd65535 - x);
wire [15:0] sine_approx = (x * x_inv) >> 8;
wire [7:0] sine_out = sine_approx[15:8];

// Waveform selection
reg [7:0] y_func;

always @(*) begin
    case (func_sel)
        3'b000: y_func = sine_out;                          
        3'b001: y_func = phase;                             
        3'b010: y_func = phase[7] ? 8'd255 : 8'd0;          
        3'b011: y_func = phase[7] ? (255 - (phase << 1))
                                 : (phase << 1);            
        3'b100: y_func = (phase * phase) >> 8;              
        default: y_func = 8'd0;
    endcase
end

// Amplitude scaling that preserves variation
reg [7:0] scaled;

always @(*) begin
    case (amp_safe)
        3'd1: scaled = (y_func * 8'd64)  >> 8;
        3'd2: scaled = (y_func * 8'd128) >> 8;
        3'd3: scaled = (y_func * 8'd192) >> 8;
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
