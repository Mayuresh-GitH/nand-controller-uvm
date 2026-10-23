module testbench;
  logic clk = 0;
  always #1.25 clk = ~clk;          // 2.5 ns period, 400 MHz

  nand_host_if host_if(clk);
  nand_mem_if  mem_if(clk);

  // Controller + memory (bus wired inside nand_sys)
  nand_sys dut (
    .clk(clk), .nreset(host_if.nreset),
    .activate(host_if.activate), .cmd_in(host_if.cmd_in),
    .data_in(host_if.data_in), .data_out(host_if.data_out),
    .busy(host_if.busy),
    .nand_cle(mem_if.nand_cle), .nand_ale(mem_if.nand_ale),
    .nand_nce(mem_if.nand_nce), .nand_nre(mem_if.nand_nre),
    .nand_nwe(mem_if.nand_nwe), .nand_nwp(mem_if.nand_nwp),
    .nand_data(mem_if.nand_data)
  );

  // ---- helper tasks ----------------------------------------------------

  // Strobe one host command for exactly one clock cycle
  task automatic host_cmd(input bit [5:0] c);
    @(negedge clk);
    host_if.cmd_in   = c;
    host_if.activate = 1;
    @(negedge clk);
    host_if.activate = 0;
  endtask

  // Wait until the controller has finished the command (busy low)
  task automatic wait_idle(int unsigned max_cycles = 1000);
    int unsigned n = 0;
    @(posedge clk);                     // let busy rise after the strobe
    while (host_if.busy) begin
      @(posedge clk);
      if (++n > max_cycles) begin
        $display("%0t ERROR: busy stuck high", $time);
        $finish;
      end
    end
  endtask

  // Wait until the memory reports ready (rnb high); X counts as not ready
  task automatic wait_chip_ready(int unsigned max_cycles = 100000);
    int unsigned n = 0;
    while (dut.rnb !== 1'b1) begin
      @(posedge clk);
      if (++n > max_cycles) begin
        $display("%0t ERROR: rnb never went high", $time);
        $finish;
      end
    end
    $display("%0t chip READY after %0d cycles", $time, n);
  endtask

  // ---- stimulus --------------------------------------------------------
  initial begin
    // Initialise host inputs so no port is X at time 0
    host_if.nreset   = 0;  host_if.activate = 0;
    host_if.cmd_in   = 0;  host_if.data_in  = 0;

    #50 host_if.nreset = 1;          // release controller reset
    #11000;                          // wait past memory power-up (10 us)

    host_cmd(`M_RESET);              // reset the controller (this drives CE# high)
    wait_idle();

    host_cmd(`MI_CHIP_ENABLE);       // drive CE# low so the memory accepts commands
    wait_idle();

    host_cmd(`M_NAND_RESET);         // send 0xFF to the memory
    wait_idle();

    wait_chip_ready();               // rnb must go high after the reset time

    #100 $finish;
  end

  // ---- monitor: prints only when a signal that matters changes --------
  // dut.dev.R_zd          = memory ready register (drives R)
  // dut.dev.current_state = memory state machine state
  always @(host_if.activate or host_if.busy or dut.rnb or dut.dev.R_zd or
           dut.dev.current_state or
           mem_if.nand_cle or mem_if.nand_ale or mem_if.nand_nce or mem_if.nand_nwe)
    $display("%0t act=%b cmd=%0d busy=%b cle=%b nce=%b nwe=%b rnb=%b R_zd=%b state=%0d",
             $time, host_if.activate, host_if.cmd_in, host_if.busy,
             mem_if.nand_cle, mem_if.nand_nce, mem_if.nand_nwe, dut.rnb,
             dut.dev.R_zd, dut.dev.current_state);

endmodule
