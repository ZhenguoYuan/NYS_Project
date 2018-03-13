#!/bin/sh

clusternum=12

for((year=2002;year<=2016;year++))
do
    for((ci=1;ci<=$clusternum;ci++))
    do
        name=MODIS$year\_$ci
        qsub -N $name -o /home/jbi6/log -e /home/jbi6/log qsub_script $year $ci $clusternum
    done
done

