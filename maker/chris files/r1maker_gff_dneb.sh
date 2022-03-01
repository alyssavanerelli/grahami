#!/bin/sh
#SBATCH --partition=main
#SBATCH --job-name=maker_dneb1_gff1
#SBATCH --mem=32000
#SBATCH -n 8
#SBATCH -N 1
#SBATCH --time=05:00:00
#SBATCH --requeue
#SBATCH --mail-user=c.sottolano@rutgers.edu
#SBATCH --mail-type=BEGIN,END,FAIL,REQUEUE

cd /scratch/cjs374/maker/pilon_dneb1_cmp3.maker.output

# transcript alignments
awk '{ if ($2 == "est2genome") print $0 }' dneb1_rnd1.all.maker.noseq.gff > dneb_rnd1.all.maker.est2genome.gff
# protein alignments
awk '{ if ($2 == "protein2genome") print $0 }' dneb1_rnd1.all.maker.noseq.gff > dneb_rnd1.all.maker.protein2genome.gff
# repeat alignments
awk '{ if ($2 ~ "repeat") print $0 }' dneb1_rnd1.all.maker.noseq.gff > dneb_rnd1.all.maker.repeats.gff
