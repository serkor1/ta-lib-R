# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working
with code in this repository.

## What This Is

R package (`talib`) providing an interface to the TA-Lib C library for
technical analysis indicators and candlestick pattern recognition.
TA-Lib is vendored as a git submodule in `src/ta-lib/`.

## Build Commands

``` bash
make build          # Full build: gen-code → document → install
make check          # R CMD check --as-cran
make check-full     # R CMD check with valgrind
make test           # Run testthat suite
make fmt            # Format code (air for R, clang-format for C)
make document       # Regenerate roxygen2 documentation
make gen-code       # Regenerate R wrappers, C wrappers, and tests from templates
make bench          # Run performance benchmarks
```

Single test file:
`Rscript -e "testthat::test_file('tests/testthat/test-ta_APO.R')"`

## Architecture

### Code Generation (Most Source Files Are Generated)

Most R wrappers (`R/ta_*.R`), C wrappers (`src/ta_*.c`), and tests
(`tests/testthat/test-ta_*.R`) are **auto-generated**. Do not edit these
directly — modify the generation infrastructure in `codegen/` instead:

- `codegen/gen_code/indicators.R` — Unified metadata for all 128
  indicators
- `codegen/gen_code/generate.R` — Single driver script that generates R,
  C, and test files
- `codegen/gen_code/utils.R` — `impl_generate_indicator()` and
  `impl_generate_test()` helpers
- `codegen/generate_indicator.sh`, `generate_API.sh`, `generate_FFI.sh`
  — Shell scripts for template-driven generation
- `src/api.h` and `src/init.c` — Auto-generated (function prototypes and
  R registration)

Run `make gen-code` after changing any generation logic.

### R ↔︎ C Binding

Uses [`.Call()`](https://rdrr.io/r/base/CallExternal.html) (R’s native C
interface), not Rcpp. Each indicator has:

1.  **C wrapper** (`src/ta_*.c`): Converts R SEXP → C arrays, calls
    TA-Lib, returns SEXP matrix
2.  **R wrapper** (`R/ta_*.R`): S3 generic with methods for `default`,
    `data.frame`, and `plotly`

C memory management uses manual `PROTECT`/`UNPROTECT` with protection
counters.

### S3 Dispatch Pattern

Every indicator follows this pattern:

``` r

indicator <- function(x, cols, ...) UseMethod("indicator")
indicator.default    # Handles matrix/data input, calls .Call()
indicator.data.frame # Extracts columns via series(), delegates, re-wraps via map_dfr()
indicator.matrix     # Forwards to .default without NextMethod()
indicator.numeric    # Univariate fast path (single-column formulas only)
indicator.plotly     # Adds indicator as plotly trace
indicator.ggplot     # Adds indicator as ggplot2 layer
```

Column selection uses formula syntax: `cols = ~close`,
`cols = ~high + low`.

### Chart Backends

Two rendering backends are selected via
`options(talib.chart.backend = ...)`:

- `"plotly"` (default) — interactive HTML via
  [plotly](https://plotly-r.com) (Suggests)
- `"ggplot2"` — static output via
  [ggplot2](https://ggplot2.tidyverse.org) (Suggests)

[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md) +
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)
share per-pipeline state stashed in the caller’s evaluation frame (key
`.talib_chart_state`); `.chart_state()` in `R/zzz.R` walks the call
stack via [`sys.frame()`](https://rdrr.io/r/base/sys.parent.html) /
[`sys.nframe()`](https://rdrr.io/r/base/sys.parent.html) to retrieve it.
This keeps parallel pipelines (Shiny, futures, nested function bodies)
isolated without depending on those packages.
[`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md) and
its
[`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)
calls must live in the **same enclosing frame**.

### Key Non-Generated Files

- `R/chart.R` —
  [`chart()`](https://serkor1.github.io/ta-lib-R/reference/chart.md)
  entry point and plotly candlestick backend
- `R/chart_ggplot.R` — ggplot2 candlestick backend, theme, axis scales
- `R/chart_indicator.R` —
  [`indicator()`](https://serkor1.github.io/ta-lib-R/reference/indicator.md)
  single/multi dispatch, panel assembly, print methods
- `R/chart_build.R` — shared `build_plotly()` / `build_ggplot()` used by
  generated wrappers
- `R/chart_elements.R`, `R/chart_layout.R`, `R/chart_pattern.R` —
  annotations, plotly layout decorators, candlestick pattern markers
- `R/chart_theme.R` — theme registry and
  [`set_theme()`](https://serkor1.github.io/ta-lib-R/reference/set_theme.md)
- `R/zzz.R` — `.onLoad`/`.onAttach` hooks, per-pipeline state helpers,
  package-level `.chart_variables` theme env
- `R/series.R` — Formula-based column selection logic (`series()` S3
  generic)
- `R/utils.R` — Input validation (`assert_column_names()`,
  `assert_formula()`, …), `candlestick_setting()`, `set_rownames()` /
  `map_dfr()` S3 generics
- `R/helper.R` — Operators (`%nn%`, `%or%`), chart helpers
  (`plotly_init`, `plotly_line`, `ggplot_init`, `ggplot_line`,
  `modify_traces`, `add_idx`, `rebuild_formula`)
- `R/BTC.R`, `R/NVDA.R`, `R/SPY.R`, `R/ATOM.R` — Built-in OHLCV datasets
  (docs only; `.rda` files in `data/`)
- `R/talib-package.R` — `generate_returns_section()` used at
  roxygen-render time by `man-roxygen/returns.R`
- `src/dataframe.c` — Matrix↔︎data.frame conversion (`map_dfr`)
- `src/container.h`, `src/shift.h`, `src/names.h` — Shared C utilities

### TA-Lib Submodule

`src/ta-lib/` is a git submodule compiled via CMake into a static
library (`libta-lib.a`). The `configure` script handles
detection/compilation. `SystemRequirements: CMake`.

## Conventions

- **Naming**: TA-Lib `TA_BBANDS()` → R
  [`bollinger_bands()`](https://serkor1.github.io/ta-lib-R/reference/bollinger_bands.md)
  (snake_case), with uppercase alias `BBANDS`
- **Data**: Expects OHLCV columns named `open`, `high`, `low`, `close`,
  `volume` (case-sensitive)
- **Style**: Tidyverse style guide; R formatted with `air`, C with
  `clang-format`
- **Docs**: Roxygen2 with Markdown syntax; never edit `man/*.Rd`
  directly
- **Tests**: testthat edition 3; auto-generated tests cover alias
  equivalence, type preservation, dimension integrity, and value
  correctness
