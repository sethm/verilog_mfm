
//
// Digital PLL. The output, 'clk_5', will be synchronized with the
// clock and data bits of the raw MFM. It is self-correcting for any
// jitter in the MFM data.
//
module MFM_DPLL (clk_50, raw_mfm, clk_5);
   parameter CLK_DELAY = 4'd9;

   input clk_50;              // Clock
   input raw_mfm;             // Raw MFM data

   output clk_5;              // 5 MHz clock, sync'ed on MFM data

   reg clk_5;                 // Register holding the state of clk_5
   reg [4:0] div_counter;     // Divide-by-ten counter

   initial
     begin
        div_counter = CLK_DELAY;
        clk_5 = 1'b1;
     end

   always @(posedge clk_50)
     begin
        if (div_counter == 0)
          begin
             div_counter <= CLK_DELAY;
             clk_5 = ~clk_5;
          end
        else
          div_counter <= div_counter - 1;
     end

   always @(posedge raw_mfm)
     if (div_counter < 5)
       div_counter = 0;
     else
       div_counter = CLK_DELAY;




endmodule
