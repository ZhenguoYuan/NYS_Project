#!/bin/sh


for((year=2015;year<=2016;year++))
do
    name=NDVI$year
    qsub -N $name -q long.q -o /home/jbi6/log -e /home/jbi6/log qsub_script $year
done

