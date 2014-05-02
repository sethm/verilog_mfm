//
// Digital PLL. The output, 'clk_5', will be synchronized with the
// clock and data bits of the raw MFM. It is self-correcting for any
// jitter in the MFM data by shortening or lengthening the width of
// the 5 MHz output clock to compensate.
//
module MFM_DPLL (clk_50, raw_mfm, clk_5);

   input clk_50;            // 50 MHz system clock
   input raw_mfm;           // Raw MFM data

   output clk_5;            // 5 MHz clock, sync'ed on MFM data

   reg clk_5;               // Register holding the state of clk_5
   reg [4:0] div_counter;   // Divide-by-ten counter
   reg [4:0] next_counter;  // How long is our next 1/2 cycle?
   reg first_sync;          // Have we ever found an MFM pulse?
   reg mfm_state;           // State of the MFM input

   parameter COUNTER_VAL = 9;

   initial
     begin
        div_counter = 0;
        next_counter = 0;
        first_sync = 0;
        clk_5 = 0;
        mfm_state = 0;
     end

   always @(posedge clk_50)
     begin
        if (!first_sync)
          // It's important to align our first rising edge pulse
          // with an MFM pulse. It might be clock, or it might be data,
          // we don't care -- as long as we align with it. Until then,
          // do nothing.
          begin
             if (raw_mfm)
               begin
                  first_sync = 1;
                  div_counter = 0;
                  // Take off one for the 50MHz cycle we just lost.
                  next_counter = COUNTER_VAL - 1;
               end
          end
        else if (div_counter == 0)
          // Reset the clock divider counter and toggle the 5 MHz
          // clock.
          begin
             div_counter = next_counter;
             next_counter = COUNTER_VAL;
             clk_5 = ~clk_5;
          end
        else
          // Just count down.
          div_counter = div_counter - 1;
     end

   //
   // If the MFM clock is earlier or later than we expect it, lengthen
   // or shorten the clock width to compensate and re-sync.
   //
   always @(posedge clk_50)
     if (mfm_state != raw_mfm)
       begin
          mfm_state = raw_mfm;
          if (div_counter > 5)

            // MFM clock is early. Lengthen current 1/2 cycle. But since
            // the raw MFM clock may be synced either to the rising edge or
            // the falling edge of the 50 MHz clock, we must be sure that
            // the 5MHz clock output is always lagging (never leading!) by
            // at least 1 to 1.5 clk_50 cycles, for safety. Hence, the
            // extra "1"

            div_counter = div_counter + (COUNTER_VAL - div_counter + 1);
          else if (div_counter > 0)
            // MFM clock is late. Shortne next 1/2 cycle.
            next_counter = COUNTER_VAL - div_counter;
       end

endmodule
