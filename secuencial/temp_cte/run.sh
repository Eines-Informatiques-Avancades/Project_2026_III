#!/bin/csh
#$ -N paralel_sim
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
module load intel_compiler_suite/2023.0

##########################################
# Copying files needed
##########################################

setenv old `pwd`

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

#Making SEQUENTIAL RESULTS directory
mkdir -p $TMPDIR/SEQUENTIAL_RESULTS
mkdir -p $old/SEQUENTIAL_RESULTS

##########################################
# Run the job
##########################################
# We compile and run parallel program

make run_all

# Execute simulation (OMP_NUM_THREADS is set in Makefile)
./programa_mc.exe

##########################################
# Copy the results to our home directory
##########################################

cp timing_data.txt $TMPDIR/SEQUENTIAL_RESULTS/ >& /dev/null
cp -r SEQUENTIAL_RESULTS/* $old/SEQUENTIAL_RESULTS/ >& /dev/null

