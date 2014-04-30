module MFM_Shift_Test;

   reg clk;
   reg load;
   reg [2:0] pulses;
   wire so;
   wire done;

   MFM_Shift s1 (.clk (clk),
                 .load (load),
                 .pulses (pulses),
                 .so (so),
                 .done (done));

   // Simulate a clock
   initial
     begin
        pulses = 2;
        clk = 0;
     end

   always
     begin
        clk = !clk;
        #5;
     end

   initial
     begin
        load = 1;
        #10;
        load = 0;

        #140;

        pulses = 3;

        load = 1;
        #10;
        load = 0;

        #180;

        pulses = 5;

        load = 1;
        #10;
        load = 0;

        #180;

        pulses = 3;

        load = 1;
        #10;
        load = 0;

        #180;

        $finish;
     end

   initial
     begin
        $monitor("%0t %0d %0d %0d %0d", $time, clk, so, done, load);
     end


endmodule // test
