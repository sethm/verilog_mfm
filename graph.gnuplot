set terminal png size 1800,400
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
set multiplot
set origin 0,0.28

set key at 0,-0.06
plot "graph.txt" using 1:2 notitle with steps linecolor 2
plot "graph.txt" using 1:3 title "Output" with steps linecolor 1 linewidth 2
set origin 0,0
plot "graph.txt" using 1:5 title "Load" with steps linecolor 3 linewidth 2
set origin 0,-0.28
plot "graph.txt" using 1:4 title "Done" with steps linecolor 4 linewidth 2
unset multiplot
