#!/bin/sh


for((year=2013;year<=2014;year++))
do
    name=NDVI$year
    qsub -v YEAR=$year,NAME=$name qsub_pbs
done

