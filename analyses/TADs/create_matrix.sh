hicBuildMatrix --samFiles mate_R1.bam mate_R2.bam \
                 --binSize 10000 \
                 --restrictionSequence GATC \
                 --danglingSequence GATC \
                 --restrictionCutFile cut_sites.bed \
                 --threads 4 \
                 --inputBufferSize 100000 \
                 --outBam hic.bam \
                 -o hic_matrix.h5 \
                 --QCfolder ./hicQC
