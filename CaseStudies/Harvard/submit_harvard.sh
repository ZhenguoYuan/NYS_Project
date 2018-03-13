#!/bin/sh

clusternum=12

for((year=2015;year<=2015;year++))
do
    for((ci=1;ci<=$clusternum;ci++))
    do
        name=Harvard$year\_$ci
        qsub -N $name -o /home/jbi6/log -e /home/jbi6/log qsub_script_harvard $year $ci $clusternum
    done
done

