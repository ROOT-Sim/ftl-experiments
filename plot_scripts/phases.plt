
set terminal pdfcairo enhanced color size 5in,2.5in font "Linux Libertine, 20"
set output '../run_logs/unbalanced/3.processed.pdf'

set style line 1 lt 1 lw 2 lc rgb "blue" # Solid line
set style line 2 dt "." lw 2 lc rgb "blue" # Dashed line

set style line 101 lc rgb "black" lt 1 lw 2 # Line style for border

# Background styles (semi-transparent colors)
set style fill transparent solid 0.5

set xlabel "Wall Clock Time"
set ylabel "Global Virtual Time"
set xrange [0:132]
set yrange [0:64000000]
set key below center maxcols 10 maxrows 1
set bmargin 5.5
set ytics 8000000
set ytics 9000000
set grid noxtics ytics

set object 1 rect from 0.0, graph 0 to 0.0, graph 1 back fc rgb "green" fs transparent solid 0.2 noborder
set object 2 rect from 0.0, graph 0 to 83.311506, graph 1 back fc rgb "yellow" fs transparent solid 0.2 noborder

# Plot command to iterate through unique line styles in the third column
plot for [i=0:1] '../run_logs/unbalanced/3.processed.txt' u 1:($3==i?$2:1/0) w lines linestyle i+1 notitle,\
NaN  title 'Unbalanced' with boxes ls 101 lc rgb "yellow" fs transparent solid 0.2,\
NaN  title 'Balanced' with boxes ls 101 lc rgb "green" fs transparent solid 0.2,\
NaN  title 'On CPU' w lines linestyle 1,\
NaN  title 'On GPU' w lines linestyle 2