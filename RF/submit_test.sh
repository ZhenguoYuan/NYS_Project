#!/bin/sh

name=RF_TEST
qsub -N $name -q short.q -o /home/jbi6/log -e /home/jbi6/log qsub_script_test

