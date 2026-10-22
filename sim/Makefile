# VCS flow for nand-controller-uvm (steps 1-3: RTL + wiring + smoke test)
VCS     = vcs
RTL_DIR = ../rtl
SRC_DIR = ../src

RTL_SRCS = $(RTL_DIR)/onfi_package.sv \
           $(RTL_DIR)/nand_master.sv

TB_SRCS  = k9f1208.sv \
           $(SRC_DIR)/NAND_CTRL_HOST_INTF.sv \
           $(SRC_DIR)/NAND_CTRL_MEM_INTF.sv \
           design.sv testbench.sv

VCS_FLAGS = -full64 -sverilog -timescale=1ns/10ps \
            +incdir+$(RTL_DIR) -debug_access+all

compile:
	$(VCS) $(VCS_FLAGS) $(RTL_SRCS) $(TB_SRCS) -o simv -l compile.log

run: compile
	./simv -l sim.log

clean:
	rm -rf simv simv.daidir csrc ucli.key DVEfiles *.vpd *.log
