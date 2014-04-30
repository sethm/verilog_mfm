// MFM shift register.
// Operation:
//    - Load with data "d" iff
//      - Initializing, or
//      - "one_out" is high.
//

module MFM_Shift (clk, load, si, d, so);
   input clk;           // Clock
   input si;            // Serial input
   input load;          // Asynchronous load
   input [5:0] d;       // Parallel input
   output so;      // Serial output
   reg [5:0] tmp;     // Internal register

   always @(posedge clk or posedge load)
     begin
        // Load up the tmp register
        if (load)
          tmp <= d;
        else
          begin
             tmp = {tmp[4:0], si};
          end
     end
   assign so = tmp[5];
endmodule
