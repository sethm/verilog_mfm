#!/bin/bash

if [ "$1" = "clean" ] ; then
    echo "Cleaning..."
    rm -f graph.png
    rm -f *.OLD
    rm -f mfm
    rm -f graph.txt
    exit
fi

if [ -f graph.png ] ; then
    mv -f graph.png graph.png.OLD
fi

iverilog -o mfm mfm_decoder_tb.v mfm.v &&
    vvp mfm | tee graph.txt &&
    gnuplot graph.gnuplot > graph.png
