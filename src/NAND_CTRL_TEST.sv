class nand_base_test extends uvm_test;
  `uvm_component_utils(nand_base_test)

  nand_env m_env;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_env = nand_env::type_id::create("m_env", this);
  endfunction

  // Free sanity check: wrong topology or a missing connect shows up here,
  // before any clock has ticked.
  virtual function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction

endclass


class nand_smoke_test extends nand_base_test;
  `uvm_component_utils(nand_smoke_test)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual task run_phase(uvm_phase phase);
    nand_smoke_seq seq;
    seq = nand_smoke_seq::type_id::create("seq");
    phase.raise_objection(this, "smoke");
    seq.start(m_env.m_host_agent.m_sqr);
    #1us;                                 // let the tail of the last command settle
    phase.drop_objection(this, "smoke");
  endtask

endclass
