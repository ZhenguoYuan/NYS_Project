#!/bin/sh

## Declare an array for AOT type
declare -a typearr=(AAOT TAOT)
## Cluster number
clusternum=20

for((year=2002;year<=2003;year++))
do
    for type in ${typearr[@]}
    do
        for((ci=1;ci<=clusternum;ci++))
        do

            name=MAIAC$year\_$type\_$ci
            qsub -N $name -o /home/jbi6/log -e /home/jbi6/log qsub_script $year $type $ci $clusternum

        done
    done
done

