VERILOG=iverilog
VVP=vvp
GNUPLOT=gnuplot

.PHONY: clean

all: graph.txt

testbench.v:
	./mfm2tb.py data/test1.csv > testbench.v

mfm: testbench.v
	$(VERILOG) -o mfm testbench.v mfm.v \
		mfm_dpll.v mfm_decoder.v \
		wd_gap_scanner.v wd_decoder.v

graph.txt: mfm
	vvp mfm | tee graph.txt

graph.png: graph.txt
	$(GNUPLOT) graph.gnuplot > graph.png

clean:
	rm -f mfm graph.txt testbench.v *.png *~
