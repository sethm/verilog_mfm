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

   // Number of ull 50MHz cycles per 1/2 5 MHz cycle.
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
                  next_counter = COUNTER_VAL + 1;
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
   // The idea here is to maintain a lag behind the MFM clock by close
   // to 1/2 a bit cell (MFM bits will be read in the decoder on both
   // rising and falling edges of this 5 MHz clock, so we can't be
   // right on top of the MFM bit cells)
   //
   always @(posedge clk_50)
     if (mfm_state != raw_mfm)
       begin
          mfm_state <= raw_mfm;
          if (div_counter > 2)
            div_counter = div_counter - 1;
          else if (div_counter == 0)
            next_counter = COUNTER_VAL + 1;
       end
endmodule

//
// Decode a stream of MFM data.
// Input:
//    clk_5       - 5 MHz clock, synchroncized on MFM data
//    raw_mfm     - Raw, undecoded MFM.
// Output:
//    mfm_buffer  - 32 bit holds the raw MFM data
//    byte_buffer - 16 bit, 2-byte decoded MFM data
//
module MFM_Decoder (clk_5, raw_mfm, mfm_buffer, word_buffer, byte_buffer);
   input clk_5;
   input raw_mfm;

   output [31:0] mfm_buffer;
   output [15:0] word_buffer;
   output [7:0] byte_buffer;

   reg [31:0] mfm_buffer;

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

   assign word_buffer = {mfm_buffer[31],
                         mfm_buffer[29],
                         mfm_buffer[27],
                         mfm_buffer[25],
                         mfm_buffer[23],
                         mfm_buffer[21],
                         mfm_buffer[19],
                         mfm_buffer[17],
                         mfm_buffer[15],
                         mfm_buffer[13],
                         mfm_buffer[11],
                         mfm_buffer[9],
                         mfm_buffer[7],
                         mfm_buffer[5],
                         mfm_buffer[3],
                         mfm_buffer[1]};

   assign byte_buffer = {mfm_buffer[15],
                         mfm_buffer[13],
                         mfm_buffer[11],
                         mfm_buffer[9],
                         mfm_buffer[7],
                         mfm_buffer[5],
                         mfm_buffer[3],
                         mfm_buffer[1]};
endmodule

//
// Watch the MFM buffer for the "4E" gap pattern, and when found,
// assert "sync" (active low)
//
module WD_Gap_Scanner (clk_50, byte_buffer, sync);
   parameter GAP_VAL = 8'h4e; // The gap value 4E4E

   input clk_50;
   input [7:0] byte_buffer;

   output sync;
   reg sync;

   initial
     sync = 1;

   always @(negedge clk_50)
     begin
        if (byte_buffer == GAP_VAL)
          sync = 0;
        else
          sync = 1;
     end
endmodule

//
// When "sync" is asserted, start consuming bytes from the byte
// buffer, one at a time, and put them in data_buffer.
//
// When data is ready to be read, "data_valid" (active low) is asserted.
//
module WD_Decoder (clk_50, sync, byte_buffer, data_buffer, data_valid);

   parameter ID_VAL = 8'h1a;

   input clk_50;
   // 'ready' is active low
   input sync;

   input [7:0] byte_buffer;
   output [7:0] data_buffer;
   output       data_valid;

   reg          data_valid;
   reg [7:0]    data_buffer;
   reg [7:0]    counter;

   // 'ready' is active low
   reg          ready;

   initial
     begin
        counter = 0;
        ready = 1;
        data_buffer = 0;
        data_valid = 1;
     end

   always @(posedge clk_50)
     begin
        if (ready == 0)
          begin
             if (counter == 0)
               begin
                  data_buffer = byte_buffer;
                  counter = 7'h4F;
               end
             else
               begin
                  counter = counter - 1;
                  // Data Ready should go high again 15 clocks before
                  // the next read.
                  if (counter < 7'h40 && counter > 7'h0f)
                    data_valid = 0;
                  else
                    // De-assert
                    data_valid = 1;
               end
          end
        else
          begin
             if (sync == 0)
               ready = 0;
          end
     end

endmodule
