set terminal pngcairo size 800,600
set grid
set key top right
set output OUTFILE
set title "Distance distribution during equilibration T=".TEMP
set xlabel "Step"
set ylabel "Squared Distance (Angstroms^2)"
plot INFILE u ($0*10):(column(1)) w l title 'End-to-End Distance',\
     INFILE u ($0*10):(column(2)) w l title 'Radius of Gyration'