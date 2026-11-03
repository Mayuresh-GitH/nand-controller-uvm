//-------------------------------------------------------------------------------
// Passive by construction: nand_mem_if has only mon_cb, so there is nothing to
// drive. No is_active check -- a driver cannot exist here. Phase 3 error
// injection would add one (and a drv_cb to the interface).
//-------------------------------------------------------------------------------
class nand_mem_agent extends uvm_agent;
  `uvm_component_utils(nand_mem_agent)

  nand_mem_monitor                m_mon;
  uvm_analysis_port #(nand_mem_txn) ap;   // forwarded, so the env never reaches
                                          // inside the agent for the monitor
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap    = new("ap", this);
    m_mon = nand_mem_monitor::type_id::create("m_mon", this);
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_mon.ap.connect(ap);
  endfunction

endclass
