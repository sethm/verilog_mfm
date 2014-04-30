set terminal png size 1300,200
set size ratio 0.05
set key left
unset border
unset title
set grid
unset tics
#set format x ""
#set ytics 0,1
#set xtics 0,10
set style data steps
#set multiplot layout 2,1
set multiplot
plot "graph.txt" using 1:2 notitle with steps linecolor 2
plot "graph.txt" using 1:3 notitle with steps linecolor 1 linewidth 3
unset multiplot
