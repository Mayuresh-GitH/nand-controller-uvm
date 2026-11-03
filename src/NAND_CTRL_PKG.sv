//-------------------------------------------------------------------------------
// All UVM classes for the NAND controller testbench.
//
// Compile order dependencies (enforced in sim/Makefile):
//   - rtl/onfi_package.sv  must precede this file (M_* / MI_* macros)
//   - both interfaces      must precede this file (virtual interface types)
//
// Include order inside the package is load-bearing: every class must be
// declared before the first class that references it.
//-------------------------------------------------------------------------------
package nand_ctrl_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  // onfi_package.sv is a macro header, not a real package. Including it here
  // makes this file self-sufficient regardless of VCS compilation-unit scope.
  // The guard prevents redefinition warnings when it was already compiled.
  
    `include "onfi_package.sv"
  

  //---- 1. transaction: referenced by everything below ----------------------
  `include "NAND_CTRL_TRANSACTION.sv"
 `include "NAND_MEM_TRANSACTION.sv"
  //---- 2. sequencer: must come AFTER the transaction it parameterises -------
  typedef uvm_sequencer #(nand_ctrl_transaction) nand_ctrl_sequencer;

  
  `include "NAND_CTRL_DRIVER.sv"
  `include "NAND_CTRL_SEQ.sv"
  `include "NAND_CTRL_HOST_MONITOR.sv"
  `include "NAND_CTRL_HOST_AGENT.sv"
  `include "NAND_CTRL_MEM_MONITOR.sv"
  `include "NAND_CTRL_MEM_AGENT.sv"
  `include "NAND_CTRL_ENV.sv"
  `include "NAND_CTRL_TEST.sv"
  // `include "NAND_CTRL_SBD.sv"

endpackage
