#!/bin/bash
INPUT_DIR="/projects/f_geneva_1/data/denovo_genomes/grahami_fixed"
OUTDIR="/projects/f_geneva_1/alyssa/grahami/hicexplorer/hic_reads"

FILES=$(ls -1 /projects/f_geneva_1/data/denovo_genomes/grahami_fixed/DTG-HiC-* | cut -d "/" -f 7 | sort | uniq)
for FILE in $FILES
        do 
        CMD="ln -s ${INPUT_DIR}/${FILE} ${OUTDIR}/"
        echo $CMD
        #eval $CMD
        sleep 0.25
done
