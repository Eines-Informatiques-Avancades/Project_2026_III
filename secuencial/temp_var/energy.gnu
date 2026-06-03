set terminal pngcairo size 800,600 font 'sans,10'
set grid
set key top right
set output OUTFILE
set title "Energy Evolution T=".TEMP
set xlabel "Step"
set ylabel "Energy (kJ/mol)"

plot INFILE u ($0*10):(column(1)) w l lt 1 lc rgb 'blue' title 'Total Energy', \
     INFILE u ($0*10):(column(2)) w l lt 1 lc rgb 'orange' title 'LJ Energy', \
     INFILE u ($0*10):(column(3)) w l lt 1 lc rgb 'green' title 'Dihedral Energy', \
     INFILE u ($0*10):(column(4)) w l dt 2 lc rgb 'red' lw 2 title 'Temperature'