#!/bin/sh

name=MI
qsub -N $name -q long.q -o /home/jbi6/log -e /home/jbi6/log qsub_script
