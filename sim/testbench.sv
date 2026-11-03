//-------------------------------------------------------------------------------
// UVM top-level. Responsibilities:
//   1. generate the clock
//   2. instantiate the interfaces and wire them to nand_sys
//   3. publish the virtual interfaces into the config database
//   4. dump waves and call run_test()
//
// NO stimulus here. nreset and all commands are driven by nand_ctrl_driver.
//-------------------------------------------------------------------------------
module testbench;
  import uvm_pkg::*;
  import nand_ctrl_pkg::*;
  `include "uvm_macros.svh"

  logic clk = 0;
  always #1.25 clk = ~clk;          // 2.5 ns period, 400 MHz

  nand_host_if host_if(clk);
  nand_mem_if  mem_if(clk);

  // Controller + memory (bus wired inside nand_sys)
  nand_sys dut (
    .clk(clk), .nreset(host_if.nreset),
    .activate(host_if.activate), .cmd_in(host_if.cmd_in),
    .data_in(host_if.data_in), .data_out(host_if.data_out),
    .busy(host_if.busy),
    .nand_cle(mem_if.nand_cle), .nand_ale(mem_if.nand_ale),
    .nand_nce(mem_if.nand_nce), .nand_nre(mem_if.nand_nre),
    .nand_nwe(mem_if.nand_nwe), .nand_nwp(mem_if.nand_nwp),
    .nand_data(mem_if.nand_data)
  );

  // ---- hand the interfaces to the UVM components ------------------------
  initial begin
    uvm_config_db #(virtual nand_host_if)::set(null, "*", "host_vif", host_if);
    uvm_config_db #(virtual nand_mem_if )::set(null, "*", "mem_vif",  mem_if);
  end

  // ---- waveform dumping -------------------------------------------------
  // FSDB by default (Verdi).  Run with +vpd to get a VPD for DVE instead.
  //
  // $fsdbDump* are Verdi PLI tasks, NOT built into VCS -- the PLI must be
  // linked at COMPILE time (see FSDB_PLI in sim/Makefile) even though the
  // format is chosen here at run time.
  //
  // $fsdbDumpMDA / $vcdplusmemon are what make unpacked ARRAYS visible.
  // dut.dut.chip_id[0:4] holds the JEDEC ID bytes -- Phase 1 needs it.
  initial begin
    if ($test$plusargs("vpd")) begin
      $vcdplusfile("nand.vpd");
      $vcdpluson(0, testbench);
      $vcdplusmemon(0, testbench);
    end
    else begin
      $fsdbDumpfile("nand.fsdb");
      $fsdbDumpvars(0, testbench);
      $fsdbDumpMDA(0, testbench);       // unpacked arrays / memories
    end
  end

  // ---- optional console trace: run with +trace --------------------------
  // Kept from the smoke test; noisy during READ_ID, hence the plusarg.
  bit trace = 0;
  initial trace = $test$plusargs("trace");

  always @(host_if.activate or host_if.busy or dut.rnb or dut.dev.R_zd or
           dut.dev.current_state or
           mem_if.nand_cle or mem_if.nand_ale or mem_if.nand_nce or mem_if.nand_nwe)
    if (trace)
      $display("%0t act=%b cmd=%0d busy=%b cle=%b nce=%b nwe=%b rnb=%b R_zd=%b state=%0d",
               $time, host_if.activate, host_if.cmd_in, host_if.busy,
               mem_if.nand_cle, mem_if.nand_nce, mem_if.nand_nwe, dut.rnb,
               dut.dev.R_zd, dut.dev.current_state);

  // ---- start UVM ---------------------------------------------------------
  initial run_test();                // test chosen by +UVM_TESTNAME

endmodule
