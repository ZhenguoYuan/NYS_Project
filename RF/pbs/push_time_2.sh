#!/bin/sh
## Automatic submitting a new year's RF Gap-filling when last year's modeling is done

for year in 2014
do
    bash submit_time.sh $year
done
