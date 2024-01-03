#!/bin/bash
FILES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/bam/*.bam)
for FILE in $FILES
	do
	CMD="sbatch stats_d_b.sh ${FILE}"
	echo $CMD
	#eval $CMD
	sleep 0.25
done
