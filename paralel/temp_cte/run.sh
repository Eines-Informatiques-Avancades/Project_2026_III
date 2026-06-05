#!/bin/csh
#$ -N paralel_sim
#$ -pe omp* 6
#$ -q cerqt03.q
#$ -S /bin/csh
#$ -cwd
#$ -o run.out
#$ -e run.err
##########################################
# User environment.
##########################################
# Load the modules needed

source /etc/profile.d/modules.csh
# CERQT03
module load intel_compiler_suite/2023.0 openmpi/4.1.6_ics-2023.0

##########################################
# Copying files needed
##########################################

setenv old $cwd

setenv root_pro $old/../..

setenv OMP_NUM_THREADS $NSLOTS

#If TMPDIR does not exist, we define it

if ( ! $?TMPDIR ) then
    setenv TMPDIR /tmp/$USER/job_test
    mkdir -p $TMPDIR
    echo "TMPDIR created"
endif

#We clean TMPDIR
cd $TMPDIR

make clean_tmpdir

#Copy my files to tmpdir

cp -r $root_pro/* $TMPDIR

echo $cwd

#Making PARALEL RESULTS directory
mkdir -p $TMPDIR/RESULTS
mkdir -p $old/RESULTS

#Extracting modules needed for the parallel program
mv modules/* .
mv omp_modules/* .
mv main/main_temp_cte_par.f90 .

##########################################
# Run the job
##########################################
# We compile and run parallel program

echo $cwd

make run_par_cte PARAL=1

# Execute simulation (OMP_NUM_THREADS is set in Makefile)
./programa_par_cte.exe

##########################################
# Copy the results to our home directory
##########################################

cp timing_data.txt $TMPDIR/RESULTS/ >& /dev/null
cp -r RESULTS/* $old/RESULTS/ >& /dev/null


