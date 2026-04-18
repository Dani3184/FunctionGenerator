module tt_um_gen_onda (
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out
);

// Entradas
wire [2:0] func_sel  = ui_in[2:0]; //Selector de funcion
wire [2:0] amp_ctrl  = ui_in[5:3]; //Selector de amplitud
wire [1:0] freq_ctrl = ui_in[7:6]; // Frecuencia

// Evita amplitud 0
wire [2:0] amp_safe = (amp_ctrl == 0) ? 3'd1 : amp_ctrl;

// Frecuencia
reg [15:0] phase_acc;
reg [15:0] freq_word;

always @(*) begin
    case (freq_ctrl)
        2'b00:   freq_word = 16'd100; // Frecuencia baja
        2'b01:   freq_word = 16'd500;
        2'b10:   freq_word = 16'd2000;
        2'b11:   freq_word = 16'd8000;
        default: freq_word = 16'd100; // Frecuencia alta
    endcase
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        phase_acc <= 16'd0;
    else
        phase_acc <= phase_acc + freq_word;
end

// Fase
wire [7:0] phase = phase_acc[15:8];

// Salida de la funcion seno
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

// Selector de onda
reg [7:0] y_func;

always @(*) begin
    case (func_sel)
        3'b000: y_func = sine_out; //Funcion seno
        3'b001: y_func = phase; // Funcion sierra
        3'b010: y_func = phase[7] ? 8'd255 : 8'd0; //Funion onda cuadrada
        3'b011: y_func = phase[7] ? (~phase << 1) : (phase << 1); // Funcion triangulo
        3'b100: y_func = (phase * phase) >> 8; // Funcion Cuadrática
        default: y_func = 8'd0;
    endcase
end

// Amplitud
wire [10:0] mult_result = y_func * amp_safe;

// Fix wire/reg
reg [7:0] uo_out_reg;
assign uo_out = uo_out_reg;

always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        uo_out_reg <= 8'd0;
    else
        uo_out_reg <= mult_result[10:3]; // Desplazamiento >> 3
end

endmodule