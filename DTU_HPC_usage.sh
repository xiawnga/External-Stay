#Login in cmd
ssh username@login1.hpc.dtu.dk

#Login in WinSCP for files exchange
transfer.gbar.dtu.dk

#Submit a job
bsub < job.sh

#Kill the job
bkill [your job ID]

#See all the jobs on HPC
bjobs -u all -q gpuv100
