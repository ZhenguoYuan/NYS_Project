#!/bin/sh

for((year=2002;year<=2016;year++))
do

    name=NARR$year
    qsub -N $name -o /home/jbi6/log -e /home/jbi6/log qsub_script.pbs $year

done

