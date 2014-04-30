module MFM_Shift_Test;

   reg clk, load, si;
   reg [5:0] d;
   wire so;

   MFM_Shift s1 (.clk (clk),
                 .load (load),
                 .si (si),
                 .d (d),
                 .so (so));

   // Simulate a clock
   initial
     begin
        clk = 1;
        load = 0;
        si = 0;
        d = 5'b01101;
     end

   always
     #5 clk = !clk;

   initial
     begin
        #0 load = 1;
        #10 load = 0;
        #200 $finish;
     end

   initial
     begin
        // $display("tick\tload\tsi\tclk\tso");
        // $monitor("%0t\t%0d\t%0d\t%0d\t%0d", $time, load, si, clk, so);
        $monitor("%0t %0d %0d", $time, clk, so);
     end


endmodule // test
