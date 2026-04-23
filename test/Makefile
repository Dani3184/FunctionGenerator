# Makefile for cocotb simulation (Tiny Tapeout style)

SIM ?= icarus
TOPLEVEL_LANG ?= verilog

# Path to your design
SRC_DIR = $(PWD)/../src

# Your design files
PROJECT_SOURCES = tt_um_gen_onda.v

# RTL sources
VERILOG_SOURCES = $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

# Top module (your DUT)
TOPLEVEL = tt_um_gen_onda

# Python test file (without .py)
MODULE = test

# Optional: include headers
COMPILE_ARGS += -I$(SRC_DIR)

# Include cocotb
include $(shell cocotb-config --makefiles)/Makefile.sim