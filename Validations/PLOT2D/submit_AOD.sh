#!/bin/sh

name=Combine4PLOT_AOD
qsub -N $name -o /home/jbi6/log -e /home/jbi6/log qsub_script_AOD
