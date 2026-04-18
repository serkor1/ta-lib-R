## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.

## Spelling

The words flagged by the spell-checker (ADX, Bollinger, MACD, OHLCV) are
established technical-analysis terms and standard acronyms in the
quantitative finance domain. Each acronym is fully expanded on first use
in the Description (e.g. "Moving Average Convergence Divergence (MACD)");
'Bollinger' is the surname in the proper-noun "Bollinger Bands".

## Vendored library

This package vendors the TA-Lib C library (BSD 3-Clause, source under
`src/ta-lib/`) to avoid an external system dependency. The upstream
copyright is reproduced verbatim in `inst/COPYRIGHTS` and the original
copyright holder is credited in `Authors@R` as `cph`. The static library
artifact built from `src/ta-lib/` produces a NOTE about an apparent object
file under `src/ta-lib/local/lib/libta-lib.a`; this is a build-time artifact
required for linking and is regenerated from source on every install.
