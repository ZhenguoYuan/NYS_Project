#!/bin/sh

clusternum=10

for((year=2013;year<=2014;year++))
do
    for((ci=1;ci<=$clusternum;ci++))
    do
        qsub -v YEAR=$year,CI=$ci,CLUST=$clusternum qsub_pbs 
    done
done

