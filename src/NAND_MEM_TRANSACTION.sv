//-------------------------------------------------------------------------------
// One NAND bus PHASE, not one host command. A single host command expands into
// several of these (READ_ID = 1 CMD + 1 ADDR + 5 DATA_RD).
//-------------------------------------------------------------------------------
typedef enum bit [1:0] {
  MEM_CMD,       // CLE high  -> command byte latched on WE# rising
  MEM_ADDR,      // ALE high  -> address byte latched on WE# rising
  MEM_DATA_WR,   // both low  -> data byte written on WE# rising
  MEM_DATA_RD    // RE# pulse -> data byte read from the chip
} mem_phase_e;

class nand_mem_txn extends uvm_sequence_item;
  `uvm_object_utils(nand_mem_txn)

  rand mem_phase_e kind;
  rand bit [7:0]   value;

  function new(string name = "nand_mem_txn");
    super.new(name);
  endfunction

  virtual function void do_copy(uvm_object rhs);
    nand_mem_txn t;
    if (!$cast(t, rhs)) `uvm_fatal("MEM_TXN", "do_copy cast failed")
    super.do_copy(rhs);
    kind  = t.kind;
    value = t.value;
  endfunction

  virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    nand_mem_txn t;
    if (!$cast(t, rhs)) return 0;
    return super.do_compare(rhs, comparer)
           && (kind == t.kind) && (value == t.value);
  endfunction

  virtual function string convert2string();
    return $sformatf("%s 0x%02h", kind.name(), value);
  endfunction

endclass
