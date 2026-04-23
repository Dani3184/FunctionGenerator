module tt_um_gen_onda (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       ena,
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe
);

// Disable bidirectional pins (not used)
assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

// Input decoding
// ui_in[2:0] -> waveform selection
// ui_in[5:3] -> amplitude control
// ui_in[7:6] -> frequency control

wire [2:0] func_sel  = ui_in[2:0];
wire [2:0] amp_ctrl  = ui_in[5:3];
wire [1:0] freq_ctrl = ui_in[7:6];

// Prevent zero amplitude (avoid constant output)
wire [2:0] amp_safe = (amp_ctrl == 0) ? 3'd1 : amp_ctrl;

// DDS (Direct Digital Synthesis) core
reg [15:0] phase_acc;
reg [15:0] freq_word;

// Frequency selection
// Values are intentionally large to ensure visible changes
always @(*) begin
    case (freq_ctrl)
        2'b00: freq_word = 16'd500;
        2'b01: freq_word = 16'd2000;
        2'b10: freq_word = 16'd8000;
        2'b11: freq_word = 16'd20000;
        default: freq_word = 16'd500;
    endcase
end

// Phase accumulator
// Increments every clock cycle when enabled
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        phase_acc <= 16'd0;
    else if (ena)
        phase_acc <= phase_acc + freq_word;
end

// Use the most significant 8 bits as phase output
wire [7:0] phase = phase_acc[15:8];

// Sine approximation (cheap, no LUT)
// Uses symmetry to generate a triangular sine-like shape
reg [7:0] sine_out;

always @(*) begin
    if (phase < 8'd128)
        sine_out = phase;
    else
        sine_out = 8'd255 - phase;
end

// Waveform generator
reg [7:0] y_func;
wire [15:0] phase_squared = phase * phase;

always @(*) begin
    case (func_sel)
        3'b000: y_func = sine_out;                               // pseudo sine
        3'b001: y_func = phase;                                  // sawtooth
        3'b010: y_func = phase[7] ? 8'd255 : 8'd0;               // square
        3'b011: y_func = phase[7] ? (255 - (phase << 1)) 
                                 : (phase << 1);                // triangle
        3'b100: y_func = phase_squared[15:8];                    // quadratic
        default: y_func = 8'd0;
    endcase
end

// Amplitude scaling
// Simple linear scaling to preserve variation
reg [7:0] scaled;

always @(*) begin
    scaled = (y_func * amp_safe) >> 2;
end

// Output register (synchronous)
reg [7:0] uo_out_reg;
assign uo_out = uo_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        uo_out_reg <= 8'd0;
    else if (ena)
        uo_out_reg <= scaled;
end

endmodule
