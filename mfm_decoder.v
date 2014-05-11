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

   always @(posedge clk_5 or negedge clk_5) begin
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
