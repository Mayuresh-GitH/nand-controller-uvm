module nand_sys (
  input  wire       clk, nreset, activate,
  input  wire [5:0] cmd_in,
  input  wire [7:0] data_in,
  output wire [7:0] data_out,
  output wire       busy,
  output wire       nand_cle, nand_ale, nand_nwe, nand_nre, nand_nce, nand_nwp,
  input  wire       nand_rnb_w,   // not used; rnb comes from the model
  inout  wire [7:0] nand_data
);
  wire [15:0] bus16;
  wire        rnb;

  nand_master dut (
    .clk(clk), .enable(1'b0), .nreset(nreset),
    .activate(activate), .cmd_in(cmd_in), .data_in(data_in),
    .data_out(data_out), .busy(busy),
    .nand_cle(nand_cle), .nand_ale(nand_ale),
    .nand_nce(nand_nce), .nand_nre(nand_nre),
    .nand_nwe(nand_nwe), .nand_nwp(nand_nwp),
    .nand_rnb(rnb), .nand_data(bus16)
  );

  k9f1208 dev (
    .IO7(nand_data[7]), .IO6(nand_data[6]), .IO5(nand_data[5]), .IO4(nand_data[4]),
    .IO3(nand_data[3]), .IO2(nand_data[2]), .IO1(nand_data[1]), .IO0(nand_data[0]),
    .CLE(nand_cle), .ALE(nand_ale), .CENeg(nand_nce), .RENeg(nand_nre),
    .WENeg(nand_nwe), .WPNeg(nand_nwp), .R(rnb)
  );

  assign bus16[15:8] = 8'hZZ;   // upper byte unused on x8 part
endmodule
