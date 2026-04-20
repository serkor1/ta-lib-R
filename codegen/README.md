# codegen/ — Code Generation System

This directory contains the meta-programming infrastructure that generates
most of the R wrappers, C wrappers, and unit tests in the package. If you are
reading this because something broke, start at [Quick reference](#quick-reference)
and work backwards.

## Quick reference

```
make gen-code      # regenerate R/, src/ta_*.c, and tests/ from metadata
make build         # also runs generate_API.sh + generate_FFI.sh
make fmt           # format everything (air for R, clang-format for C)
```

## How the pieces fit together

```
indicators.R            All 128 indicator definitions (one list)
      |
      v
generate.R              Loops over indicators, calls:
      |
      +---> utils.R  impl_generate_indicator()
      |        |
      |        +---> generate_indicator.sh   (envsubst on R templates)
      |
      +---> utils.R  impl_generate_test()
      |        |
      |        +---> generate_unit-tests.sh  (heredoc test files)
      |
      +---> generate_indicator_core.sh       (parses ta_func.h, envsubst on C template)
      +---> generate_core_candlestick.sh     (candlestick-specific C generation)
```

After generation, `make fmt` runs `air format` (R) and `clang-format` (C) to
normalize style.

## Directory layout

```
codegen/
  gen_code/
    indicators.R        <- THE metadata: every indicator in one place
    generate.R          <- driver script (make gen-code calls this)
    utils.R             <- impl_generate_indicator(), impl_generate_test()
  templates/
    indicator_template.R.in         Standard R wrapper (most indicators)
    indicator_template.c.in         Standard C wrapper (most indicators)
    candlestick_template.R.in       Candlestick pattern R wrapper
    candlestick_template.c.in       Candlestick pattern C wrapper
    moving_average_template.R.in    Moving average R wrapper (includes numeric + plotly)
    rolling_template.R.in           Rolling statistic R wrapper (simplified)
    numeric_template.R.in           Appended for univariate .numeric method
    plotly_main_template.R.in       Plotly method — main chart overlay
    plotly_subchart_template.R.in   Plotly method — subchart panel
    ggplot_main_template.R.in       ggplot2 method — main chart overlay
    ggplot_subchart_template.R.in   ggplot2 method — subchart panel
    candlestick_ggplot_template.R.in  ggplot2 method for candlesticks
    moving_average_ggplot_template.R.in  ggplot2 method for moving averages
  generate_indicator.sh         R template assembler (envsubst + splice)
  generate_indicator_core.sh    C code generator (parses ta_func.h headers)
  generate_core_candlestick.sh  C code generator for candlestick patterns
  generate_unit-tests.sh        Test file generator
  generate_API.sh               Extracts SEXP prototypes → src/api.h
  generate_FFI.sh               Builds R_CallMethodDef table → src/init.c
  validation/
    validate.R                  Smoke-tests: compares R output vs raw TA-Lib C calls
    validate.c                  Reference C implementations for validation
```

## Adding a new indicator

1. **Add one line to `gen_code/indicators.R`** using the appropriate
   constructor. Pick the constructor that matches the indicator family:

   | Constructor     | Family               | Notes                           |
   |-----------------|----------------------|---------------------------------|
   | `momentum()`    | Momentum Indicator   | Most common                     |
   | `candlestick()` | Pattern Recognition  | OHLC patterns, boolean output   |
   | `moving_avg()`  | Overlap Study        | Each MA gets its own `src/ta_<ALIAS>.c` |
   | `overlap()`     | Overlap Study        | Non-MA overlays (BBANDS, SAR)   |
   | `cycle()`       | Cycle Indicator      | Hilbert transforms              |
   | `price_xform()` | Price Transform      | No charting, no subchart        |
   | `volume()`      | Volume Indicator     |                                 |
   | `volatility()`  | Volatility Indicator |                                 |
   | `rolling()`     | Rolling Statistic    | Simplified template, no NA handling |

   Example — adding a new momentum indicator:

   ```r
   momentum("Awesome Oscillator", "awesome_oscillator", "AO",
            "~high + low", c("fast=5", "slow=34"))
   ```

2. **Run `make gen-code`**. This generates:
   - `R/ta_AO.R` — R wrapper with S3 methods
   - `src/ta_AO.c` — C wrapper calling TA-Lib
   - `tests/testthat/test-ta_AO.R` — unit tests

3. **Check the splice regions** in the generated R file. If the indicator
   needs custom `.Call()` arguments (e.g. constructed series columns), edit the
   content between `## splice:call:start` and `## splice:call:end`. This
   content is preserved across regenerations.

4. **Run `make build`** to rebuild (also regenerates `api.h` and `init.c`).

## How R wrapper generation works

`generate_indicator.sh` is the core R assembler. It:

1. **Receives metadata** as environment variables (`FUN`, `TA_FUN`, `FORMULA`,
   `ARGS`, `PLOTLY`, `SUBCHART`, `CANDLESTICK`, `maType`, `ROLLING`, etc.)
   and function arguments as positional parameters.

2. **Selects the main template** based on flags:
   - `CANDLESTICK=1` → `candlestick_template.R.in`
   - `maType != -1` → `moving_average_template.R.in`
   - `ROLLING != 0` → `rolling_template.R.in`
   - Otherwise → `indicator_template.R.in`

3. **Runs `envsubst`** to replace `${VAR}` placeholders in the template.

4. **Appends optional templates** (if the indicator supports them):
   - `numeric_template.R.in` — when `NUMERIC=1` (univariate formula)
   - `plotly_*_template.R.in` — when `PLOTLY=1`
   - `ggplot_*_template.R.in` — for charting support

5. **Splices preserved content** from the existing output file. Any code
   between `## splice:LABEL:start` and `## splice:LABEL:end` markers in the
   current file on disk is re-inserted into the freshly generated version.
   This is how hand-written `.Call()` arguments and documentation survive
   regeneration.

### Template variables

The shell script constructs several argument-related variables from the
positional parameters (the `signature` field in the metadata):

| Variable          | Description                                   | Example (`n=10,vfactor=0.7`)             |
|-------------------|-----------------------------------------------|------------------------------------------|
| `${ARGS}`         | Signature args with trailing comma            | `n=10,vfactor=0.7,`                      |
| `${PARGS}`        | Named forwarding: `key=key,`                  | `,n=n ,vfactor=vfactor ,`                |
| `${CARGS}`        | Bare names for `.Call()`: `,key`              | `,n ,vfactor`                            |
| `${CARGS_TYPED}`  | Type-coerced names (`as.integer`/`as.double`) | `,as.integer(n) ,as.double(vfactor)`     |
| `${PPARGS}`       | Named forwarding, no trailing comma (plotly)  | `,n=n ,vfactor=vfactor`                  |
| `${SPEC_FIELDS}`  | MA spec-mode list fields, one per signature arg | `n = if (missing(n)) 10L else as.integer(n),\n\t\t\t\tvfactor = if (missing(vfactor)) 0.7 else as.double(vfactor)` |

## How C wrapper generation works

### Standard indicators — `generate_indicator_core.sh`

This 420-line bash script:

1. **Locates `ta_func.h`** in the TA-Lib submodule headers.
2. **Extracts the `TA_<NAME>(...)` prototype** using awk (skipping `TA_<NAME>_*` variants).
3. **Classifies each parameter** via regex:
   - Input arrays (`const double inArray[]`) → `REAL()` extraction
   - Input scalars (`int`, `double`, `TA_MAType`) → `INTEGER()[0]` / `REAL()[0]`
   - Output arrays (`double outArray[]`) → allocated in output container
   - Skip: `startIdx`, `endIdx`, `outBegIdx`, `outNBElement` (TA-Lib internals)
4. **Extracts the lookback function** `TA_<NAME>_Lookback(...)` parameters.
5. **Exports 16+ environment variables** and runs `envsubst` on
   `indicator_template.c.in`.
6. **Writes to stdout** — the caller redirects to `src/ta_<NAME>.c`.

### Candlestick patterns — `generate_core_candlestick.sh`

Simpler variant that:
1. Checks if the pattern has an `optInPenetration` parameter.
2. Uses `sed` to convert `{{VAR}}` → `${VAR}` in the candlestick C template.
3. Runs `envsubst` and writes directly to `src/ta_<NAME>.c`.

### Moving averages

Each MA type (SMA, EMA, WMA, DEMA, TEMA, TRIMA, KAMA, MAMA, T3) uses the
standard `generate_indicator_core.sh` path and gets its own per-function
`src/ta_<ALIAS>.c` calling the TA-Lib entry point directly (e.g. `TA_SMA`,
`TA_MAMA`). The `moving_avg()` helper wires per-MA signatures and routes R
wrappers through `moving_average_template.R.in`, which retains the spec-mode
`missing(x)` branch so `SMA(n = 5)` still returns `list(n, maType)` for
downstream consumers (BBANDS, APO, PPO, MACDEXT, STOCH*).

## How test generation works

`generate_unit-tests.sh` writes test files using bash heredocs. Two paths:

- **Rolling statistics** (`ROLLING=1`): 3 quick tests — runs without error,
  length preservation, output type.
- **Everything else**: 10+ tests covering alias equivalence, class
  preservation (matrix/data.frame), default formula, row names, NA handling,
  and optionally plotly/ggplot/numeric methods.

The `NUMERIC` environment variable controls whether a numeric-method test
block is appended. It is derived from the formula: if the formula references
exactly one column (e.g. `~close`), `NUMERIC=1`.

## How API registration works (build-time)

These run during `make build`, not `make gen-code`:

1. **`generate_API.sh`** scans all `src/*.c` files for `SEXP` function
   definitions, extracts their signatures, and writes `src/api.h`
   (a header with all C function prototypes).

2. **`generate_FFI.sh`** reads `api.h`, counts each function's arguments,
   and writes `src/init.c` with `R_CallMethodDef` entries so R's `.Call()`
   interface can find them.

## The splice mechanism

The splice mechanism in `generate_indicator.sh` lets you keep hand-written
code inside generated files. Any content between matched markers is preserved
across regenerations:

```r
## splice:call:start
constructed_series[, 1],
constructed_series[, 2],
## splice:call:end
```

The awk script (lines 158-207 of `generate_indicator.sh`) does a two-pass
process:
- **Pass 1**: Read the existing output file and harvest the body of each
  labeled splice region.
- **Pass 2**: Write the newly generated template, but when a splice region
  is encountered, substitute the harvested content from pass 1 instead of
  the template's default content.

Current splice labels used:
- `documentation` — custom roxygen2 `@param` documentation
- `call` — arguments passed to `.Call()` in the `.default` method
- `numeric` — arguments passed to `.Call()` in the `.numeric` method

**Warning**: If a generation run produces a file without a splice region that
previously existed (e.g. due to a bug removing the numeric method), the
splice content is lost permanently. There is no recovery other than git.

## Validation

`make validate` compiles `validation/validate.c` against the TA-Lib static
library and runs `validation/validate.R`, which compares the package's R
output against direct C calls for a few key indicators (SMA, RSI, BBANDS, ATR).
This catches regressions where the R↔C binding produces different results
than calling TA-Lib directly.

## Key design decisions

- **`envsubst` over R templating**: The templates use `${VAR}` substitution
  via the system `envsubst` command rather than R-based templating (whisker,
  glue, etc.). This keeps templates as plain R/C files that editors can
  syntax-highlight, and avoids escaping issues with R string literals.

- **Bash for C header parsing**: `generate_indicator_core.sh` parses
  `ta_func.h` in bash rather than R. This was a pragmatic choice — the regex
  classification of C parameter types is direct in bash. The tradeoff is that
  the script is hard to modify (420 lines of careful bash regex).

- **Formatting as a separate step**: Generated code is intentionally not
  pretty. `make fmt` (air + clang-format) handles all formatting as a
  post-processing step, so templates don't need to worry about indentation.

- **Moving averages share one C file**: TA-Lib's `TA_MA()` accepts a
  `TA_MAType` enum, so all 9 MA variants call the same C function. The R
  wrappers differ (each sets a different `maType` default) but the C wrapper
  is shared.
