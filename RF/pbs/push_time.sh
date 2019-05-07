#!/bin/sh
## Automatic submitting a new year's RF Gap-filling when last year's modeling is done

for year in 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 2016
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
