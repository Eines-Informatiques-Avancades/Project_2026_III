#!/bin/csh
#$ -N paralel_sim
#$ -pe omp* 6
#$ -q cerqt03.q
#$ -S /bin/csh
#$ -cwd
#$ -o MC.out
#$ -e MC.err
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

setenv old `pwd`

setenv OMP_NUM_THREADS $NSLOTS

#If TMPDIR does not exist, we define it

if ( ! $?TMPDIR ) then
    setenv TMPDIR /tmp/$USER/job_test
    mkdir -p $TMPDIR
endif

#We clean TMPDIR
cd $TMPDIR

make clean_tmpdir

#Copy my files to tmpdir

cp -r $old/* $TMPDIR/

pwd

#Making PARALEL RESULTS directory
mkdir -p $TMPDIR/PARALEL_RESULTS
mkdir -p $old/PARALEL_RESULTS

##########################################
# Run the job
##########################################
# We compile and run parallel program

make run_all PARAL=1 

# Execute simulation (OMP_NUM_THREADS is set in Makefile)
./programa_mc.exe

##########################################
# Copy the results to our home directory
##########################################

cp timing_data.txt $TMPDIR/PARALEL_RESULTS/ >& /dev/null
cp -r PARALEL_RESULTS/* $old/PARALEL_RESULTS/ >& /dev/null

