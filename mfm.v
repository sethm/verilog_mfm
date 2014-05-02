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
   reg [3:0] div_counter;   // Divide-by-ten counter (1/2 cycle)
   reg [3:0] next_counter;  // How long is our next 1/2 cycle?
   reg first_sync;          // Have we ever found an MFM pulse?
   reg mfm_state;           // State of the MFM input

   // Full 50MHz cycles per 1/2 5 MHz cycle.
   parameter COUNTER_VAL = 4;

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
                  next_counter = COUNTER_VAL;
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
          if (div_counter > 2)
            // MFM clock is early. Lengthen current 1/2 cycle.
            div_counter = div_counter + (COUNTER_VAL - div_counter);
          else if (div_counter > 0)
            // MFM clock is late. Shortne next 1/2 cycle.
            next_counter = COUNTER_VAL - div_counter + 1;
       end

endmodule

module MFM_Decoder (clk_5, raw_mfm, mfm_buffer, byte_buffer);
   input clk_5;
   input raw_mfm;

   output [15:0] mfm_buffer;
   output [7:0] byte_buffer;

   reg [15:0] mfm_buffer;

   initial
     mfm_buffer = 0;

   always @(posedge clk_5 or negedge clk_5)
     begin
        mfm_buffer = mfm_buffer << 1;
        if (raw_mfm)
          mfm_buffer[0] = 1;
        else
          mfm_buffer[0] = 0;
     end

   assign byte_buffer = {mfm_buffer[15],
                         mfm_buffer[13],
                         mfm_buffer[11],
                         mfm_buffer[9],
                         mfm_buffer[7],
                         mfm_buffer[5],
                         mfm_buffer[3],
                         mfm_buffer[1]};

endmodule
