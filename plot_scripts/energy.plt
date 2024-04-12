outputName = sprintf("%s.energy.pdf", outputFileName)
inputName = sprintf("%s.energy.txt", outputFileName)
set terminal pdfcairo enhanced color size 5in,2.5in font "Linux Libertine, 21"
set output outputName

set style data histograms
set style histogram rowstacked
set style fill solid 1.0 border -1

set boxwidth 0.75 relative
set style fill solid 1.0 border -1

set xlabel 'Scenario'
set ylabel 'Joule'
set yrange [0:*]
set ytics 10000

set key below center

# Format: <Scenario> <GPU Value> <CPU Value>
plot inputName using 2:xtic(1) title '   CPU' lt 1 lc rgb "skyblue", '' using 3:xtic(1) title '   GPU' lt 1 lc rgb "light-coral"
