#!/bin/sh

name=Combine4PM25
qsub -N $name -o /home/jbi6/log -e /home/jbi6/log qsub_script 
