#!/bin/sh

clusternum=20

for((ci=1;ci<=$clusternum;ci++))
do
    name=RF$1\_$ci
    qsub -N $name -q short.q -l h=!condor -o /home/jbi6/log -e /home/jbi6/log qsub_script $1 $ci $clusternum
done

