# Chromosome Synteny Analysis using Satsuma1

SatsumaSynteny2 is not working well with SLURM so we are trying SatsaumaSynteny


# Resources
- [Satsuma](http://satsuma.sourceforge.net/)
- [Manual](http://satsuma.sourceforge.net/manual.html)

<details><summary>code from pietro</summary>
<p>
  
  ```
  #!/bin/bash
#SBATCH --job-name=Satsuma_sagrei_carolinensis
#SBATCH --partition=glor,kbs,bi,eeb
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=24
#SBATCH --time=20-00:00:00
#SBATCH --mem=500G
#SBATCH --mail-user=hollandademello@ku.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/panfs/pfs.local/scratch/glor/p470d241/Satsuma_sagrei_carolinensis_%j.log

# Here I will make a synteny plot between the A sagrei genome and the A carolinensis
# genome.

work_folder=/panfs/pfs.local/work/glor/p470d241/sagrei_synteny
out_folder=/panfs/pfs.local/scratch/glor/p470d241/sagrei_synteny
carolinensis_folder=/panfs/pfs.local/work/glor/p470d241/carolinensis_fasta
satsuma_folder=/panfs/pfs.local/work/glor/p470d241/Programs/satsuma-code-0

mkdir -p $out_folder/Satsuma
zcat $work_folder/AnoSag2.1.fa.gz > $out_folder/A_sagrei.fa
zcat $carolinensis_folder/Anolis_carolinensis.AnoCar2.0.dna.toplevel.fa.gz > $out_folder/A_carolinensis.fa

export PATH=/panfs/pfs.local/work/glor/p470d241/Programs/satsuma-code-0:$PATH

time $satsuma_folder/SatsumaSynteny \
-t $out_folder/A_sagrei.fa \
-q $out_folder/A_carolinensis.fa \
-o $out_folder/Satsuma/Satsuma_sagrei_carolinensis -n 24


</p>
</details>


# Installation
- Will install using source code






