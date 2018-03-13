#!/bin/sh

clusternum=20

for((year=2015;year<=2015;year++))
do
    for((ci=1;ci<=$clusternum;ci++))
    do
        name=CldOnly$year\_$ci
        qsub -N $name -q short.q -l h=!condor -o /home/jbi6/log -e /home/jbi6/log qsub_script_rf $year $ci $clusternum
    done
done

