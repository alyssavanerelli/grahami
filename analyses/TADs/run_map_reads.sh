#!/bin/bash
SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/grahami/juicerdir/AnoGra/fastq/*.gz | cut -d "/" -f 9 | cut -d "_" -f 1 | sort | uniq)
for SAMPLE in $SAMPLES
	do
	CMD="sbatch map_reads.sh ${SAMPLE}"
	echo $CMD
	#eval $CMD
	sleep 0.25
done
