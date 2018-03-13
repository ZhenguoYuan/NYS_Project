#!/bin/sh

clusternum=20
year=2010
ci=10
name=RF$year\_$ci

qsub -N $name -q short.q -l h=!condor -o /home/jbi6/log -e /home/jbi6/log qsub_script $year $ci $clusternum

