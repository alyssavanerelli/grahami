# Commands to count Acar X othologs in grahami scaffolds

```
# search for annotated orthologs in A grahami annotation
grep "\tgene\t" AnoGra1.1_final.gff | grep -i -f AcarX_genes_list.txt > grahami_car_xlinked_genes_new_annotation.gff

# parse output to count the number of genes on each scaffold
grep "scaffold_" grahami_car_xlinked_genes_new_annotation.gff | cut -f 1,9 | cut -d "=" -f 1,3 | sed 's/ID=//g' | cut -f 1-2 -d "_" | grep -w -i -f AcarX_genes_list.txt | sort | uniq -i | cut -f 1 | uniq -c | sort -nr

```


Resulting output is a table of the number of uniq Acar X genes on each scaffold
```
 184 scaffold_12
  30 scaffold_39
   3 scaffold_33
   3 scaffold_3
   3 scaffold_10
   3 scaffold_1
   2 scaffold_5
   2 scaffold_2
   1 scaffold_9756
   1 scaffold_9
   1 scaffold_7754
   1 scaffold_7419
   1 scaffold_6301
   1 scaffold_52
   1 scaffold_4721
   1 scaffold_4293
   1 scaffold_306
   1 scaffold_218
   1 scaffold_188
   1 scaffold_1840
   1 scaffold_175
   1 scaffold_173
   1 scaffold_16
   1 scaffold_14
   1 scaffold_11202
   1 scaffold_11184
   1 scaffold_11084
```
# To Generate Figure run:

```
Rscript plot_GWAS_DPratio_genes.R
```
