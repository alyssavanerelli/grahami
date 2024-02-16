#!/bin/bash
LISTS=$(ls -1 /projects/f_geneva_1/alyssa/grahami/gatk/*.list | cut -d "/" -f 7 | cut -d "." -f 1 | sort | uniq)
for LIST in $LISTS
	do
	CMD="sbatch hap_call.sh ${LIST}"
	echo $CMD
	#eval $CMD
	sleep 0.25
done
