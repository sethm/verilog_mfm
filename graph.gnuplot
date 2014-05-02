set terminal png size 4000,400
set size ratio 0.02
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
set yrange [0:1]

set origin 0,0.12
# set key at 8,-0.30
plot "graph.txt" using 1:2 notitle with steps linecolor 1 linewidth 2
set origin 0,-0.12
# set key at 0,-0.05
plot "graph.txt" using 1:3 notitle with steps linecolor 3 linewidth 2
unset multiplot
