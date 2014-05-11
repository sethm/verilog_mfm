#!/usr/bin/env python

import sys
import re
from os.path import isfile
from decimal import *

deltas = []

max_lines = 10000

def gen_tb_header():
    print """module mfm_test();

   reg reset;
   reg clk_50;
   reg raw_mfm;

   wire clk_5;
   wire sync;

   wire [31:0] mfm_buffer;
   wire [15:0] word_buffer;
   wire [7:0]  byte_buffer;

   wire [7:0] data_buffer;
   wire data_valid;

   MFM_DPLL pll (.reset (reset),
                 .clk_50 (clk_50),
                 .raw_mfm (raw_mfm),
                 .clk_5 (clk_5));

   MFM_Decoder decoder (.clk_5 (clk_5),
                        .raw_mfm (raw_mfm),
                        .mfm_buffer (mfm_buffer),
                        .word_buffer (word_buffer),
                        .byte_buffer (byte_buffer));

   WD_Gap_Scanner scanner (.clk_50 (clk_50),
                           .byte_buffer (byte_buffer),
                           .sync (sync));

   WD_Decoder wdd (.reset (reset),
                   .clk_50 (clk_50),
                   .sync (sync),
                   .byte_buffer (byte_buffer),
                   .data_buffer (data_buffer),
                   .data_valid (data_valid));

   initial begin
      reset = 1;   // active low
      clk_50 = 0;
      raw_mfm = 0;
   end

   // Simulate a clock
   always begin
      #5;
      clk_50 = !clk_50;
   end

   // Every 50 steps is one full 5 MHz MFM pulse width.
   initial begin

      #10 reset = 0;
      #100 reset = 1;

"""

def gen_tb_footer():
    print """

      $finish;
   end

   initial
     begin
        $monitor("%0t %0d %0d %032b 0x%08x %08b 0x%02x %d %08b 0x%02x %d",
                 $time, clk_5, raw_mfm, mfm_buffer, mfm_buffer,
                 byte_buffer, byte_buffer, sync,
                 data_buffer, data_buffer,
                 data_valid);
     end

endmodule"""

def gen_delta_line(delay):
    print "         raw_mfm = 1; #50; raw_mfm = 0; #%s;" % delay

def consume_file(file):
    data = open(file)

    line_count = 0
    last_time = -1

    for line in data:
        if line_count > max_lines:
            break

        tm = re.search('^(.+),', line)
        vm = re.search(', (.)$', line)

        t = Decimal(tm.group(1)) * Decimal(1e9)
        v = int(vm.group(1))

        if v == 0:
            continue

        if last_time == -1:
            last_time = t
            continue

        deltas.append(t - last_time)
        last_time = t

        line_count = line_count + 1



def gen_tb_body():
    print "         #250;"

    for delta in deltas:
        if (delta < 260):
            gen_delta_line(50)
            continue
        if (delta < 360):
            gen_delta_line(100)
            continue
        if (delta < 460):
            gen_delta_line(150)
            continue
        else:
            gen_delta_line(200)

    print "         #250;"
    print "         $finish;"

def gen_tb():
    gen_tb_header()
    gen_tb_body()
    gen_tb_footer()
    pass


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print "Usage: mfm2tb.py <file>"
        exit(1)

    if not isfile(sys.argv[1]):
        print "Can't read file `%s'." % sys.argv[1]
        exit(1)

    consume_file(sys.argv[1])

    gen_tb()
