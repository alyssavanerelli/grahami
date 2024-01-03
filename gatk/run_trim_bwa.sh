#!/bin/bash
FILES=$(ls -1 /projects/f_geneva_1/data/sagrei_populations/*.fastq.gz | cut -d "/" -f 6 | cut -d "_" -f 1-3 | sort | uniq)
for FILE in $FILES
	do
	CMD="sbatch trim_bwa.sh ${FILE}"
	echo $CMD
	#eval $CMD
	sleep 0.25
done
