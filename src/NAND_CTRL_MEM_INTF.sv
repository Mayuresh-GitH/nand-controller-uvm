//mem_intf
interface nand_mem_if (input logic clk);
  wire       nand_cle;
  wire       nand_ale;
  wire       nand_nwe;
  wire       nand_nre;
  wire       nand_nce;
  wire       nand_nwp;
  wire       nand_rnb;
  wire  [7:0] nand_data;   // wire: the controller and the model both drive it

  clocking mon_cb @(posedge clk);
    input nand_cle, nand_ale, nand_nwe, nand_nre, nand_nce, nand_nwp, nand_rnb, nand_data;
  endclocking
endinterface
