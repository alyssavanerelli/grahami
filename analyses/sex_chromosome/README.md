# Commands to count Acar X othologs in grahami scaffolds

```
# search for annotated orthologs in A grahami annotation
grep "\tgene\t" AnoGra1.1_final.gff | grep -i -f AcarX_genes_list.txt > grahami_car_xlinked_genes_new_annotation.gff

# parse output to count the number of genes on each scaffold
grep "scaffold_" grahami_car_xlinked_genes_new_annotation.gff | cut -f 1,9 | cut -d "=" -f 1,3 | sed 's/ID=//g' | cut -d "_" -f 1-2 | sort -n | uniq | cut -f 1 | sort | uniq -c

```


Resulting output is a table of the number of uniq Acar X genes on each scaffold
```
  22 scaffold_1
  12 scaffold_10
   1 scaffold_10185
   1 scaffold_1030
   1 scaffold_1055
   1 scaffold_107
   5 scaffold_11
   2 scaffold_11084
   1 scaffold_11184
   1 scaffold_11202
   1 scaffold_11630
 195 scaffold_12
   1 scaffold_121
   1 scaffold_13360
   1 scaffold_13471
   1 scaffold_136
   3 scaffold_14
   1 scaffold_14175
   1 scaffold_14913
   1 scaffold_1521
   1 scaffold_1529
   1 scaffold_15488
   1 scaffold_15652
   1 scaffold_16
   1 scaffold_160
   2 scaffold_165
   1 scaffold_1681
   2 scaffold_173
   1 scaffold_175
   1 scaffold_1792
   2 scaffold_18
   1 scaffold_183
   1 scaffold_1840
   2 scaffold_188
   1 scaffold_189
   1 scaffold_199
  15 scaffold_2
   2 scaffold_218
   2 scaffold_223
   1 scaffold_2256
   1 scaffold_228
   1 scaffold_232
   3 scaffold_24
   1 scaffold_2505
   1 scaffold_2521
   1 scaffold_2591
   1 scaffold_266
   1 scaffold_2667
   1 scaffold_272
   1 scaffold_2782
   1 scaffold_28
   2 scaffold_291
   1 scaffold_2912
   1 scaffold_296
   1 scaffold_297
   1 scaffold_298
  11 scaffold_3
   3 scaffold_302
   1 scaffold_306
   1 scaffold_3086
   5 scaffold_32
   1 scaffold_3214
   1 scaffold_3294
   4 scaffold_33
   1 scaffold_34
   1 scaffold_351
   1 scaffold_357
   1 scaffold_3671
  32 scaffold_39
   1 scaffold_392
   8 scaffold_4
   1 scaffold_40
   1 scaffold_4293
   1 scaffold_4721
   7 scaffold_5
   1 scaffold_50
   1 scaffold_52
   1 scaffold_5666
   8 scaffold_6
   1 scaffold_6009
   1 scaffold_601
   1 scaffold_62
   1 scaffold_620
   1 scaffold_6301
   1 scaffold_631
   1 scaffold_6634
   4 scaffold_67
   1 scaffold_68
   4 scaffold_7
   1 scaffold_73
   1 scaffold_7419
   1 scaffold_7754
   1 scaffold_7840
   4 scaffold_8
   1 scaffold_83
   1 scaffold_8454
   1 scaffold_8591
   1 scaffold_89
   4 scaffold_9
   1 scaffold_903
   1 scaffold_9129
   1 scaffold_9250
   1 scaffold_9347
   1 scaffold_9756
   1 scaffold_9815
```
