set terminal pngcairo size 800,600
set grid
set output OUTFILE
set title "Distribution of Dihedral Angles T=".TEMP
set xlabel "Dihedral Angle (degrees)"; set ylabel "Density"
set style fill solid 1.0
binwidth = 5
set boxwidth binwidth
bin(x,width) = width*floor(x/width) + width/2.0
stats INFILE u 1 name 'S' nooutput
plot INFILE u (bin(column(1),binwidth)):(1.0/(S_records*binwidth)) smooth frequency with boxes title 'Density'