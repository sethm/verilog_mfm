//
// When "sync" is asserted, start consuming bytes from the byte
// buffer, one at a time, and put them in data_buffer.
//
// When data is ready to be read, "data_valid" (active low) is asserted.
//
module WD_Decoder (reset, clk_50, sync,
                   byte_buffer, data_buffer, data_valid);

   parameter ID_VAL = 8'h1a;

   input reset;
   input clk_50;
   // Input from gap scanner, active high
   input sync;

   input [7:0] byte_buffer;
   output [7:0] data_buffer;
   output       data_valid;

   reg          data_valid;
   reg [7:0]    data_buffer;
   reg [7:0]    counter;

   // 'ready' is active low
   reg          synced;

   always @(posedge clk_50) begin
      if (~reset) begin
         synced = 0;
         data_valid = 1;
         counter = 0;
      end
      else if (synced) begin
         if (counter == 0) begin
            data_buffer = byte_buffer;
            counter = 7'h4F;
         end
         else begin
            counter = counter - 1;
            // Data is valid 15 clock cycles after
            // it's latched, and 15 cycles before
            // the next expected read.
            if (counter < 7'h40 && counter > 7'h0f)
              data_valid = 0; // Valid. Active low
            else
              data_valid = 1; // Not valid. Active low
         end
      end
      else begin
         // Latch the sync signal from the gap scanner.
         if (sync)
           synced = 1;
      end
   end

endmodule
