#!/bin/sh
## Automatic submitting a new year's RF Gap-filling when last year's modeling is done

for year in 2011 2012
do
    while true
    do
        clear
        echo 'waiting...'
        qstatnum=$(qstat | wc -l)
        if [ $qstatnum -le 2 ]
        then
            bash submit_time.sh $year
	    break
        fi
    done
done
