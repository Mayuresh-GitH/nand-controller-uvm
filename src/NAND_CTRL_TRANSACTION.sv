// NAND_CTRL_TRANSACTION.sv
// One host-side operation on nand_host_if.
// Requires onfi_package.sv to be compiled first (provides the MI_* / M_* macros).
class nand_ctrl_transaction extends uvm_sequence_item;
  `uvm_object_utils(nand_ctrl_transaction)

  // Set by the sequence, driven by the host driver
  rand bit [5:0] cmd;        // -> cmd_in
  rand bit [7:0] data_in;    // -> data_in (used only by commands that take a data byte)

  // Set by the host monitor after busy falls
  bit [7:0]      data_out;   // <- data_out (valid only for get-byte commands)

  function new(string name = "nand_ctrl_transaction");
    super.new(name);
  endfunction

  // Copy: used by the sequencer and by scoreboards that keep a copy
  function void do_copy(uvm_object rhs);
    nand_ctrl_transaction rhs_;
    super.do_copy(rhs);
    if (!$cast(rhs_, rhs))
      `uvm_fatal("COPY_FAIL", "rhs is not nand_ctrl_transaction")
    cmd      = rhs_.cmd;
    data_in  = rhs_.data_in;
    data_out = rhs_.data_out;
  endfunction

  // Compare: cmd and data_out are what the scoreboard checks.
  // data_in is stimulus, so it is not compared.
  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    nand_ctrl_transaction rhs_;
    if (!$cast(rhs_, rhs))
      return 0;
    return (super.do_compare(rhs, comparer) &&
            cmd      == rhs_.cmd &&
            data_out == rhs_.data_out);
  endfunction

  // Print: one line per host operation, for logs
  function string convert2string();
    return $sformatf("cmd=0x%02h data_in=0x%02h data_out=0x%02h",
                     cmd, data_in, data_out);
  endfunction
endclass
