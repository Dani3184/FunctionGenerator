# DDS Waveform Generator

## Descripción
Este proyecto implementa un generador digital de señales basado en DDS (Direct Digital Synthesizer).
Genera múltiples formas de onda con control de frecuencia y amplitud mediante una interfaz de 8 bits.

## Características
- Generación de:
  - Seno (LUT)
  - Diente de sierra
  - Onda cuadrada
  - Onda triangular
  - Función cuadrática
- Control digital completo mediante `ui_in`
- Salida de 8 bits lista para DAC

## Interfaz

### Entradas
- `clk` → reloj
- `rst_n` → reset activo en bajo
- `ui_in[7:0]` → control

### Mapeo de `ui_in`
- `ui_in[2:0]` → selección de función
- `ui_in[5:3]` → amplitud
- `ui_in[7:6]` → frecuencia

### Salida
- `uo_out[7:0]` → señal digital

## Funcionamiento
El diseño utiliza un acumulador de fase (DDS) para generar señales periódicas.
Dependiendo de la configuración, se selecciona la forma de onda y se escala su amplitud.

## Uso
El valor de `uo_out` puede conectarse a:
- un DAC (por ejemplo R-2R)
- un osciloscopio
- un sistema digital

## Aplicaciones
- Generadores de señal
- Instrumentación digital
- Sistemas embebidos