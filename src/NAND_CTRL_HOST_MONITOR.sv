//-------------------------------------------------------------------------------
// Watches the host interface independently of the driver.
// One transaction per EXECUTED command (busy actually rose).
//-------------------------------------------------------------------------------
class nand_host_monitor extends uvm_monitor;
  `uvm_component_utils(nand_host_monitor)

  virtual nand_host_if vif;
  uvm_analysis_port #(nand_ctrl_transaction) ap;

  int unsigned busy_rise_window = 8;
  int unsigned max_cycles       = 400_000;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap = new("ap", this);
    if (!uvm_config_db #(virtual nand_host_if)::get(this, "", "host_vif", vif))
      `uvm_fatal("MON_NOVIF", "host_vif not found in uvm_config_db")
  endfunction

  // Trigger on the RISING edge of activate, not on (activate && !busy).
  // busy is registered one cycle behind state, so busy==0 is not the same
  // condition the DUT uses -- an activate rising edge is unambiguous.
  virtual task run_phase(uvm_phase phase);
    logic prev_activate = 1'b0;
    logic cur_activate;
    forever begin
      @(vif.mon_cb);
      cur_activate = vif.mon_cb.activate;
      if (cur_activate === 1'b1 && prev_activate === 1'b0)
        collect_command();
      prev_activate = vif.mon_cb.activate;   // re-read: collect() consumed time
    end
  endtask

  protected virtual task collect_command();
    nand_ctrl_transaction tr;
    bit seen;

    tr = nand_ctrl_transaction::type_id::create("tr");
    tr.cmd     = vif.mon_cb.cmd_in;
    tr.data_in = vif.mon_cb.data_in;

    // busy rise proves the command was accepted. cmd_in = M_IDLE never rises.
    seen = 1'b0;
    for (int unsigned i = 0; i < busy_rise_window; i++) begin
      @(vif.mon_cb);
      if (vif.mon_cb.busy === 1'b1) begin seen = 1'b1; break; end
    end
    if (!seen) begin
      `uvm_info("MON_HOST",
                $sformatf("cmd=0x%02h produced no busy -- not executed, dropped",
                          tr.cmd), UVM_MEDIUM)
      return;
    end

    // busy fall. uvm_error not uvm_fatal -- the driver already fatals on hangs.
    seen = 1'b0;
    for (int unsigned i = 0; i < max_cycles; i++) begin
      @(vif.mon_cb);
      if (vif.mon_cb.busy === 1'b0) begin seen = 1'b1; break; end
    end
    if (!seen) begin
      `uvm_error("MON_HOST",
                 $sformatf("busy stuck high on cmd=0x%02h", tr.cmd))
      return;
    end

    // Spec p.4: data_out is only valid when busy is 0. We are at that edge.
    tr.data_out = vif.mon_cb.data_out;
    ap.write(tr);

    `uvm_info("MON_HOST",
              $sformatf("cmd=0x%02h data_in=0x%02h data_out=0x%02h",
                        tr.cmd, tr.data_in, tr.data_out), UVM_HIGH)
  endtask

endclass
