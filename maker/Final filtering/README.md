# Final filtering of annotation
This is code used to filter our maker annotation output file (from round 4) and assign gene names.

---

# BLAST search
- First we will perform a blast search
- This will take our annotation file and search for already published sequences
- This will be used to assign gene names to the genes that match
- We can be confident that these are real genes in our annotation
- Resources:
  - https://open.oregonstate.education/computationalbiology/chapter/command-line-blast/
- Important
  - We will be using `blastn` for nucleotides
  - For annie, the output needs to be in format 6: `-outfmt 6`
  - The location of the nucleotide database on amarel: `/projectsc/ccib/shain/blastdb`
    - We will use the `nt` files (for nucleotide)
- **Output**
  - The output

<details><summary>blast.sh</summary>
<p>
  
  ```
  #!/bin/bash
  #SBATCH --partition=cmain
  #SBATCH --exclude=gpuc001,gpuc002
  #SBATCH --job-name=BLAST
  #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
  #SBATCH --mem=100G
  #SBATCH -n 10
  #SBATCH -N 1
  #SBATCH --time=3-00:00:00
  #SBATCH --requeue
  #SBATCH --mail-user=av795@rutgers.edu
  #SBATCH --mail-type=FAIL


  echo "load modules"
  module purge
  module use /projects/community/modulefiles/
  module load blast/2.10.1-zz109
  
  echo ""
  echo "load variables"
  INDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
  OUTDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast"
  
  echo ""
  echo "commands to run blast"
  blastn -query ${INDIR}/Agra_rnd4.all.maker.transcripts.fasta \
  -db /projectsc/ccib/shain/blastdb/nt \
  -outfmt 6 
  
  
  #-out ${OUTDIR}
  
  echo ""
  echo "done"
  ```

</p>
</details>

```
mv OUTPUT blast/
```

---

# Annie
- [Annie documentation](http://genomeannotation.github.io/annie/)
- [Github page](https://github.com/genomeannotation/Annie)
- We are keeping genes that blasted 
- Uses `python3`
- Input
  - The blast output 6 
  - Transcript fasta file
  - Transcript gff file
- Copy `annie.py` script from [here](https://github.com/genomeannotation/annie/blob/master/annie.py)
- **Output**
  - Product annotation in the form `<mrna_id> product <product>`
    - Use the blast file to get the dbxref for the associated mrna 
    - Then we use the fasta file to take that dbxref and get the corresponding product
    - `mrna_id ---blast_file---> dbxref ---fasta_file---> product`
  - Name annotation in the form `<parent_gene_id> name <parent_gene_name>`
    - Obtaining the `<parent_gene_id>`
      - For each mrna in the blast results, we look it up in the gff file to get the corresponding parent gene id
      - `mrna_id ---gff_file---> parent_gene_id`
    - Obtaining the `<parent_gene_name>`
      - We use the blast file to get the associated dbxref from the mrna 
      - Then we use the fasta file to take that dbxref ref and give us the gene name
      - `mrna_id ---blast_file---> dbxref ---fasta_file---> parent_gene_name`


<details><summary>annie.sh</summary>
<p>
	
	```
	#!/bin/bash
	#SBATCH --partition=p_ccib_1
	#SBATCH --exclude=gpuc001,gpuc002
	#SBATCH --job-name=annie
	#SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
	#SBATCH --mem=100G
	#SBATCH -n 10
	#SBATCH -N 1
	#SBATCH --time=3-00:00:00
	#SBATCH --requeue
	#SBATCH --mail-user=av795@rutgers.edu
	#SBATCH --mail-type=FAIL


	echo "load modules"
	module purge
	module use /projects/community/modulefiles/
	module load python/3.9.6-gc563

	echo ""
	echo "load variables"
	MAKER_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
	BLAST_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast"

	echo ""
	echo "commands to run annie"
	python3 annie.py \
	-b ${BLAST_DIR}/blast.out \
	-g ${MAKER_DIR}/Agra_rnd4.all.maker.gff \
	-db ${MAKER_DIR}/Agra_rnd4.all.maker.transcripts.fasta

	echo ""
	echo "done"
	```

</p>
</details>


```
python3 annie.py \
	-b sample_data/sample.blastout \
        -g sample_data/sample.gff \
        -db sample_data/sample.fasta
```

---

# GAG
- [GAG documentation](http://genomeannotation.github.io/GAG/)
- [Github page](https://github.com/genomeannotation/GAG)
- GAG takes the output from annie and combines it with our annotation 
- Uses `python2`
- Copy `gag.py` script from [here](https://github.com/genomeannotation/GAG/blob/master/gag.py)
- Input
  - Fasta file of nucleotide sequences
  - GFF3 file

<details><summary>gag.sh</summary>
<p>
  
  ```
  #!/bin/bash
  #SBATCH --partition=p_ccib_1
  #SBATCH --exclude=gpuc001,gpuc002
  #SBATCH --job-name=gag
  #SBATCH --output=/projects/f_geneva_1/alyssa/grahami/annotation/filtering/slurmout/slurm-%j-%x.out
  #SBATCH --mem=100G
  #SBATCH -n 10
  #SBATCH -N 1
  #SBATCH --time=3-00:00:00
  #SBATCH --requeue
  #SBATCH --mail-user=av795@rutgers.edu
  #SBATCH --mail-type=FAIL


  echo "load modules"
  module purge
  module use /projects/community/modulefiles/
  module load python/2.7.17-gc563
  
  echo ""
  echo "load variables"
  MAKER_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/maker"
  BLAST_DIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/blast"
  OUTDIR="/projects/f_geneva_1/alyssa/grahami/annotation/filtering/gag"
  
  echo ""
  echo "commands to run annie"
  python gag.py \
  --fasta organism.fasta \
  --gff organism.gff \
  --out ${OUTDIR}
  
  echo ""
  echo "done"
  ```

</p>
</details>


```
python gag.py --fasta organism.fasta --gff organism.gff --out gag_output
```

---

# Manual filtering
- We will also be doing manual filtering on the gene models that didnt match to anything during our blast search
- During BLAST, our gene models will really only be matching with _A. carolinensis_ genes which is pretty divergent from _A. grahami_
- By manually filtering our other gene models on certain criteria we can be pretty confident that these are genes that _A. grahami_ has that _A. carolinensis_ doesn't
- Filtering criteria:
  - AED score of X or lower
  - X or more exons (prob 3?)
- Determining criteria:
  - Make a histogram of AED scores
  - Make a histogram of # of exons

---

# Final BUSCO analysis
- Now we want to run BUSCO again to see our completeness scores after all of our filtering
- The completeness will probably decrease some but we don't want to see it drastically change




<details><summary>name</summary>
<p>

</p>
</details>
