
# Benchmarks

The benchmarks are run on the `bollinger_bands()` function, with three
different specifications:

1.  *baseline:* This specification calls the C routine directly, without
    any calls to R functions.
2.  *data.frame:* This specification is the S3 `<data.frame>` dispatch.
3.  *matrix:* This specification is the S3 `<matrix>` dispatch.

All benchmarks uses a 200000 row OHLC `<data.frame>`

## Benchmark results

    #> # A data frame: 3 × 6
    #>   expression      min   median `itr/sec` mem_alloc `gc/sec`
    #>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
    #> 1 baseline   846.75µs   1.47ms      682.    4.58MB     97.4
    #> 2 data.frame   1.19ms   1.27ms      688.    9.17MB    442. 
    #> 3 matrix       1.69ms   1.82ms      484.   13.74MB    730.
