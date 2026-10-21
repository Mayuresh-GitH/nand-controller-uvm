interface nand_host_if (input logic clk);
  logic       nreset;
  logic       activate;
  logic [5:0] cmd_in;
  logic [7:0] data_in;
  logic [7:0] data_out;
  logic       busy;

  clocking drv_cb @(posedge clk);
    output nreset, activate, cmd_in, data_in;
    input  busy, data_out;
  endclocking

  clocking mon_cb @(posedge clk);
    input nreset, activate, cmd_in, data_in, busy, data_out;
  endclocking
endinterface
