module MFM_Shift (clk, load, pulses, so, done);
   input clk;           // Clock
   input load;          // Asynchronous load
   input [2:0] pulses;  // Number of pulses

   output so;           // Serial output
   output done;

   // Internal state
   reg so;
   reg done;
   reg [2:0] pulses_reg;
   reg [2:0] counter_reg = 0;

   initial
     begin
        so <= 0;
        done <= 0;
     end

   always @(posedge clk)
     begin
        if (counter_reg != pulses_reg)
          begin
             so = 0;

             if (counter_reg == 0)
               done = 1;
             else
               done = 0;
          end
        else
          begin
             done = 0;
             so = 1;
          end

        if (counter_reg == 0)
          counter_reg = pulses_reg;
        else
          counter_reg = counter_reg - 1;
     end

   always @(negedge load)
     begin
        pulses_reg = pulses;
        counter_reg = pulses;
     end
endmodule

//
// Input
//
`define SHORT 2
`define MED   3
`define LONG  4
`define ID    5

// As input, take an unknown clock + data MFM stream.
// As output, produce a stream synchronized on the
// rising edge of clk.
//
// Assumes a 50MHz clk, and 5MHz MFM data.
//
module MFM_DPLL (clk, si, reset, so);
   input clk, si, reset;
   output so;

endmodule
