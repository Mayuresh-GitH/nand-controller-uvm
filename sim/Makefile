#===============================================================================
# VCS + UVM 1.2 flow for nand-controller-uvm
#
#   make compile              build simv
#   make run                  run nand_smoke_test, FSDB waves (default)
#   make run VPD=1            run with VPD waves instead (for DVE)
#   make debug                UVM_HIGH + console trace + FSDB
#   make topo                 build env only, print topology, no stimulus
#   make waves                open Verdi on the FSDB
#   make dve                  open DVE on the VPD
#   make clean
#===============================================================================

VCS     = vcs
RTL_DIR = ../rtl
SRC_DIR = ../src

TEST  = nand_smoke_test
VERB  = UVM_LOW
SEED  = 1

#--- Verdi FSDB PLI ------------------------------------------------------------
# $fsdbDump* come from Verdi, not VCS, so the PLI is linked at COMPILE time.
# testbench.sv now dumps FSDB by default, so this link is always required.
# VERDI_HOME must be set in your environment (module load verdi, or equivalent).
VERDI_PLI_DIR = $(VERDI_HOME)/share/PLI/VCS/LINUX64
FSDB_PLI      = -P $(VERDI_PLI_DIR)/novas.tab $(VERDI_PLI_DIR)/pli.a

#--- compile order is load-bearing ---------------------------------------------
#  1. onfi_package.sv  macro header, not a real package; everything needs it
#  2. interfaces       the UVM package declares virtual handles to them
#  3. NAND_CTRL_PKG.sv all UVM classes
#  4. nand_master.sv   `include`s latch_unit.sv and io_unit.sv itself --
#                      do NOT list those two (Error-[MPD] Module previously declared)
#  5. model, wiring, top
SRCS = $(RTL_DIR)/onfi_package.sv \
       $(SRC_DIR)/NAND_CTRL_HOST_INTF.sv \
       $(SRC_DIR)/NAND_CTRL_MEM_INTF.sv \
       $(SRC_DIR)/NAND_CTRL_PKG.sv \
       $(RTL_DIR)/nand_master.sv \
       k9f1208.sv \
       design.sv \
       testbench.sv

# -ntb_opts uvm-1.2 pulls VCS's BUNDLED UVM. $UVM_HOME points at a site 1.1c
# install -- do not add it to +incdir, it will shadow the bundled copy.
# -debug_access+all -kdb produce simv.daidir, needed for Verdi source browsing.
# -suppress=PISB silences the harmless k9f1208 parameter warnings.
VCS_FLAGS = -full64 -sverilog -timescale=1ns/10ps \
            -ntb_opts uvm-1.2 \
            +incdir+$(RTL_DIR) +incdir+$(SRC_DIR) \
            -debug_access+all -kdb \
            -suppress=PISB

#--- runtime plusargs ----------------------------------------------------------
# testbench.sv dumps FSDB unless it sees +vpd, so the switch is VPD=1.
RUN_ARGS = +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=$(VERB) +ntb_random_seed=$(SEED)
ifdef VPD
RUN_ARGS += +vpd
endif

#===============================================================================

.PHONY: compile run debug topo waves dve check_verdi clean

check_verdi:
	@if [ -z "$(VERDI_HOME)" ]; then \
	  echo "ERROR: VERDI_HOME is not set -- cannot link the FSDB PLI."; \
	  echo "       testbench.sv calls \$$fsdbDumpfile, so this link is mandatory."; \
	  exit 1; \
	fi
	@if [ ! -f "$(VERDI_PLI_DIR)/pli.a" ]; then \
	  echo "ERROR: $(VERDI_PLI_DIR)/pli.a not found."; \
	  echo "       Check the platform dir -- it may be LINUXAMD64 instead of LINUX64."; \
	  ls $(VERDI_HOME)/share/PLI/VCS/ 2>/dev/null; \
	  exit 1; \
	fi

compile: check_verdi
	$(VCS) $(VCS_FLAGS) $(FSDB_PLI) $(SRCS) -o simv -l compile.log

run: compile
	./simv $(RUN_ARGS) -l sim.log

# UVM_HIGH shows the driver's per-command info; +trace enables the console
# signal monitor in testbench.sv. FSDB is the default, no plusarg needed.
debug: compile
	./simv +UVM_TESTNAME=$(TEST) +UVM_VERBOSITY=UVM_HIGH +trace \
	  +ntb_random_seed=$(SEED) -l sim.log

# Builds the env and prints uvm_top.print_topology(), no stimulus.
# Run this FIRST -- it catches config_db and connect_phase mistakes
# before any clock activity.
topo: compile
	./simv +UVM_TESTNAME=nand_base_test +UVM_VERBOSITY=UVM_LOW -l topo.log

# -dbdir gives Verdi the design so you can click a signal and jump to the RTL
waves:
	verdi -ssf nand.fsdb -dbdir simv.daidir &

dve:
	dve -full64 -vpd nand.vpd &

clean:
	rm -rf simv simv.daidir csrc ucli.key DVEfiles \
	       *.vpd *.fsdb *.vcd *.log \
	       novas.* verdiLog nWaveLog vfastLog .inter.vpd.uvm
