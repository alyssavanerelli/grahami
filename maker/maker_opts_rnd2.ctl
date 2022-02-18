(base) [av795@amarel2 ~]$ squeue -u av795
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
          17642043      cmem satsuma-    av795  R    7:26:07      1 memc001
          17634542     cmain maker_au    av795  R   22:30:19      1 halc021
(base) [av795@amarel2 ~]$ cd /projects/f_geneva_1/alyssa/grahami/annotation/
(base) [av795@amarel2 annotation]$ ls -lh
total 8.2M
-rw-rw-r-- 1 ag1839 ag1839     3.0K Dec 15 13:40 AED_cdf_generator.pl
drwxr-xr-x 6 av795  g_geneva_1 4.0K Feb 14 16:44 AnoGra1.1.maker.output
drwxrwxr-x 4 av795  av795      4.0K Feb 17 17:04 AnoGra_annotation_eval1_1
drwxrwxr-x 5 av795  av795      4.0K Feb 17 15:20 AnoGra_rnd1_aug
-rw-rw-r-- 1 av795  g_geneva_1 2.4K Dec 15 13:24 busco_200291.log
-rw-rw-r-- 1 av795  g_geneva_1 5.8K Dec 15 13:32 busco_201655.log
-rw-rw-r-- 1 av795  g_geneva_1 5.8K Dec 15 14:29 busco_209065.log
-rw-rw-r-- 1 av795  g_geneva_1 5.9K Dec 15 14:39 busco_211432.log
-rw-rw-r-- 1 av795  av795      4.0M Feb 17 16:59 busco_77273.log
-rw-rw-r-- 1 av795  g_geneva_1 5.0K Feb 17 16:59 busco_aug_log.txt
-rw-rw-r-- 1 av795  av795      3.7K Feb 17 17:04 busco_aug_rnd1_transc.txt
drwxrwxr-x 3 av795  g_geneva_1 4.0K Dec 15 14:24 busco_downloads
drwxr-xr-x 5 av795  g_geneva_1 4.0K Dec 14 10:51 first_AnoGra1.1.maker.output
drwxrwxr-x 5 av795  g_geneva_1 4.0K Dec 16 22:10 first_AnoGra_rnd1_aug
drwxrwxr-x 2 av795  g_geneva_1 4.0K Dec 16 21:51 first_tmp_opt_BUSCO_AnoGra_rnd1_aug
drwxrwxr-x 3 av795  g_geneva_1 4.0K Dec 16 09:26 LIBDIR
-rw-r--r-- 1 av795  g_geneva_1 1.4K Dec  6 15:19 maker_bopts.ctl
-rw-r--r-- 1 av795  g_geneva_1 1.2K Dec  6 15:19 maker_exe.ctl
-rw-r--r-- 1 av795  g_geneva_1 4.6K Dec 16 09:25 maker_opts.ctl
-rw-r--r-- 1 av795  g_geneva_1 4.8K Dec 14 09:05 maker_opts_rnd1.ctl
drwxrwxr-x 2 av795  g_geneva_1 4.0K Dec  8 12:56 proteomes
-rw-rw-r-- 1 av795  g_geneva_1 1.8K Feb 17 15:18 r1maker_aug.sh
-rw-rw-r-- 1 av795  g_geneva_1 3.3K Feb 14 15:16 r1maker_bsh_n.sh
-rw-rw-r-- 1 av795  g_geneva_1 3.3K Dec 20 12:43 r1maker_bsh.sh
-rw-rw-r-- 1 av795  g_geneva_1 1.6K Dec 14 09:23 r1maker_gff.sh
-rw-rw-r-- 1 av795  g_geneva_1 2.6K Dec 16 09:26 r1maker_sub.sh
-rw-rw-r-- 1 av795  g_geneva_1 2.0K Feb 17 15:22 r1maker_trans_aug.sh
-rw-rw-r-- 1 av795  av795      2.1K Feb 17 17:56 r2maker_sub.sh
-rw-rw-r-- 1 av795  g_geneva_1    0 Dec 20 12:38 renamed_file
-rw-rw-r-- 1 av795  g_geneva_1    8 Dec  7 14:36 res.txt
drwxrwxr-x 2 av795  g_geneva_1 4.0K Feb 17 16:33 slurmout
-rw-rw-r-- 1 av795  g_geneva_1  539 Dec  7 14:36 test.sh
drwxrwxr-x 2 av795  av795      4.0K Feb 17 17:00 tmp_opt_BUSCO_AnoGra_rnd1_aug
(base) [av795@amarel2 annotation]$ less maker_opts.ctl 















