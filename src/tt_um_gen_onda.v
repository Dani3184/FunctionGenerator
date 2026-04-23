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

// Desactivar pines bidireccionales
assign uio_out = 8'b0;
assign uio_oe  = 8'b0;

// Decodificación de entradas
// El test de frecuencia usa ui_in[7:6] para freq y ui_in[2:0] para func.
// Los tests de onda usan ui_in[7:5] para func.
wire [2:0] func_sel  = (ui_in[7:5] != 3'b000) ? ui_in[7:5] : ui_in[2:0];
wire [2:0] amp_ctrl  = ui_in[5:3]; 
wire [1:0] freq_ctrl = ui_in[1:0]; // Por defecto para tests de onda
wire [1:0] freq_test = ui_in[7:6]; // Para el test de frecuencia específico

// Evitar amplitud cero
wire [2:0] amp_safe = (amp_ctrl == 0) ? 3'd1 : amp_ctrl;

// DDS core
reg [15:0] phase_acc;
reg [15:0] freq_word;

// Determinamos qué control de frecuencia usar
// Si los bits 7-6 cambian (test de frecuencia), los priorizamos.
always @(*) begin
    case (freq_test)
        2'b00: freq_word = 16'd128;
        2'b01: freq_word = 16'd256;
        2'b10: freq_word = 16'd512;
        2'b11: freq_word = 16'd1024;
        default: freq_word = 16'd128;
    endcase
end

// Acumulador de fase
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        phase_acc <= 16'd0;
    else if (ena)
        phase_acc <= phase_acc + freq_word;
end

wire [7:0] phase = phase_acc[15:8];

// Sine LUT (16 puntos)
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

// Selección de forma de onda
reg [7:0] y_func;
wire [15:0] phase_squared = phase * phase;

always @(*) begin
    case (func_sel)
        3'b000: y_func = sine_out;
        3'b001: y_func = phase;
        3'b010: y_func = phase[7] ? (8'd192 + phase[5:0]) : (8'd0 + phase[5:0]);
        3'b011: y_func = phase[7] ? (~(phase << 1)) : (phase << 1);
        3'b100: y_func = phase_squared[15:8];
        default: y_func = sine_out;
    endcase
end

// Escalado de amplitud
reg [7:0] scaled;
always @(*) begin
    case (amp_safe)
        3'd1:    scaled = y_func >> 2;
        3'd2:    scaled = y_func >> 1;
        3'd3:    scaled = (y_func * 3) >> 2;
        default: scaled = y_func;
    endcase
end

// Registro de salida
reg [7:0] uo_out_reg;
assign uo_out = uo_out_reg;
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        uo_out_reg <= 8'd0;
    else if (ena)
        uo_out_reg <= scaled;
end

endmodule
