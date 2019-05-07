#!/bin/sh

clusternum=20

for((ci=1;ci<=$clusternum;ci++))
do
    qsub -v YEAR=$1,CI=$ci,CLUST=$clusternum qsub_script
done

