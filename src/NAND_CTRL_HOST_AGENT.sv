class nand_host_agent extends uvm_agent;
  `uvm_component_utils(nand_host_agent)

  nand_ctrl_driver     m_drv;
  nand_ctrl_sequencer  m_sqr;
  nand_host_monitor    m_mon;
  uvm_analysis_port #(nand_ctrl_transaction) ap;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap    = new("ap", this);
    m_mon = nand_host_monitor::type_id::create("m_mon", this);   // always built
    if (get_is_active() == UVM_ACTIVE) begin
      m_drv = nand_ctrl_driver   ::type_id::create("m_drv", this);
      m_sqr = nand_ctrl_sequencer::type_id::create("m_sqr", this);
    end
  endfunction

  virtual function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    m_mon.ap.connect(ap);
    if (get_is_active() == UVM_ACTIVE)
      m_drv.seq_item_port.connect(m_sqr.seq_item_export);
  endfunction

endclass
