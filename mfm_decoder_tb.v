module MFM_Decoder_Test;

   reg clk_50;
   reg raw_mfm;

   wire clk_5;

   wire [15:0] mfm_buffer;
   wire [7:0] byte_buffer;

   MFM_DPLL pll (.clk_50 (clk_50),
                 .raw_mfm (raw_mfm),
                 .clk_5 (clk_5));

   MFM_Decoder decoder (.clk_5 (clk_5),
                        .raw_mfm (raw_mfm),
                        .mfm_buffer (mfm_buffer),
                        .byte_buffer (byte_buffer));

   // Simulate a clock
   initial
     begin
        clk_50 = 0;
        raw_mfm = 0;
     end

   always
     begin
        #5;
        clk_50 = !clk_50;
     end

   // Every 50 steps is one full 5 MHz MFM pulse width.
   initial
     begin

        #150;
        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #150;

        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #100;

        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #150;

        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #100;

        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #50;

        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #150;

        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #100;

        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #150;

        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #100;

        raw_mfm = 1;
        #50;
        raw_mfm = 0;
        #50;

        $finish;
     end

   initial
     begin
        $monitor("%0t %0d %0d %016b (0x%04x) %08b (0x%02x)",
                 $time, clk_5, raw_mfm, mfm_buffer, mfm_buffer, byte_buffer, byte_buffer);
     end

endmodule // test
