//
// When "sync" is asserted, start consuming bytes from the byte
// buffer, one at a time, and put them in data_buffer.
//
// When data is ready to be read, "data_valid" (active low) is asserted.
//
module WD_Decoder (reset, clk_50, sync,
                   byte_buffer, data_buffer,
                   data_valid, status_led1, status_led2);

   parameter ID_VAL = 8'h1a;

   input        reset;
   input        clk_50;
   // Input from gap scanner, active high
   input        sync;

   input  [7:0] byte_buffer;
   output [7:0] data_buffer;
   output       data_valid;
   output       status_led1;
   output       status_led2;

   reg          data_valid;
   reg [7:0]    data_buffer;
   reg [7:0]    counter;
   reg          status_led1;
   reg          status_led2;
   reg          synced;

   always @(posedge clk_50) begin
      if (~reset) begin
         status_led1 = 1;
         status_led2 = 1;
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
            if (counter < 7'h40 && counter > 7'h0f) begin
               status_led1 = 0;
               data_valid = 0; // Valid. Active low
            end
            else begin
               status_led1 = 1;
               data_valid = 1; // Not valid. Active low
            end
         end
      end
      else begin
         // Latch the sync signal from the gap scanner.
         if (sync) begin
            synced = 1;
            status_led2 = 0;
         end
      end
   end

endmodule
