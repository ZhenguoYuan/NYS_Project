#!/bin/sh

name=RF_perform_cldonly
qsub -N $name -q short.q -l h=!condor -o /home/jbi6/log -e /home/jbi6/log qsub_script_perform 