#-----Protein Homology Evidence (for best results provide a file for at least one)
protein=/projects/f_geneva_1/alyssa/grahami/annotation/proteomes/SceUnd1.1_protein.faa,/projects/f_geneva_1/alyssa/grahami/annotation/proteomes/AnoSag2.1_proteins.fa  #protein sequence file in fasta format (i.e. from mutiple oransisms)
protein_gff=  #aligned protein homology evidence from an external GFF3 file

#-----Repeat Masking (leave values blank to skip repeat masking)
model_org=Anolis_carolinensis #select a model organism for DFam masking in RepeatMasker
rmlib= #provide an organism specific repeat library in fasta format for RepeatMasker
repeat_protein= #provide a fasta file of transposable element proteins for RepeatRunner
rm_gff= #pre-identified repeat elements from an external GFF3 file
prok_rm=0 #forces MAKER to repeatmask prokaryotes (no reason to change this), 1 = yes, 0 = no
softmask=1 #use soft-masking rather than hard-masking in BLAST (i.e. seg and dust filtering)

#-----Gene Prediction
snaphmm= #SNAP HMM file
gmhmm= #GeneMark HMM file
augustus_species= #Augustus gene prediction species model
fgenesh_par_file= #FGENESH parameter file
pred_gff= #ab-initio predictions from an external GFF3 file
model_gff= #annotated gene models from an external GFF3 file (annotation pass-through)
est2genome=0 #infer gene predictions directly from ESTs, 1 = yes, 0 = no
protein2genome=1 #infer predictions from protein homology, 1 = yes, 0 = no
trna=0 #find tRNAs with tRNAscan, 1 = yes, 0 = no
snoscan_rrna= #rRNA file to have Snoscan find snoRNAs
unmask=0 #also run ab-initio prediction programs on unmasked sequence, 1 = yes, 0 = no

#-----Other Annotation Feature Types (features MAKER doesn't recognize)
other_gff= #extra features to pass-through to final MAKER generated GFF3 file

#-----External Application Behavior Options
alt_peptide=C #amino acid used to replace non-standard amino acids in BLAST databases
cpus=1 #max number of cpus to use in BLAST and RepeatMasker (not for MPI, leave 1 when using MPI)

#-----MAKER Behavior Options
max_dna_len=100000 #length for dividing up contigs into chunks (increases/decreases memory usage)
min_contig=1000 #skip genome contigs below this length (under 10kb are often useless)

pred_flank=200 #flank for extending evidence clusters sent to gene predictors
pred_stats=0 #report AED and QI statistics for all predictions as well as models
AED_threshold=1 #Maximum Annotation Edit Distance allowed (bound by 0 and 1)
min_protein=0 #require at least this many amino acids in predicted proteins
alt_splice=0 #Take extra steps to try and find alternative splicing, 1 = yes, 0 = no
always_complete=0 #extra steps to force start and stop codons, 1 = yes, 0 = no
map_forward=0 #map names and attributes forward from old GFF3 genes, 1 = yes, 0 = no
keep_preds=0 #Concordance threshold to add unsupported gene prediction (bound by 0 and 1)

split_hit=10000 #length for the splitting of hits (expected max intron size for evidence alignments)
single_exon=0 #consider single exon EST evidence when generating annotations, 1 = yes, 0 = no
single_length=250 #min length required for single exon ESTs if 'single_exon is enabled'
correct_est_fusion=0 #limits use of ESTs in annotation to avoid fusion genes

tries=5 #number of times to try a contig if there is a failure for some reason
clean_try=0 #remove all data from previous run before retrying, 1 = yes, 0 = no
clean_up=0 #removes theVoid directory with individual analysis files, 1 = yes, 0 = no
TMP= #specify a directory other than the system default temporary directory for temporary files
