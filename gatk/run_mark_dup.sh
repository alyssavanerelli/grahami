#!/bin/bash
SAMPLES=$(cut -f 1 /projects/f_geneva_1/alyssa/sagrei/4_lanes.txt | sort | uniq)
for SAMPLE in $SAMPLES
	do
	CMD="sbatch mark_dup.sh ${SAMPLE}"
	echo $CMD
	#eval $CMD
	sleep 0.25
done
