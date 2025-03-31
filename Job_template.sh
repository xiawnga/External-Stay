#!/bin/sh
# embedded options to bsub - start with #BSUB
### -- set the job Name --
#BSUB -J NAME_TEMPLATE
### -- specify queue --
#BSUB -q hpc
### -- ask for number of cores (default: 1) --
#BSUB -n 16
### -- set walltime limit: hh:mm --
#BSUB -W 24:00 
### -- specify that we need 4GB of memory per core/slot -- 
#BSUB -R "rusage[mem=4GB]"
### -- set the email address --
# please uncomment the following line and put in your e-mail address,
# if you want to receive e-mail notifications on a non-default address
##BSUB -u EMAIL_TEMPLATE
### -- send notification at start --
#BSUB -B
### -- send notification at completion--
#BSUB -N
### -- Specify the output and error file. %J is the job-id -- 
### -- -o and -e mean append, -oo and -eo mean overwrite -- 
#BSUB -o Output_%J.out
#BSUB -e Output_%J.err
# here follow the commands you want to execute
# 

# load the necessary modules
# NOTE: this is just an example, check with the available modules

module load python3/3.10.12
module load mpi/5.0.5-gcc-14.2.0-binutils-2.43
module load povray/3.7.0.10-gcc-12.4.0

cd /DIRECTORY_TEMPLATE
### This uses the LSB_DJOB_NUMPROC to assign all the cores reserved
### This is a very basic syntax. For more complex examples, see the documentation
mpirun -np $LSB_DJOB_NUMPROC fepx
