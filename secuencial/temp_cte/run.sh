#!/bin/csh
#$ -N MC_sim
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
module load intel_compiler_suite/2023.0

##########################################
# Copying files needed
##########################################

setenv old $cwd

setenv root_pro $old/../..

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

#Making SECUENTIAL RESULTS directory
mkdir -p $TMPDIR/RESULTS
mkdir -p $old/RESULTS

#Extracting modules needed for the parallel program
mv modules/* .
mv main/main_temp_cte_sec.f90 .

##########################################
# Run the job
##########################################
# We compile and run parallel program

echo $cwd

make run_sec_cte

# Execute simulation (OMP_NUM_THREADS is set in Makefile)
./programa_sec_cte.exe

##########################################
# Copy the results to our home directory
##########################################

cp $TMPDIR/RESULTS/ >& /dev/null
cp -r RESULTS/* $old/RESULTS/ >& /dev/null

