//
// Watch the MFM buffer for the "4E" gap pattern, and when found,
// assert "sync". Sync is an internal-only line, and therefore
// it's active high.
//
module WD_Gap_Scanner (clk_50, byte_buffer, sync);
   parameter GAP_VAL = 8'h4e; // The gap value 4E4E

   input clk_50;
   input [7:0] byte_buffer;

   output sync;
   reg sync;

   always @(negedge clk_50) begin
      if (byte_buffer == GAP_VAL)
        sync = 1;
      else
        sync = 0;
   end
endmodule
