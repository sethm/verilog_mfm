#!/bin/bash

if [ "$1" = "clean" ] ; then
    echo "Cleaning..."
    rm -f graph.png
    rm -f *.OLD
    rm -f module
    rm -f graph.txt
    exit
fi

if [ -f graph.png ] ; then
    mv -f graph.png graph.png.OLD
fi

iverilog -o module mfm_shift_register_tb.v mfm_shift_register.v &&
    vvp module > graph.txt &&
    gnuplot graph.gnuplot > graph.png &&
    open graph.png
