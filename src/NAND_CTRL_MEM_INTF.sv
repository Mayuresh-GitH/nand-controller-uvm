//mem_intf
interface nand_mem_if (input logic clk);
  logic       nand_cle;
  logic       nand_ale;
  logic       nand_nwe;
  logic       nand_nre;
  logic       nand_nce;
  logic       nand_nwp;
  logic       nand_rnb;
  wire  [7:0] nand_data;   // wire: the controller and the model both drive it

  clocking mon_cb @(posedge clk);
    input nand_cle, nand_ale, nand_nwe, nand_nre, nand_nce, nand_nwp, nand_rnb, nand_data;
  endclocking
endinterface
