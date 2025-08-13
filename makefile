# Makefile for Verilator simulation

# Top-level module name of your Verilog/SystemVerilog project
TOP_MODULE = proj5_bruno_5

# Verilog/SystemVerilog sources
VERILOG_SOURCES = proj5_bruno_5.sv

# C++ testbench sources
CPP_SOURCES = proj5_bruno_6.cpp

# Final executable name
TARGET = sim

# Verilator command to specify C++ output mode
VERILATOR_CMD = verilator --cc --trace -exe --top-module $(TOP_MODULE) $(VERILOG_SOURCES) $(CPP_SOURCES)

# --- Make Rules ---

# Default rule: compile everything
all: $(TARGET)

# Rule to create the simulation executable
$(TARGET): $(VERILOG_SOURCES) $(CPP_SOURCES)
	$(VERILATOR_CMD)
	$(MAKE) -C obj_dir -f V$(TOP_MODULE).mk
	cp obj_dir/V$(TOP_MODULE) $(TARGET)

# Rule to run the simulation
run: $(TARGET)
	@echo "Running simulation..."
	./$(TARGET)

# Rule to open GTKWave with the waveform file
wave:
	@echo "Opening GTKWave..."
	gtkwave waveform.vcd

# Rule to clean up generated files
clean:
	@echo "Cleaning up generated files..."
	rm -rf obj_dir $(TARGET) waveform.vcd

.PHONY: all run wave clean
