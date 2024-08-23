// Code your testbench here
// or browse Examples
module uart_testbench;
  reg clk, rst, send, rx;
  reg [7:0] tx_data;
  wire tx, donetx, donerx;
  wire [7:0] doutrx;
  
  // Instantiate the UART module
  uart_top #(
    .clk_freq(1000000),    // Set your desired values for these parameters
    .baud_rate(9600)
  ) uut (
    .clk(clk),
    .rst(rst),
    .rx(rx),
    .dintx(tx_data),
    .send(send),
    .tx(tx),
    .doutrx(doutrx),
    .donetx(donetx),
    .donerx(donerx)
  );
  
  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Reset generation
  initial begin
    $dumpfile ("uart.vcd");
$dumpvars (0,uart_testbench); 
    rst = 1;
    #10 rst = 0;
  end
  
  // Stimulus generation
  initial begin
    send = 0;
    tx_data = 8'b10101010;
    
    // Simulate sending data
    send = 0; 
    #25 send = 1 ;
    #600;
    send = 0;
    
    // Simulate receiving data
    #11050;
    rx = 0;
    #1050;
    rx = 1;
    #1050;
    rx = 1;
     #1050;
    rx = 1;
     #1050;
    rx = 0;
     #1050;
    rx = 0;
    #200;
    
    #20000 $finish;
  end
  
endmodule
