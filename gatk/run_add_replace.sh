#!/bin/bash
SAMPLES=$(ls -1 /projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/bwa/*.bam | cut -d "_" -f 1-5 | cut -d "/" -f 8 | sort | uniq)
for SAMPLE in $SAMPLES
  do
	BAMS=$(ls -1 /projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/bwa/*${SAMPLE}*.bam | cut -d "_" -f 1-7 | cut -d "/" -f 8 | sort | uniq)
	for BAM in $BAMS
		do
		READS=$(ls -1 /projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/trimmed/${SAMPLE}_filtered.R1.fq.gz | cut -d "/" -f 8 | cut -d "." -f 1-3 | sort | uniq)
		for READ in $READS
			do
			PU=$(zcat /projects/f_geneva_1/alyssa/jamaica-mtgenome/phylogeny/trimmed/${READ}.gz | head -n 1 | cut -d ":" -f 3-5)
		done
		CMD="sbatch add_replace.sh ${SAMPLE} ${BAM} ${PU} ${READ}"
		echo $CMD
		#eval $CMD
		#sleep 0.25
	done
done
