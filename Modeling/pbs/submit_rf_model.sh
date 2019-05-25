#!/bin/sh

for((year=2002;year<=2016;year++))
do
     qsub -v YEAR=$year qsub_script_model
done

