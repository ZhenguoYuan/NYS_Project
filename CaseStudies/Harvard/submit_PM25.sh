#!/bin/sh

for year in `seq 2015 2015`;
do
    name=Combine4PLOTPM25_$year
    qsub -N $name -q long.q -o /home/jbi6/log -e /home/jbi6/log qsub_script_PM25 $year
done
