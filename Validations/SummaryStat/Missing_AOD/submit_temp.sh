#!/bin/sh

for((year=2015;year<=2015;year++))
do
    name=temporal$year
    qsub -N $name -q short.q -o /home/jbi6/log -e /home/jbi6/log qsub_script_temp $year
done

