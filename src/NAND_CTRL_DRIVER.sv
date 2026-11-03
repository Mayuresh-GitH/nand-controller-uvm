//-------------------------------------------------------------------------------
// NAND_CTRL_DRIVER.sv
// Host driver for nand_master's component interface (nand_host_if.drv_cb).
// One sequence item = one host command.
//
//   wait busy low  ->  set cmd/data  ->  activate for 1 cycle
//                  ->  wait busy rise  ->  wait busy fall
//
// Command ordering (chip-enable after reset, reset-index before ID reads)
// lives in sequences, not here.
// Requires onfi_package.sv compiled first.
//-------------------------------------------------------------------------------
class nand_ctrl_driver extends uvm_driver #(nand_ctrl_transaction);
  `uvm_component_utils(nand_ctrl_driver)

  virtual nand_host_if vif;        // interface has no modport -> raw type

  int unsigned powerup_cycles = 4400;     // 11 us > K9F1208 power-up (10 us)
  int unsigned max_cycles     = 400_000;  // covers block erase (~280k cycles)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(virtual nand_host_if)::get(this, "", "host_vif", vif))
      `uvm_fatal("DRV_NOVIF", "host_vif not found in uvm_config_db")
  endfunction

  virtual task run_phase(uvm_phase phase);
    reset_dut();                           // once, before any item
    forever begin
      seq_item_port.get_next_item(req);    // 'req' inherited from uvm_driver
      drive_item(req);
      seq_item_port.item_done();
    end
  endtask

  // Pin bring-up only: no commands.
  protected virtual task reset_dut();
    vif.drv_cb.activate <= 1'b0;
    vif.drv_cb.cmd_in   <= '0;
    vif.drv_cb.data_in  <= '0;
    vif.drv_cb.nreset   <= 1'b0;           // active low
    repeat (20) @(vif.drv_cb);
    vif.drv_cb.nreset   <= 1'b1;
    repeat (powerup_cycles) @(vif.drv_cb);
    `uvm_info("DRV", "reset done", UVM_LOW)
  endtask

  protected virtual task drive_item(nand_ctrl_transaction tr);
    // 1. controller must be idle, else activate is silently ignored
    wait_busy(1'b0, max_cycles, "idle before command", tr.cmd);

    // 2. command stable one cycle before activate (spec v18 p.4)
    vif.drv_cb.cmd_in  <= tr.cmd;
    vif.drv_cb.data_in <= tr.data_in;
    @(vif.drv_cb);

    // 3. one activate cycle
    vif.drv_cb.activate <= 1'b1;
    @(vif.drv_cb);
    vif.drv_cb.activate <= 1'b0;

    // 4. busy rises (command accepted), then falls (command done)
    wait_busy(1'b1, 8,          "busy rise",  tr.cmd);
    wait_busy(1'b0, max_cycles, "busy fall",  tr.cmd);

    `uvm_info("DRV", $sformatf("cmd=0x%02h done", tr.cmd), UVM_HIGH)
  endtask

  // Sample busy on every clocking edge until it equals 'val'.
  // Edge-by-edge, because busy can be high for only one cycle.
  protected virtual task wait_busy(bit val, int unsigned limit,
                                   string what, bit [5:0] cmd);
    for (int unsigned i = 0; i < limit; i++) begin
      @(vif.drv_cb);
      if (vif.drv_cb.busy == val) return;
    end
    `uvm_fatal("DRV_TIMEOUT",
               $sformatf("%s: busy != %0b after %0d cycles on cmd=0x%02h",
                         what, val, limit, cmd))
  endtask

endclass 
