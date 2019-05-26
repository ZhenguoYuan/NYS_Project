#!/bin/sh

clusternum=3

for((year=2002;year<=2016;year++))
do
    for((ci=1;ci<=$clusternum;ci++))
    do
        qsub -v YEAR=$year,CI=$ci,CLUST=$clusternum qsub_pbs 
    done
done

