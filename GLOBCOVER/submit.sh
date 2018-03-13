#!/bin/sh

name=GLOBCOVER
qsub -N $name -o /home/jbi6/log -e /home/jbi6/log qsub_script 
