// The following external lines are active low:
//    - RESET (input)
//    - READY (output)

//
// Digital PLL. The output, 'clk_5', will be synchronized with the
// clock and data bits of the raw MFM. It is self-correcting for any
// jitter in the MFM data by shortening or lengthening the width of
// the 5 MHz output clock to compensate.
//
module MFM_DPLL (reset, clk_50, raw_mfm, clk_5);

   input reset;             // Reset line, active low
   input clk_50;            // 50 MHz system clock
   input raw_mfm;           // Raw MFM data

   output clk_5;            // 5 MHz clock, sync'ed on MFM data

   reg clk_5;               // Register holding the state of clk_5
   reg [3:0] div_counter;   // Divide-by-ten counter (1/2 cycle)
   reg [3:0] next_counter;  // How long is our next 1/2 cycle?
   reg first_sync;          // Have we ever found an MFM pulse?
   reg mfm_state;           // State of the MFM input

   // Number of ull 50MHz cycles per 1/2 5 MHz cycle.
   parameter COUNTER_VAL = 4;

   always @(posedge clk_50 or negedge reset) begin
      if (~reset) begin
         first_sync = 0;
         div_counter = 0;
         mfm_state = 0;
         clk_5 = 0;
         next_counter = COUNTER_VAL;
      end



      else if (!first_sync) begin
         // It's important to align our first rising edge pulse
         // with an MFM pulse. It might be clock, or it might be data,
         // we don't care -- as long as we align with it. Until then,
         // do nothing.
         if (raw_mfm) begin
            first_sync = 1;
            next_counter = COUNTER_VAL + 1;
         end
      end
      else if (div_counter == 0) begin
         // Reset the clock divider counter and toggle the 5 MHz
         // clock.
         div_counter = next_counter;
         next_counter = COUNTER_VAL;
         clk_5 = ~clk_5;
      end
      else begin
         //
         // If the MFM clock is earlier or later than we expect it,
         //lengthen or shorten the clock width to compensate and
         //re-sync.
         //
         // The idea here is to maintain a lag behind the MFM clock by close
         // to 1/2 a bit cell (MFM bits will be read in the decoder on both
         // rising and falling edges of this 5 MHz clock, so we can't be
         // right on top of the MFM bit cells)
         //
         if (mfm_state != raw_mfm) begin
            mfm_state = raw_mfm;
            if (div_counter > 2)
              div_counter = div_counter - 1;
            else if (div_counter == 0)
              next_counter = COUNTER_VAL + 1;
         end

        // Just count down.
        div_counter = div_counter - 1;
      end
   end

endmodule
