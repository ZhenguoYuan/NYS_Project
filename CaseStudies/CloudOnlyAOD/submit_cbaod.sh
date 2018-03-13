#!/bin/sh

name=CbAODCldOnly
qsub -N $name -q short.q -l h=!condor -o /home/jbi6/log -e /home/jbi6/log qsub_script_cbaod

