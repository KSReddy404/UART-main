// Code your design here
module uart_top #(parameter clk_freq=1000000,parameter baud_rate=9600)
  (input clk,input rst,input rx,input [7:0] dintx,input send,
   output tx,output [7:0] doutrx,output donetx,output donerx); 
  uarttx #(clk_freq,baud_rate) utx(clk,rst,send,dintx,tx,donetx);
  uartrx #(clk_freq,baud_rate) rtx(clk,rst,rx,donerx,doutrx);
endmodule

module uarttx #(parameter clk_freq=1000000,parameter baud_rate=9600)
  (input clk,input rst,input send,input[7:0] tx_data,output reg tx,output reg donetx);
  integer count=0;
  integer counts=0;
  localparam clkcount=clk_freq/baud_rate;
  enum bit[1:0] {idle=2'b00,transfer=2'b10} state;
  reg uclk=0;
  
  always@(posedge clk)
    begin
      if(count<clkcount/2)
        count=count+1;
      else begin
        count<=0;
        uclk=~uclk;
      end
    end
  
  reg[7:0] din; 
  always@(posedge uclk)
    begin
      if(rst)
        begin
          state<=idle;
        end
      else
        begin
          case(state)
            idle:
              begin
                counts<=0;
                tx<=1'b1; 
                donetx=1'b0;
                if(send)
                  begin
                    state<=transfer;
                    din<=tx_data;
                    tx=1'b0;
                  end
                else
                  state<=idle;
              end
            transfer:
              begin
                if(counts<=7)
                  begin
                    counts<=counts+1;
                    tx<=din[counts];
                    state<=transfer;
                  end
                else
                  begin
                    counts<=0;
                    tx<=1'b1;
                    state<=idle;
                  	donetx<=1'b1;
                  end
              end
            default:state<=idle;
          endcase
        end
    end
endmodule


module uartrx #(parameter clk_freq=1000000,parameter baud_rate=9600) 
  (input clk,input rst,input rx,output reg done,output reg[7:0] rxdata);
  integer count=0;
  integer counts=0;
  localparam clkcount=clk_freq/baud_rate;
  enum bit[1:0] {idle=2'b00,start=2'b01} state;
  reg uclk=0;
  
  always@(posedge clk)
    begin
      if(count<clkcount/2)
        count=count+1;
      else begin
        count<=0;
        uclk=~uclk;
      end
    end
  always@(posedge uclk)
    begin
      if(rst)
        begin
          rxdata<=8'h00;
          counts<=0;
          done<=1'b0;
        end
      else
        begin
          case(state)
            idle:
              begin
                rxdata<=8'h00;
          		counts<=0;
          		done<=1'b0;
                if(rx==1'b0)
                  state<=start;
                else
                  state=idle;
              end
            start:
              begin
                if(counts<=7)
                  begin
                    counts=counts+1;
                    rxdata<={rx,rxdata[7:1]};
                  end
                else
                  begin
                 	 counts<=0;
               	  	 done<=1'b1;
               	  	 state=idle;
              	  end
              end
            default:state<=idle;
          endcase
        end
    end
endmodule