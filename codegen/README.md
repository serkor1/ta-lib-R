# codegen/ — Code Generation System

This directory contains the Rust crate that generates most of the R wrappers,
the C binding header, and the unit tests in the package. If you are reading
this because something broke, start at [Quick reference](#quick-reference)
and work backwards.

## Quick reference

```
make gen-code      # cargo run: regenerate src/TA-Lib.h, R/ta_*.R, tests/ — then make fmt
make build         # document + build + install the package
cargo test         # unit tests of the generator itself (run from codegen/)
```

The crate has **zero dependencies** and is driven entirely by three files
from the TA-Lib submodule:

- `src/ta-lib/ta_func_api.xml` — machine-generated metadata for every
  TA-Lib function (names, groups, inputs, optional inputs, outputs)
- `src/ta-lib/include/ta_func.h` + `src/ta-lib/ta_func_list.txt` — the C
  prototypes, mined for the binding header

## How the pieces fit together

```
ta_func_list.txt + ta_func.h          ta_func_api.xml
      |                                     |
      v                                     v
  c_header.rs                           metadata.rs  parse_api() -> Vec<MetaData>
      |                                     |
      v                                     v
  src/TA-Lib.h                          render.rs  render_indicator()
  (TA_INDICATOR / TA_LOOKBACK               |  template dispatch + placeholder fill
   X-macro lines, expanded by               +--> preserve_regions()   (splice)
   src/wrapper.h and src/init.c)            |
                                            v
                                        R/ta_<ALIAS>.R
                                            |
                                        testthat.rs  render_test()
                                            |
                                            v
                                        tests/testthat/test-ta_<ALIAS>.R
```

The exclusions in `tables.rs` filter both paths: excluded indicators get
neither a C wrapper nor an R wrapper. After generation, `make fmt` runs
`air format` (R) and `clang-format` (C) to normalize style.

## Directory layout

```
codegen/
  src/
    main.rs               Driver: writes src/TA-Lib.h, then runs the
                          R + test generation loop (with splice preservation)
    c_header.rs           Mines TA_<NAME>() / TA_<NAME>_Lookback() prototypes
                          from ta_func.h and renders the X-macro lines
    metadata.rs           XML mining: parse_api() -> Vec<MetaData>
    render.rs             The Templates struct, render_indicator(), the
                          dual-backend chart rendering (render_backend)
                          and preserve_regions() (splice)
    testthat.rs           testthat file generation
    tables.rs             The hand-maintained lookup tables: FUNCTION_NAMES
                          (BBANDS -> bollinger_bands), CHART_TYPES (Main
                          overlay vs Sub panel; absent = not chartable),
                          MOVING_AVERAGES (TA_MAType index, SMA = 0L),
                          AGNOSTIC_PATTERNS (fills ${AGNOSTIC}) and
                          EXCLUDED_INDICATORS / EXCLUDED_GROUPS
  templates/
    indicator_template.R             Standard R wrapper (most indicators)
    numeric_template.R               Appended .numeric method (univariate)
    rolling_template.R               Rolling statistics (Statistic Functions,
                                     .numeric baked in, not plotable)
    moving_average_template.R        Moving averages (spec-mode,
                                     .numeric baked in)
    candlestick_template.R           Candlestick patterns
    chart_main_template.R            Chart methods — main chart overlay
    chart_subchart_template.R        Chart methods — own subchart panel
    chart_moving_average_template.R  Chart methods — moving averages
    chart_candlestick_template.R     Chart methods — candlestick markers
  parity/
    btc_to_csv.R, parity_gen.c, csv_to_rds.R, test_parity_template.R
                          Parity snapshots: R output vs raw TA-Lib C calls
                          (make parity-prepare; runs in make test / check)
```

Each `chart_*_template.R` is **dual-backend**: one file describes both the
`.plotly` and the `.ggplot` method and is rendered once per backend (see
[Dual-backend chart templates](#dual-backend-chart-templates)).

## The metadata source

`metadata::parse_api()` mines `ta_func_api.xml` into one `MetaData` per
`<FinancialFunction>`:

- **Required inputs** become column names: price types map to their OHLCV
  column (`High` -> `high`), plain double arrays (`inReal`) default to
  `close`. The deduplicated columns form `${FORMULA}`
  (`~high + low + close`).
- **Optional inputs** become camelCase formals (`Fast-K Period` ->
  `fastKPeriod`) with their XML defaults; doubles are reformatted from
  scientific notation (`2.000000e-2` -> `0.02`).

The outputs are not mined from the XML: the C side gets them from the
header prototypes (see [How C generation works](#how-c-generation-works))
and the R side does not need them.

The XML is attribute-free and machine-generated, so the crate uses
hand-rolled `tag_blocks()`/`tag_text()` mining instead of an XML library.

## How R wrapper generation works

`render_indicator()` picks the templates per indicator:

| Condition                        | Main template               | Chart template                    |
|----------------------------------|-----------------------------|-----------------------------------|
| Abbreviation starts with `CDL`   | `candlestick_template.R`    | `chart_candlestick_template.R`    |
| Listed in `MOVING_AVERAGES`      | `moving_average_template.R` | `chart_moving_average_template.R` |
| GroupId `Statistic Functions`    | `rolling_template.R`        | — (not plotable)                  |
| Otherwise                        | `indicator_template.R`      | `chart_main_template.R` or `chart_subchart_template.R` for indicators in `CHART_TYPES` |

The standard path additionally appends `numeric_template.R` for univariate
indicators (a single input series); moving averages and rolling statistics
carry their own `.numeric` method inside their main template.

The rendered output ends with **`strip_blank_indentation()`** — dropping
whitespace-only lines left behind by empty multi-entry placeholders (e.g.
the gap between `cols,` and `na.bridge` for argument-less indicators),
which `air` does not reformat away; truly empty separator lines are kept.
`main.rs` then applies **`preserve_regions()`** — splicing hand-edited
content from the existing file on disk back into the fresh render (see
[The splice mechanism](#the-splice-mechanism)).

### Dual-backend chart templates

Every chart method exists in a `.plotly` and a `.ggplot` variant that share
almost all of their body. Each `chart_*_template.R` therefore describes
both variants in one file; `render_backend()` renders it once per backend
(`.plotly` first). Backend divergences are expressed two ways:

- **Backend placeholders**, filled per render:

  | Placeholder | plotly   | ggplot   | Used for                                          |
  |-------------|----------|----------|---------------------------------------------------|
  | `${METHOD}` | `plotly` | `ggplot` | S3 class, `build_*`/`*_init` helpers, `*_object` locals, splice-region names |
  | `${PKG}`    | `plotly` | `ggplot2`| the package name in comments                      |
  | `${SUFFIX}` | `ly`     | `gg`     | helper suffixes (`add_last_value_ly`, `pattern_gg`) |

- **Conditional lines** for structurally different code: a line starting
  with `#plotly#` or `#ggplot#` (column 0) is kept only when rendering
  that backend, with the prefix stripped:

  ```r
  #plotly#	assert_plotly_object(x)
  #ggplot#	assert_ggplot2()
  ```

  A marker-shaped line that survives filtering (a typo'd prefix, an
  unknown backend name) makes the render panic instead of shipping as a
  do-nothing R comment. Note the subchart template's optional-formals
  splice region is itself backend-conditional (the two backends order
  `title` and the region differently), so template lines placed inside
  those markers must carry the backend prefix too.

### Template placeholders

| Placeholder               | Description                                        | Example (BBANDS)                        |
|---------------------------|----------------------------------------------------|-----------------------------------------|
| `${FUN}`                  | snake_case R name (via `FUNCTION_NAMES`)           | `bollinger_bands`                       |
| `${ALIAS}`                | TA-Lib abbreviation (uppercase alias, C symbol)    | `BBANDS`                                |
| `${TITLE}`                | `<ShortDescription>`                               | `Bollinger Bands`                       |
| `${FAMILY}`               | `<GroupId>`                                        | `Overlap Studies`                       |
| `${FORMULA}`              | Default column formula                             | `~close`                                |
| `${ARGS}`                 | Formals, one per line, trailing comma per entry    | `timePeriod = 5,`                       |
| `${PARGS}`                | Named forwarding, trailing comma per entry         | `timePeriod = timePeriod,`              |
| `${C_SIGNATURE}`          | `.Call()` args: series columns + coerced formals   | `constructed_series[[1]],\n as.integer(timePeriod), ...` |
| `${C_NUMERIC}`            | `.Call()` args of the numeric/rolling path         | `as.double(x),\n as.integer(timePeriod), ...` |
| `${C_SIGNATURE_LOOKBACK}` | Lookback `.Call()` args, **leading** comma per entry | `,\n as.integer(timePeriod)`          |
| `${SPEC_FIELDS}`          | MA spec-mode list fields                           | `timePeriod = if (missing(timePeriod)) 5L else as.integer(timePeriod)` |
| `${MA_TYPE}`              | TA_MAType index literal (MAs only)                 | `0L`                                    |
| `${CARGS}`                | Bare formals for `label()`, leading comma per entry | `, timePeriod`                         |
| `${AGNOSTIC}`             | OHLC-order agnosticism (candlesticks only)         | `TRUE` / `FALSE`                        |

The comma conventions matter: `${ARGS}`/`${PARGS}` entries carry their own
**trailing** comma so empty renders leave no dangling comma (the leftover
blank line is removed by `strip_blank_indentation()`), while the lookback
entries carry a **leading** comma because the lookback `.Call()` has no
fixed trailing argument to absorb one.

**MAMA quirk**: moving averages whose C signature has no period get a
spec-only `timePeriod = 30` formal injected — it appears in `${ARGS}`,
`${PARGS}` and `${SPEC_FIELDS}` so every MA spec carries a period for its
downstream consumers, but it is deliberately absent from the `.Call()`
coercions.

## Customizing an indicator

Everything is mined from the XML, so new TA-Lib functions appear
automatically on `make gen-code`. The lookup tables in `tables.rs` tune
the result:

1. **`FUNCTION_NAMES`** — add the `("ABBREV", "snake_case_name")`
   pair. Unmapped abbreviations fall back to the abbreviation itself,
   which renders a degenerate `X <- X` alias line.
2. **`CHART_TYPES`** — add `("ABBREV", ChartType::Main | Sub)` to give the
   indicator `.plotly`/`.ggplot` methods (and chart-method unit tests).
3. **`MOVING_AVERAGES` / `AGNOSTIC_PATTERNS`** — family classification for
   the dedicated templates.
4. **`EXCLUDED_INDICATORS` / `EXCLUDED_GROUPS`** — add the abbreviation
   (or its GroupId) to skip generation entirely, in both C and R.

After `make gen-code`, fill the protected regions of the generated file
(documentation, chart assembly) — the content survives every regeneration.

## How C generation works

There are no per-indicator `.c` files. `c_header.rs` mines each
`TA_<NAME>(...)` prototype (and its `TA_<NAME>_Lookback(...)` companion)
from `ta_func.h` — the output names are stripped of their
`out`/`Real`/`Integer` prefixes (`outRealUpperBand` -> `UpperBand`, a bare
`outReal` takes the indicator name) and an integer output array flags the
indicator as `TA_INTEGER` — and renders one X-macro line per indicator
into `src/TA-Lib.h`:

```c
TA_INDICATOR(BBANDS, TA_DOUBLE, TA_INPUT(inReal), TA_OPTIONS(...), TA_OUTPUT(...), TA_OUTPUT_NAME(...), NOT_CANDLESTICK)
...
TA_LOOKBACK(BBANDS, TA_OPTIONS(...))
```

The hand-written `src/init.c` `#include`s `"TA-Lib.h"` several times with
different `TA_INDICATOR`/`TA_LOOKBACK` macro definitions — composed from
the argument-shape helpers in `src/wrapper.h` — to expand declarations,
`impl_ta_<NAME>` wrapper definitions and the `.Call()` registration table. Candlesticks (`CANDLESTICK` kind) additionally
take a normalization flag that maps the `[-200, 200]` integer output onto
`[-2, 2]`.

## How test generation works

`testthat.rs` writes `tests/testthat/test-ta_<ALIAS>.R` for every
generated indicator (no protected regions — the files are overwritten on
every run). What a file contains follows from the metadata:

- **Rolling statistics** (GroupId `Statistic Functions`): a short
  fast-track file — runs without condition, length preservation, output
  type — on `SPY[,1]`, with `,y=SPY[,2]` appended for the bivariate
  BETA/CORREL.
- **Everything else**: alias equivalence, class preservation
  (matrix/data.frame), default formula, row names, and `na.bridge` length
  checks; plus `.plotly`/`.ggplot` method tests for chartable indicators
  (including candlesticks and moving averages, which are always
  chartable) and a `.numeric` test for univariate indicators.

## The splice mechanism

`preserve_regions()` keeps hand-written code inside generated files. Any
content between matched markers in the file **on disk** replaces the
template's default content in the fresh render:

```r
## splice:documentation:start
#' @param timePeriod [integer] rolling window
## splice:documentation:end
```

It is name-generic: every `## splice:<name>:start` / `## splice:<name>:end`
pair discovered in the rendered output is preserved, so new region names
added to a template work without generator changes. Regions absent from the
existing file (first generation) keep the template default.

Current labels:

- `documentation` — custom roxygen2 documentation (indicator, MA, rolling)
- `call` — the `.Call()` arguments of the rolling `.default` method
  (prefilled with the univariate default; BETA/CORREL hand-add their `y`)
- `optional-plotly` / `optional-ggplot` — extra chart-only formals
  (e.g. `lower_bound = 20,` in RSI)
- `plotly-assembly` / `ggplot-assembly` — the per-indicator `name` /
  `decorators` / `traces` (or `layers`) construction

**Warning**: if a generation run produces a file without a region that
previously existed, the spliced content is lost. There is no recovery
other than git.

## Parity testing

`make parity-prepare` (run by `make test` / `make check`) compiles
`parity/parity_gen.c` against the TA-Lib static library, snapshots raw C
outputs for the BTC dataset, and stages `tests/testthat/test-parity.R` from
`parity/test_parity_template.R`. The testthat run then compares the
package's R output against those snapshots, catching regressions where the
R↔C binding diverges from calling TA-Lib directly.

## Key design decisions

- **Rust, zero dependencies**: the generator is one `cargo run` with no
  crates.io footprint. Templates stay plain R files that editors can
  syntax-highlight; placeholders are filled with simple string replacement
  rather than a templating engine.
- **Hand-rolled XML mining**: `ta_func_api.xml` is machine-generated and
  attribute-free, so `tag_blocks()`/`tag_text()` string scanning is
  sufficient and keeps the crate dependency-free.
- **The XML is the metadata**: there is no hand-maintained indicator list;
  the lookup tables in `tables.rs` (names, chart types, classifications,
  exclusions) are small Rust consts layered on top of what the XML
  provides.
- **One template per chart method, not per backend**: the `.plotly` and
  `.ggplot` variants of a chart method live in one dual-backend template,
  so a change to the shared body is made once instead of twice.
- **X-macros over generated C**: one generated header (`src/TA-Lib.h`)
  expanded by hand-written macros replaces per-indicator `.c` files, so C
  binding logic lives in exactly one place (`src/wrapper.h`).
- **Formatting as a separate step**: generated code is intentionally not
  pretty. `make gen-code` ends with `make fmt` (air + clang-format);
  the only whitespace the generator itself fixes is the blank-indentation
  lines air would leave behind.
- **Generator is unit-tested**: `cargo test` covers the header and XML
  mining, the dual-backend line filtering, every template family render
  (including the full-API sweep asserting no unreplaced `${` placeholders
  and no unstripped backend prefixes), region preservation, and test-file
  rendering.
