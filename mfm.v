module MFM (clk_50, raw_mfm, reset, data_buffer, data_valid, status_led1, status_led2);

   input clk_50, raw_mfm, reset;
   output [7:0] data_buffer;
   output data_valid;
   output status_led1;
   output status_led2;

   wire clk_5;

   MFM_DPLL pll(.reset (reset),
                .clk_50 (clk_50),
                .raw_mfm (raw_mfm),
                .clk_5 (clk_5));

   wire [15:0] mfm_buffer;
   wire [7:0] byte_buffer;

   MFM_Decoder decoder(.clk_5 (clk_5),
                       .raw_mfm (raw_mfm),
                       .mfm_buffer (mfm_buffer),
                       .byte_buffer (byte_buffer));

   wire sync;

   WD_Gap_Scanner scanner(.clk_50 (clk_50),
                          .byte_buffer (byte_buffer),
                          .sync (sync));

   WD_Decoder wd_decoder(.reset (reset),
                         .clk_50 (clk_50),
                         .sync (sync),
                         .byte_buffer (byte_buffer),
                         .data_buffer (data_buffer),
                         .data_valid (data_valid),
                         .status_led1 (status_led1),
                         .status_led2 (status_led2));

endmodule
