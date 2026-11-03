class nand_env extends uvm_env;
  `uvm_component_utils(nand_env)

  nand_host_agent m_host_agent;
  nand_mem_agent  m_mem_agent;
  // nand_scoreboard m_sbd;   // next step

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_host_agent = nand_host_agent::type_id::create("m_host_agent", this);
    m_mem_agent  = nand_mem_agent ::type_id::create("m_mem_agent",  this);
  endfunction

endclass
