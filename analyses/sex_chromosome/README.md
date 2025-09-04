# Commands to count Acar X othologs in grahami scaffolds

```





grep "scaffold_" grahami_car_xlinked_genes_new_annotation.gff | cut -f 1,9 | cut -d "=" -f 1,3 | sed 's/ID=//g' | cut -d "_" -f 1-2 | sort -n | uniq | cut -f 1 | sort | uniq -c

```



