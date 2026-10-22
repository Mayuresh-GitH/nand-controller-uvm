module testbench;
  logic clk = 0;
  always #1.25 clk = ~clk;          // 2.5 ns period, 400 MHz

  nand_host_if host_if(clk);
  nand_mem_if  mem_if(clk);

  nand_sys dut (
    .clk(clk), .nreset(host_if.nreset),
    .activate(host_if.activate), .cmd_in(host_if.cmd_in),
    .data_in(host_if.data_in), .data_out(host_if.data_out),
    .busy(host_if.busy),
    .nand_cle(mem_if.nand_cle), .nand_ale(mem_if.nand_ale),
    .nand_nce(mem_if.nand_nce), .nand_nre(mem_if.nand_nre),
    .nand_nwe(mem_if.nand_nwe), .nand_nwp(mem_if.nand_nwp),
    .nand_rnb_w(1'b1),
    .nand_data(mem_if.nand_data[7:0])
  );

  initial begin
    host_if.nreset   = 0;  host_if.activate = 0;
    host_if.cmd_in   = 0;  host_if.data_in  = 0;
    #50 host_if.nreset = 1;
    #20 host_if.cmd_in = 6'd1; host_if.activate = 1;   // M_RESET, adjust to macro value
    #2.5 host_if.activate = 0;
    #500 $finish;
  end
endmodule
