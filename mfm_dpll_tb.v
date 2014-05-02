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

        #100;
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

        #100
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #150
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #100
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #150
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #50
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #100
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #50
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #100
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #100
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #100
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #100
        raw_mfm = 1;
        #50;
        raw_mfm = 0;

        #200;

        $finish;
     end

   initial
     begin
        $monitor("%0t %0d %0d %0d", $time, clk_50, raw_mfm, clk_5);
     end

endmodule // test
