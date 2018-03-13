#!/bin/sh

clusternum=20

for((year=2015;year<=2015;year++))
do
    for((ci=1;ci<=$clusternum;ci++))
    do

         name=RF_Pred$year\_$ci
         qsub -N $name -q long.q -o /home/jbi6/log -e /home/jbi6/log qsub_script_rf_pred $year $ci $clusternum

    done
done

