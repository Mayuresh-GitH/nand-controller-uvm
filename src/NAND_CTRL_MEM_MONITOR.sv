//-------------------------------------------------------------------------------
// Watches the NAND bus. Emits one transaction per STROBE, not per clock.
//
// The bus is strobe-based, not clock-based: nand_nwe sits low for t_wp = 4
// clocks, so a naive clocked monitor would emit the same byte four times.
// Transactions are emitted on the RISING edge of WE#/RE# -- that is when a real
// NAND part latches a write -- using the values sampled on the PREVIOUS clocking
// edge, while the strobe was still low and the data still driven.
//-------------------------------------------------------------------------------
class nand_mem_monitor extends uvm_monitor;
  `uvm_component_utils(nand_mem_monitor)

  virtual nand_mem_if vif;
  uvm_analysis_port #(nand_mem_txn) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual nand_mem_if)::get(this, "", "mem_vif", vif))
      `uvm_fatal("MON_NOVIF", "mem_vif not found in uvm_config_db")
  endfunction

  virtual task run_phase(uvm_phase phase);
    logic       cur_nwe,  cur_nre;
    logic       prev_nwe  = 1'b1, prev_nre = 1'b1;
    logic       prev_cle  = 1'b0, prev_ale = 1'b0;
    logic [7:0] prev_data = 8'h00;

    forever begin
      @(vif.mon_cb);
      cur_nwe = vif.mon_cb.nand_nwe;
      cur_nre = vif.mon_cb.nand_nre;

      // WE# rising = byte latched by the chip
      if (cur_nwe === 1'b1 && prev_nwe === 1'b0)
        emit(classify_write(prev_cle, prev_ale), prev_data);

      // RE# rising = byte read from the chip
      if (cur_nre === 1'b1 && prev_nre === 1'b0)
        emit(MEM_DATA_RD, prev_data);

      prev_nwe  = cur_nwe;
      prev_nre  = cur_nre;
      prev_cle  = vif.mon_cb.nand_cle;
      prev_ale  = vif.mon_cb.nand_ale;
      prev_data = vif.mon_cb.nand_data;
    end
  endtask

  protected virtual function mem_phase_e classify_write(logic cle, logic ale);
    if (cle === 1'b1) return MEM_CMD;
    if (ale === 1'b1) return MEM_ADDR;
    return MEM_DATA_WR;
  endfunction

  protected virtual function void emit(mem_phase_e k, logic [7:0] v);
    nand_mem_txn tr;
    tr = nand_mem_txn::type_id::create("tr");
    tr.kind  = k;
    tr.value = v;
    ap.write(tr);
    `uvm_info("MON_MEM", tr.convert2string(), UVM_HIGH)
  endfunction

endclass
