//-------------------------------------------------------------------------------
// Bring the chip to a known state, then read the JEDEC ID.
// Ordering rules live HERE, not in the driver:
//   - MI_CHIP_ENABLE must follow M_RESET (M_RESET drives CE# high; the model
//     only latches a command while CENeg is low)
//   - MI_RESET_INDEX before MI_GET_ID_BYTE (page_idx is shared across buffers)
//-------------------------------------------------------------------------------
class nand_smoke_seq extends uvm_sequence #(nand_ctrl_transaction);
  `uvm_object_utils(nand_smoke_seq)

  function new(string name = "nand_smoke_seq");
    super.new(name);
  endfunction

  virtual task body();
    send(`M_RESET);           // controller reset; drives CE# HIGH
    send(`MI_CHIP_ENABLE);    // MANDATORY after M_RESET - CE# back LOW
    send(`M_NAND_RESET);      // 0xFF to the memory; waits on R/B#
    send(`M_NAND_READ_ID);    // 0x90 + addr 0x00, 5 bytes into chip_id[]
    send(`MI_RESET_INDEX);    // page_idx = 0
    repeat (5) send(`MI_GET_ID_BYTE);
  endtask

  // One command. data_in defaults to 0; no command is randomized yet.
  protected virtual task send(bit [5:0] cmd, bit [7:0] data = 8'h00);
    nand_ctrl_transaction tr;
    tr = nand_ctrl_transaction::type_id::create("tr");
    start_item(tr);
    tr.cmd     = cmd;
    tr.data_in = data;
    finish_item(tr);
  endtask

endclass

