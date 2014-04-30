module MFM_Shift (clk, load, pulses, so, done);
   input clk;           // Clock
   input load;          // Asynchronous load
   input [2:0] pulses;  // Number of pulses

   output so;           // Serial output
   output done;
   output shift_done;   // Shift done (one clock)

   // Internal state
   reg so_reg;
   reg done_reg;
   reg load_requested;
   reg [2:0] pulses_reg;
   reg [2:0] counter = 0;

   initial
     begin
        so_reg <= 0;
        done_reg <= 0;
     end

   always @(posedge clk)
     begin
        if (counter != pulses_reg)
          begin
             so_reg = 0;

             if (counter == 0)
               done_reg = 1;
             else
               done_reg = 0;
          end
        else
          begin
             done_reg = 0;
             so_reg = 1;
          end

        if (counter == 0)
          counter = pulses_reg;
        else
          counter = counter - 1;
     end

   always @(negedge load)
     begin
        pulses_reg = pulses;
        counter = pulses;
     end

   assign so = so_reg;
   assign done = done_reg;
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
