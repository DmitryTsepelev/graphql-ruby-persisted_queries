# Compiled queries benchmarks

The name of benchmark consists of a field count and optional "nested" label. In case of non–nested one we just generate a query with that field count, e.g. `2 fields` means:

```gql
query {
  field1
  field2
}
```

In case of "nested" benchmark we also put a list of fields to each top–level field, e.g. `2 fields (nested)` means:

```gql
query {
  field1 {
    field1
    field2
  }
  field2 {
    field1
    field2
  }
}
```

Field resolver just returns a string, so real–world tests might be way slower because of IO.

Here are the results:

```
Plain schema:

                                   user     system      total        real
10 fields                      0.001061   0.000039   0.001100 (  0.001114)
50 fields                      0.001658   0.000003   0.001661 (  0.001661)
100 fields                     0.004587   0.000026   0.004613 (  0.004614)
200 fields                     0.006447   0.000016   0.006463 (  0.006476)
300 fields                     0.024493   0.000073   0.024566 (  0.024614)
10 fields (nested)             0.003061   0.000043   0.003104 (  0.003109)
50 fields (nested)             0.056927   0.000995   0.057922 (  0.057997)
100 fields (nested)            0.245235   0.001336   0.246571 (  0.246727)
200 fields (nested)            0.974444   0.006531   0.980975 (  0.981810)
300 fields (nested)            2.175855   0.012773   2.188628 (  2.190130)

Schema with persisted queries:

                                   user     system      total        real
10 fields                      0.000606   0.000007   0.000613 (  0.000607)
50 fields                      0.001855   0.000070   0.001925 (  0.001915)
100 fields                     0.003239   0.000009   0.003248 (  0.003239)
200 fields                     0.007542   0.000009   0.007551 (  0.007551)
300 fields                     0.014975   0.000237   0.015212 (  0.015318)
10 fields (nested)             0.002992   0.000068   0.003060 (  0.003049)
50 fields (nested)             0.062314   0.000274   0.062588 (  0.062662)
100 fields (nested)            0.256404   0.000865   0.257269 (  0.257419)
200 fields (nested)            0.978408   0.007437   0.985845 (  0.986579)
300 fields (nested)            2.263338   0.010994   2.274332 (  2.275967)

Schema with compiled queries:

                                   user     system      total        real
10 fields                      0.000526   0.000009   0.000535 (  0.000530)
50 fields                      0.001280   0.000012   0.001292 (  0.001280)
100 fields                     0.002292   0.000004   0.002296 (  0.002286)
200 fields                     0.005462   0.000001   0.005463 (  0.005463)
300 fields                     0.014229   0.000121   0.014350 (  0.014348)
10 fields (nested)             0.002027   0.000069   0.002096 (  0.002104)
50 fields (nested)             0.029933   0.000087   0.030020 (  0.030040)
100 fields (nested)            0.133933   0.000502   0.134435 (  0.134756)
200 fields (nested)            0.495052   0.003545   0.498597 (  0.499452)
300 fields (nested)            1.041463   0.005130   1.046593 (  1.047137)
```

Results gathered from my MacBook Pro Mid 2014 (2,5 GHz Quad-Core Intel Core i7, 16 GB 1600 MHz DDR3).
