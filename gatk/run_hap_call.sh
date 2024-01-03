#!/bin/bash
SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/sagrei/mark_duplicates/*.bam | cut -d "/" -f 7 | cut -d "." -f 1 | sort | uniq)
for SAMPLE in $SAMPLES
	do
	CMD="sbatch hap_call.sh ${SAMPLE}"
	echo $CMD
	#eval $CMD
	sleep 0.25
done
