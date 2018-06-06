# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./mux2_1.sv"
vlog "./D_FF.sv"
vlog "./enableD_FF.sv"
vlog "./individualReg64.sv"
vlog "./fullReg32x64.sv"
vlog "./decoder2x4.sv"
vlog "./decoder1x2.sv"
vlog "./decoder4x16.sv"
vlog "./decoder5x32.sv"
vlog "./mux4x1.sv"
vlog "./mux8x1.sv"
vlog "./mux16x1.sv"
vlog "./mux32x1.sv"
vlog "./mux32x64.sv"
vlog "./regfile.sv"
vlog "./fullAdder.sv"
vlog "./bitSlice.sv"
vlog "./orGate16.sv"
vlog "./alu.sv"
vlog "./signExtend19.sv"
vlog "./signExtend26.sv"
vlog "./mux2x64.sv"
vlog "./shiftLeft2.sv"
vlog "./adder64.sv"
vlog "./instructionFetch.sv"
vlog "./instructmem.sv"
vlog "./mux2x5.sv"
vlog "./signExtend9.sv"
vlog "./datamem.sv"
vlog "./dataMovement.sv"
vlog "./completeDataPath.sv"
vlog "./signExtend12.sv"
vlog "./control.sv"
vlog "./wallOfDFFs.sv"
vlog "./completeDataPathPipelined.sv"
vlog "./forwardingUnit.sv"
vlog "./regReadAndWriteStage.sv"
vlog "./ALUstage.sv"
vlog "./memStage.sv"
vlog "./pipelinedProcessor.sv"
vlog "./shifter.sv"
vlog "./NAND_MUX_4x1.sv"
vlog "./NAND_MUX_2x1.sv"
vlog "./multiplier.sv"
vlog "./andifier.sv"
vlog "./full_adder.sv"
vlog "./fullAdderArray63.sv"
vlog "./registerX64.sv"
vlog "./divider.sv"
vlog "./divider1.sv"
vlog "./FF_en.sv"
vlog "./mux_2x1_X65.sv"
vlog "./mux_4x1_X65.sv"
vlog "./registerX65.sv"
vlog "./xnorifier.sv"
vlog "./norifier.sv"
vlog "./adderC65.sv"


# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work pipelinedProcessor_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do pipelinedProcessor_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End
