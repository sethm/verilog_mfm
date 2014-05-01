module MFM_Shift_Test;

   reg clk_50;
   reg raw_mfm;

   wire clk_5;

   MFM_DPLL pll (.clk_50 (clk_50),
                 .raw_mfm (raw_mfm),
                 .clk_5 (clk_5));

   // Simulate a clock
   initial
     begin
        clk_50 = 0;
        raw_mfm = 0;
     end

   always
     begin
        #1;
        clk_50 = !clk_50;
     end

   initial
     begin

        #71; raw_mfm = 1;
        #20; raw_mfm = 0;

        #40; raw_mfm = 1;
        #20; raw_mfm = 0;

        #40; raw_mfm = 1;
        #20; raw_mfm = 0;

        #40; raw_mfm = 1;
        #20; raw_mfm = 0;

        #40; raw_mfm = 1;
        #20; raw_mfm = 0;

        #43; raw_mfm = 1;
        #20; raw_mfm = 0;

        #38; raw_mfm = 1;
        #20; raw_mfm = 0;

        #60; raw_mfm = 1;
        #20; raw_mfm = 0;

        #40; raw_mfm = 1;
        #20; raw_mfm = 0;

        #80; raw_mfm = 1;
        #20; raw_mfm = 0;

        #100;

        $finish;
     end

   initial
     begin
        $monitor("%0t %0d %0d %0d", $time, clk_50, raw_mfm, clk_5);
     end

endmodule // test
