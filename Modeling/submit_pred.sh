#!/bin/sh

for((year=2009;year<=2009;year++))
do
     name=Pred$year
     qsub -N $name -o /home/jbi6/log -e /home/jbi6/log qsub_script_pred $year
done

