#!/bin/sh

name=Combine4AERO
qsub -N $name -o /home/jbi6/log -e /home/jbi6/log qsub_script 
