//! R wrapper rendering
//!
//! Templates are plain R files with ${...} placeholders filled by
//! simple string replacement (see the README for the placeholder
//! table). The chart-method templates are *dual-backend*: one file
//! describes both the .plotly and the .ggplot method, and
//! render_backend() renders it once per backend by
//!
//!   - keeping '#plotly#'/'#ggplot#'-prefixed lines only for their
//!     backend (prefix stripped), and
//!   - filling ${METHOD} (plotly|ggplot), ${PKG} (plotly|ggplot2)
//!     and ${SUFFIX} (ly|gg)
//!
//! The camelCase alias block is marker-conditional the same way:
//! render_camel() keeps '#camel#'-prefixed lines (prefix stripped)
//! only when the camelCase name differs from the snake_case name.
//!
//! After rendering, hand-edited splice regions of the existing file
//! on disk are preserved by preserve_regions() (see main.rs).

use crate::metadata::{MetaData, OptionalArg, OptionalType};
use crate::tables::{
    ChartType, MOVING_AVERAGES, agnostic, camel_case_name, chart_type, function_name,
    is_candlestick, ma_type,
};

/// The template files rendered by render_indicator(),
/// loaded once from 'codegen/templates/'
pub struct Templates {
    pub indicator: String,
    pub numeric: String,
    pub rolling: String,
    pub moving_average: String,
    pub candlestick: String,
    pub chart_main: String,
    pub chart_subchart: String,
    pub chart_moving_average: String,
    pub chart_candlestick: String,
}

impl Templates {
    pub fn load(dir: &str) -> Templates {
        let read = |name: &str| {
            std::fs::read_to_string(format!("{dir}/{name}"))
                .unwrap_or_else(|e| panic!("read {dir}/{name}: {e}"))
        };

        Templates {
            indicator: read("indicator_template.R"),
            numeric: read("numeric_template.R"),
            rolling: read("rolling_template.R"),
            moving_average: read("moving_average_template.R"),
            candlestick: read("candlestick_template.R"),
            chart_main: read("chart_main_template.R"),
            chart_subchart: read("chart_subchart_template.R"),
            chart_moving_average: read("chart_moving_average_template.R"),
            chart_candlestick: read("chart_candlestick_template.R"),
        }
    }
}

/// One chart backend of a dual-backend template
struct Backend {
    /// ${METHOD}: the S3 class, and by convention also the builder
    /// (build_plotly), the init helper (plotly_init), the local
    /// object (plotly_object) and the splice-region names
    /// (optional-plotly, plotly-assembly)
    method: &'static str,
    /// ${PKG}: the package name in comments ({ggplot2}-object)
    pkg: &'static str,
    /// ${SUFFIX}: the chart-helper suffix (add_last_value_ly,
    /// pattern_gg)
    suffix: &'static str,
}

const PLOTLY: Backend = Backend {
    method: "plotly",
    pkg: "plotly",
    suffix: "ly",
};

const GGPLOT: Backend = Backend {
    method: "ggplot",
    pkg: "ggplot2",
    suffix: "gg",
};

/// Render a dual-backend chart template for one backend: keep
/// '#plotly#'/'#ggplot#'-prefixed lines only for their backend
/// (prefix stripped), then fill the backend placeholders
fn render_backend(template: &str, backend: &Backend) -> String {
    let own = format!("#{}#", backend.method);

    let mut out = template
        .lines()
        .filter_map(|line| {
            if let Some(rest) = line.strip_prefix(&own) {
                Some(rest)
            } else if line.starts_with("#plotly#") || line.starts_with("#ggplot#") {
                None
            } else {
                Some(line)
            }
        })
        .collect::<Vec<&str>>()
        .join("\n");

    if template.ends_with('\n') {
        out.push('\n');
    }

    // a marker-shaped line ('#word#...') surviving the filter is a
    // typo'd or unknown backend prefix; left alone it would ship as
    // a plain R comment, silently disabling the line in both
    // backends
    for line in out.lines() {
        if let Some(rest) = line.trim_start().strip_prefix('#') {
            if let Some(end) = rest.find('#') {
                if end > 0 && rest[..end].chars().all(|c| c.is_ascii_alphanumeric()) {
                    panic!("unknown backend prefix in template line: {line}");
                }
            }
        }
    }

    out.replace("${METHOD}", backend.method)
        .replace("${PKG}", backend.pkg)
        .replace("${SUFFIX}", backend.suffix)
}

/// Keep '#camel#'-prefixed lines (prefix stripped) only when the
/// indicator has a distinct camelCase alias; for single-word names
/// (doji, aroon) the block would alias the function to itself
pub fn render_camel(template: &str, keep: bool) -> String {
    let mut out = template
        .lines()
        .filter_map(|line| match line.strip_prefix("#camel#") {
            Some(rest) => keep.then_some(rest),
            None => Some(line),
        })
        .collect::<Vec<&str>>()
        .join("\n");

    if template.ends_with('\n') {
        out.push('\n');
    }

    out
}

/// Render the R wrapper of an indicator from its family's main
/// template plus the conditional methods:
///
///   - candlestick patterns (CDL*): 'candlestick_template.R' with
///     the chart methods from 'chart_candlestick_template.R'
///   - moving averages (see MOVING_AVERAGES): the spec-mode
///     'moving_average_template.R' (.numeric baked in) with the
///     chart methods from 'chart_moving_average_template.R'.
///     MAs order their formals (x, extra series, options, cols,
///     na.bridge, ...) — extra input series beyond the first
///     (VWMA: volume) are formals of every method, falling back
///     to their formula column when not explicitly passed
///   - rolling statistics (GroupId 'Statistic Functions'):
///     'rolling_template.R', not plotable, .numeric baked in
///   - everything else: 'indicator_template.R'; univariate
///     indicators (a single input series) get the appended
///     .numeric method, chartable indicators (see CHART_TYPES)
///     the methods from 'chart_main_template.R' or
///     'chart_subchart_template.R'
///
/// Multi-entry placeholders (ARGS, PARGS) carry their own trailing
/// comma per entry so that indicators without optional inputs
/// render an empty line instead of a dangling comma
pub fn render_indicator(f: &MetaData, t: &Templates) -> String {
    // the R function name, e.g. BBANDS -> bollinger_bands
    let fun = function_name(&f.indicator);

    // the TA_MAType index literal, Some for the nine
    // moving averages rendered in spec-mode
    let ma_index = ma_type(&f.indicator);

    // default column formula, e.g. ~high + low + close
    let formula = f.default_formula();

    // the generic's formal arguments: the XML optional inputs,
    // plus a spec-only timePeriod injected for moving averages
    // whose C signature has no period (MAMA) so that every MA
    // spec carries one for its downstream consumers. The injected
    // formal is deliberately absent from the .Call() coercions
    let mut formals = f.optional_input.clone();
    if ma_index.is_some() && !formals.iter().any(|a| a.name == "timePeriod") {
        formals.insert(
            0,
            OptionalArg {
                name: "timePeriod".to_string(),
                kind: OptionalType::Integer,
                default: "30".to_string(),
                description: "Number of period".to_string(),
            },
        );
    }

    // the ${PARAM_DOCS} roxygen lines of the generic, one @param
    // per optional input with its type, XML description and default,
    // e.g. #' @param fastPeriod ([integer]). Number of period for
    // the fast MA. Defaults to `12`. MAType formals additionally
    // carry the index legend with the default's moving average
    // spelled out inline.
    //
    // timePeriod and penetration are skipped: they are documented
    // by the man-roxygen templates ('description.R' and
    // 'rolling_description.R'). An empty result renders a blank
    // roxygen line so the block stays contiguous
    // the extra input series of the moving averages (VWMA:
    // volume) are formals of the generic and carry their own
    // @param line ahead of the optional inputs
    let ma_extra: &[String] = if ma_index.is_some() {
        &f.input[1..]
    } else {
        &[]
    };

    let param_docs = {
        let docs = ma_extra
            .iter()
            .map(|s| {
                format!(
                    "#' @param {s} ([numeric]). The {s} series. Defaults to the '{s}' column of the 'cols' selection."
                )
            })
            .chain(f.passthrough
            .iter()
            .map(|p| {
                format!(
                    "#' @param {p} ([numeric]). Vector of periods, one per observation of the input series."
                )
            }))
            .chain(formals
            .iter()
            .filter(|a| a.name != "timePeriod" && a.name != "penetration")
            .map(|a| match a.kind {
                OptionalType::MAType => {
                    let default_ma = MOVING_AVERAGES
                        .iter()
                        .find(|(_, index)| index.trim_end_matches('L') == a.default)
                        .map(|(ma, _)| *ma)
                        .unwrap_or_else(|| panic!("no moving average for TA_MAType {}", a.default));

                    format!(
                        "#' @param {} ([integer]). {}. Defaults to `{}` ([{}]). Can also be passed as talib::{}.",
                        a.name, a.description, a.default, default_ma, default_ma
                    )
                }
                _ => format!(
                    "#' @param {} ([{}]). {}. Defaults to `{}`.",
                    a.name,
                    match a.kind {
                        OptionalType::Double => "double",
                        _ => "integer",
                    },
                    a.description,
                    a.default
                ),
            }))
            .collect::<Vec<String>>()
            .join("\n");

        if docs.is_empty() {
            "#'".to_string()
        } else {
            docs
        }
    };

    // formals and pass-through arguments,
    // e.g. 'timePeriod = 14,' and 'timePeriod = timePeriod,'.
    // Passthrough inputs (MAVP: periods) lead as required formals
    // without a default
    let args = f
        .passthrough
        .iter()
        .map(|p| format!("{p},"))
        .chain(
            formals
                .iter()
                .map(|a| format!("{} = {},", a.name, a.default)),
        )
        .collect::<Vec<String>>()
        .join("\n\t");

    let pargs = f
        .passthrough
        .iter()
        .chain(formals.iter().map(|a| &a.name))
        .map(|name| format!("{name} = {name},"))
        .collect::<Vec<String>>()
        .join("\n\t\t\t");

    // the spec-mode list fields of the moving_average template:
    // each formal round-trips as 'name = if (missing(name)) <default>
    // else as.<type>(name)' in the list returned without 'x'
    let spec_fields = formals
        .iter()
        .map(|a| match a.kind {
            OptionalType::Double => format!(
                "{name} = if (missing({name})) {} else as.double({name})",
                a.default,
                name = a.name
            ),
            _ => format!(
                "{name} = if (missing({name})) {}L else as.integer({name})",
                a.default,
                name = a.name
            ),
        })
        .collect::<Vec<String>>()
        .join(",\n\t\t\t\t");

    // the bare argument names of the chart label(),
    // each with a leading comma: label("SMA", timePeriod)
    let cargs = f
        .optional_input
        .iter()
        .map(|a| format!(", {}", a.name))
        .collect::<String>();

    // the coerced optional inputs of the .Call() arguments
    let coercions: Vec<String> = f
        .optional_input
        .iter()
        .map(|a| match a.kind {
            OptionalType::Double => format!("as.double({})", a.name),
            OptionalType::MAType => format!("as.maType({})", a.name),
            _ => format!("as.integer({})", a.name),
        })
        .collect();

    // the coerced passthrough formals: required inputs are always
    // double arrays in TA-Lib, so as.double() guards the type on
    // the R side (the C side additionally length-checks against
    // the first input series)
    let passthrough: Vec<String> = f
        .passthrough
        .iter()
        .map(|p| format!("as.double({p})"))
        .collect();

    // the .Call() arguments: one constructed_series column per
    // required input (the raw vector for the numeric method),
    // then the coerced passthrough formals, followed by the
    // coerced optional inputs
    let c_signature = (1..=f.input.len())
        .map(|i| format!("constructed_series[[{i}]]"))
        .chain(passthrough.iter().cloned())
        .chain(coercions.iter().cloned())
        .collect::<Vec<String>>()
        .join(",\n\t\t");

    // the raw-vector series of the numeric/rolling path: the
    // first input series is the dispatching 'x', every further
    // input keeps its mined name as a required formal (BETA,
    // CORREL: y; VWMA: volume). ${SERIES}/${PSERIES} render the
    // formals and the forwarded arguments, one per line with a
    // trailing comma
    let series: Vec<String> = std::iter::once("x".to_string())
        .chain(f.input.iter().skip(1).cloned())
        .collect();

    let series_args = series
        .iter()
        .map(|s| format!("{s},"))
        .collect::<Vec<String>>()
        .join("\n\t");

    let pseries = series
        .iter()
        .map(|s| format!("{s} = {s},"))
        .collect::<Vec<String>>()
        .join("\n\t\t");

    // the univariate guard of the rolling .default/.xts methods:
    // one assert per input series, rejecting multi-column input
    // instead of flattening it column-major
    let series_guard = series
        .iter()
        .map(|s| {
            format!(
                "assert(\n\t\tx = NCOL({s}) == 1L,\n\t\tcall = sys.call(sys.parent()),\n\t\t\"Expected '{s}' to be univariate.\",\n\t\tpaste0(\"Got \", NCOL({s}), \" columns.\")\n\t)"
            )
        })
        .collect::<Vec<String>>()
        .join("\n\n\t");

    let c_numeric = series
        .iter()
        .map(|s| format!("as.double({s})"))
        .chain(passthrough.iter().cloned())
        .chain(coercions.iter().cloned())
        .collect::<Vec<String>>()
        .join(",\n\t\t");

    // the extra input series of the moving averages beyond the
    // dispatching 'x' (VWMA: volume): formals of the generic and
    // every method, leading right after 'x', falling back to
    // their formula column when not explicitly passed
    let ma_series = series[1..]
        .iter()
        .map(|s| format!("{s},"))
        .collect::<Vec<String>>()
        .join("\n\t");

    let ma_pseries = series[1..]
        .iter()
        .map(|s| format!("{s} = {s},"))
        .collect::<Vec<String>>()
        .join("\n\t\t\t");

    // the default formula of the MA .default/chart methods: when
    // every extra series is passed explicitly only the first
    // column is selected, otherwise the full formula feeds the
    // fallback
    let ma_formula = if series.len() > 1 {
        let cond = series[1..]
            .iter()
            .map(|s| format!("missing({s})"))
            .collect::<Vec<String>>()
            .join(" && ");

        format!("if ({cond}) {formula} else ~{}", f.input[0])
    } else {
        formula.clone()
    };

    // the missing()-fallback of the MA .default: extra series
    // not explicitly passed are taken from their formula column
    let ma_fallback = series[1..]
        .iter()
        .enumerate()
        .map(|(i, s)| {
            format!(
                "\n\t## fall back to the formula\n\t## column when '{s}' is\n\t## not explicitly passed\n\tif (missing({s})) {{\n\t\t{s} <- constructed_series[[{}]]\n\t}}\n",
                i + 2
            )
        })
        .collect::<String>();

    // the .Call() arguments of the MA .default: the first series
    // column, the coerced extra series and the coerced optional
    // inputs
    let ma_c_series = std::iter::once("constructed_series[[1]]".to_string())
        .chain(series[1..].iter().map(|s| format!("as.double({s})")))
        .chain(coercions.iter().cloned())
        .collect::<Vec<String>>()
        .join(",\n\t\t");

    // the .Call() arguments of the lookback wrapper: only the
    // coerced optional inputs (see TA_LB_WRAPPER in src/wrapper.h).
    // Each entry carries a *leading* comma so that indicators
    // without optional inputs render .Call(C_impl_ta_X_lookback)
    // without a dangling empty argument
    let c_lookback = coercions
        .iter()
        .map(|c| format!(",\n\t\t{c}"))
        .collect::<String>();

    // the camelCase alias; single-word indicator names camelCase
    // to themselves, dropping the '#camel#' alias block instead
    let camel = camel_case_name(&f.indicator);
    let has_camel = camel != fun;

    // the camelCase link of the chained lookback assignment
    // (BBANDS_lookback <- bollingerBands_lookback <- ...)
    let camel_lookback = if has_camel {
        format!("{camel}_lookback <- ")
    } else {
        String::new()
    };

    let fill = |template: &str| {
        render_camel(template, has_camel)
            .replace("${FUN}", fun)
            .replace("${ALIAS}", &f.indicator)
            .replace("${CAMEL_LOOKBACK}", &camel_lookback)
            .replace("${CAMEL}", &camel)
            .replace("${TITLE}", &f.title)
            .replace(
                "${FAMILY}",
                &f.family
                    .replace("Math Operators", "Rolling Statistics")
                    .replace("Statistic Functions", "Rolling Statistics"),
            )
            .replace("${FORMULA}", &formula)
            .replace("${PARAM_DOCS}", &param_docs)
            .replace("${ARGS}", &args)
            .replace("${PARGS}", &pargs)
            .replace("${C_SIGNATURE_LOOKBACK}", &c_lookback)
            .replace("${C_SIGNATURE}", &c_signature)
            .replace("${C_NUMERIC}", &c_numeric)
            .replace("${MA_SERIES}", &ma_series)
            .replace("${MA_PSERIES}", &ma_pseries)
            .replace("${MA_FORMULA}", &ma_formula)
            .replace("${MA_FALLBACK}", &ma_fallback)
            .replace("${MA_C_SERIES}", &ma_c_series)
            .replace("${SERIES}", &series_args)
            .replace("${SERIES_GUARD}", &series_guard)
            .replace("${PSERIES}", &pseries)
            .replace("${SPEC_FIELDS}", &spec_fields)
            .replace("${MA_TYPE}", ma_index.unwrap_or("-1L"))
            .replace("${CARGS}", &cargs)
            .replace("${AGNOSTIC}", agnostic(&f.indicator))
    };

    // both chart methods from one dual-backend template,
    // .plotly before .ggplot, matching the existing wrappers
    let chart = |template: &str| {
        format!(
            "{}\n{}",
            fill(&render_backend(template, &PLOTLY)),
            fill(&render_backend(template, &GGPLOT))
        )
    };

    let out = if is_candlestick(&f.indicator) {
        format!("{}\n{}", fill(&t.candlestick), chart(&t.chart_candlestick))
    } else if ma_index.is_some() {
        format!(
            "{}\n{}",
            fill(&t.moving_average),
            chart(&t.chart_moving_average)
        )
    } else if f.family == "Statistic Functions" || f.family == "Math Operators" {
        fill(&t.rolling)
    } else {
        let mut out = fill(&t.indicator);

        // univariate indicators (a single input series)
        // carry a .numeric method
        if f.input.len() == 1 {
            out.push('\n');
            out.push_str(&fill(&t.numeric));
        }

        if let Some(kind) = chart_type(&f.indicator) {
            out.push('\n');
            out.push_str(&chart(match kind {
                ChartType::Main => &t.chart_main,
                ChartType::Sub => &t.chart_subchart,
            }));
        }

        out
    };

    strip_blank_indentation(&out)
}

/// Empty multi-entry placeholders (${ARGS}, ${PARGS}) leave their
/// line's bare indentation behind, e.g. a whitespace-only line
/// between 'cols,' and 'na.bridge = FALSE,' for indicators without
/// optional inputs, which air does not reformat away. Drop those
/// lines; truly empty lines (paragraph separators) are kept
fn strip_blank_indentation(rendered: &str) -> String {
    let mut out: String = rendered
        .lines()
        .filter(|line| line.is_empty() || !line.trim().is_empty())
        .collect::<Vec<&str>>()
        .join("\n");

    if rendered.ends_with('\n') {
        out.push('\n');
    }

    out
}

/// Protected regions
///
/// Content between '## splice:<name>:start' and '## splice:<name>:end'
/// marker lines survives regeneration: for every region present in
/// both the freshly rendered output and the previously generated
/// file, the rendered default is replaced by the existing content.
/// Regions absent from the existing file keep the rendered default
pub fn preserve_regions(rendered: &str, existing: &str) -> String {
    let mut out = rendered.to_string();

    // the regions of the rendered output, in order
    let names: Vec<String> = rendered
        .lines()
        .filter_map(|line| {
            line.trim()
                .strip_prefix("## splice:")?
                .strip_suffix(":start")
                .map(str::to_string)
        })
        .collect();

    // region_span() only ever matches the first occurrence of a
    // name, so a duplicated name would silently lose the hand
    // edits of every later occurrence
    for (i, name) in names.iter().enumerate() {
        if names[..i].contains(name) {
            panic!("duplicate splice region '{name}' in rendered output");
        }
    }

    // spans are recomputed per region since each
    // replacement shifts the offsets after it
    for name in names {
        if let (Some((out_start, out_end)), Some((existing_start, existing_end))) =
            (region_span(&out, &name), region_span(existing, &name))
        {
            out.replace_range(out_start..out_end, &existing[existing_start..existing_end]);
        }
    }

    out
}

/// The content span between a region's marker lines: starts on
/// the line after '## splice:<name>:start' and ends at the
/// beginning of the '## splice:<name>:end' line
fn region_span(text: &str, name: &str) -> Option<(usize, usize)> {
    let start_marker = format!("## splice:{name}:start");
    let end_marker = format!("## splice:{name}:end");

    let start = text.find(&start_marker)?;
    let content_start = start + start_marker.len();
    let content_start = content_start + text[content_start..].find('\n')? + 1;

    let end = content_start + text[content_start..].find(&end_marker)?;
    let content_end = text[..end].rfind('\n').map_or(0, |i| i + 1);

    Some((content_start, content_end))
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::metadata::{SAMPLE, parse_api};

    #[test]
    fn strips_blank_indentation() {
        let rendered = "\
stick_sandwich <- function(
\tx,
\tcols,
\t
\tna.bridge = FALSE,
\t...) {
}

next_function\n";

        // the whitespace-only argument line vanishes,
        // the empty separator line stays
        assert_eq!(
            strip_blank_indentation(rendered),
            "\
stick_sandwich <- function(
\tx,
\tcols,
\tna.bridge = FALSE,
\t...) {
}

next_function\n"
        );
    }

    #[test]
    fn renders_backend_variants() {
        let template = "\
${FUN}.${METHOD} <- function(x) {
#plotly#\tassert_plotly_object(x)
#ggplot#\tassert_ggplot2()
\t## construct {${PKG}}-object
\tadd_last_value_${SUFFIX}(x)
}
";

        // each backend keeps its own conditional lines (prefix
        // stripped) and fills the backend placeholders; the
        // indicator placeholders are left for fill()
        assert_eq!(
            render_backend(template, &PLOTLY),
            "\
${FUN}.plotly <- function(x) {
\tassert_plotly_object(x)
\t## construct {plotly}-object
\tadd_last_value_ly(x)
}
"
        );
        assert_eq!(
            render_backend(template, &GGPLOT),
            "\
${FUN}.ggplot <- function(x) {
\tassert_ggplot2()
\t## construct {ggplot2}-object
\tadd_last_value_gg(x)
}
"
        );
    }

    #[test]
    fn preserves_protected_regions() {
        let rendered = "\
head
\t## splice:documentation:start
\tdefault docs
\t## splice:documentation:end
mid
\t## splice:plotly-assembly:start
\tdefault traces
\t## splice:plotly-assembly:end
tail
";
        let existing = "\
old head
\t## splice:documentation:start
\tcustom docs
\tsecond line
\t## splice:documentation:end
old mid
\t## splice:plotly-assembly:start
\tcustom traces
\t## splice:plotly-assembly:end
old tail
";

        // both regions carry over their existing content while
        // everything outside the markers is regenerated
        let preserved = preserve_regions(rendered, existing);
        assert_eq!(
            preserved,
            "\
head
\t## splice:documentation:start
\tcustom docs
\tsecond line
\t## splice:documentation:end
mid
\t## splice:plotly-assembly:start
\tcustom traces
\t## splice:plotly-assembly:end
tail
"
        );

        // no regions in the existing file:
        // the rendered default is kept
        assert_eq!(preserve_regions(rendered, "plain old file"), rendered);

        // emptied-out region in the existing
        // file stays empty after regeneration
        let emptied = "\
\t## splice:documentation:start
\t## splice:documentation:end
";
        let preserved = preserve_regions(rendered, emptied);
        assert!(
            preserved.contains("\t## splice:documentation:start\n\t## splice:documentation:end")
        );
        assert!(preserved.contains("default traces"));
    }

    #[test]
    fn renders_template() {
        let funcs = parse_api(SAMPLE);
        let templates = Templates::load(concat!(env!("CARGO_MANIFEST_DIR"), "/templates"));

        let rendered = render_indicator(&funcs[0], &templates);

        assert!(rendered.contains("bollinger_bands <- function("));
        assert!(rendered.contains("BBANDS <- bollinger_bands"));
        assert!(rendered.contains("timePeriod = 5,"));
        assert!(rendered.contains("deviationsUp = 2,"));
        assert!(rendered.contains("default_formula = ~close,"));
        assert!(rendered.contains("C_impl_ta_BBANDS,"));
        assert!(rendered.contains("constructed_series[[1]]"));
        assert!(rendered.contains("as.integer(timePeriod)"));
        assert!(rendered.contains("as.double(deviationsUp)"));
        assert!(!rendered.contains("${"), "unreplaced placeholder");

        // the optional inputs are documented with type, description
        // and default; timePeriod stays with the man-roxygen template
        assert!(rendered.contains(
            "#' @param deviationsUp ([double]). Deviation multiplier for upper band. Defaults to `2`."
        ));
        assert!(!rendered.contains("#' @param timePeriod"));

        // MAType formals carry the TA_MAType legend with the
        // default's moving average spelled out inline
        assert!(rendered.contains(
            "#' @param maType ([integer]). Type of Moving Average. Defaults to `0` ([SMA]). Can also be passed as talib::SMA."
        ));

        // univariate: the numeric method is appended
        // after the matrix method with the raw vector
        assert!(rendered.contains("bollinger_bands.numeric <- function("));
        assert!(rendered.contains("as.double(x)"));

        // the lookback wrapper passes only the
        // coerced optional inputs to C
        assert!(rendered.contains("bollinger_bands_lookback <- function("));
        assert!(rendered.contains(
            "C_impl_ta_BBANDS_lookback,\n\t\tas.integer(timePeriod),\n\t\tas.double(deviationsUp),\n\t\tas.maType(maType)\n\t)"
        ));

        // BBANDS is a Main chart indicator: the plotly and ggplot
        // methods are rendered from the dual-backend template and
        // draw onto the main chart state
        assert!(rendered.contains("bollinger_bands.plotly <- function("));
        assert!(rendered.contains("bollinger_bands.ggplot <- function("));
        assert!(rendered.contains("## splice:optional-plotly:start"));
        assert!(rendered.contains("## splice:ggplot-assembly:start"));
        assert!(rendered.contains("state[[\"main\"]]"));
        assert!(!rendered.contains("#plotly#"), "unstripped backend prefix");
        assert!(!rendered.contains("#ggplot#"), "unstripped backend prefix");

        // CDL* renders from the candlestick template: normalized
        // pattern codes, the named output column and the chart
        // methods with pattern markers
        let rendered = render_indicator(&funcs[1], &templates);

        assert!(rendered.contains("doji <- function("));
        assert!(rendered.contains("CDLDOJI <- doji"));
        assert!(rendered.contains("candlestick_setting()"));
        assert!(rendered.contains("default_formula = ~open + high + low + close,"));
        assert!(rendered.contains("colnames(x) <- \"CDLDOJI\""));
        assert!(!rendered.contains(",,"));
        assert!(!rendered.contains("${"), "unreplaced placeholder");

        // CDLDOJI is OHLC order agnostic
        assert!(rendered.contains("doji.plotly <- function("));
        assert!(rendered.contains("doji.ggplot <- function("));
        assert!(rendered.contains("pattern_ly("));
        assert!(rendered.contains("pattern_gg("));
        assert!(rendered.contains("agnostic = TRUE"));

        // the candlestick template carries
        // no lookback and no numeric method
        assert!(!rendered.contains("_lookback"));
        assert!(!rendered.contains(".numeric"));
    }

    #[test]
    fn renders_camel_alias() {
        let funcs = parse_api(SAMPLE);
        let templates = Templates::load(concat!(env!("CARGO_MANIFEST_DIR"), "/templates"));

        // BBANDS carries a camelCase alias next to the uppercase
        // one, and its lookback joins the chained assignment
        let rendered = render_indicator(&funcs[0], &templates);
        assert!(rendered.contains("bollingerBands <- bollinger_bands"));
        assert!(rendered.contains(
            "BBANDS_lookback <- bollingerBands_lookback <- bollinger_bands_lookback <- function("
        ));
        assert!(!rendered.contains("#camel#"), "unstripped camel prefix");

        // 'doji' camelCases to itself: the alias block is
        // dropped and the lookback chain stays two-membered
        let rendered = render_indicator(&funcs[1], &templates);
        assert!(!rendered.contains("doji <- doji"));
        assert!(rendered.contains("CDLDOJI_lookback <- doji_lookback <- function("));
        assert!(!rendered.contains("#camel#"), "unstripped camel prefix");
    }

    #[test]
    fn renders_full_api() {
        let xml = std::fs::read_to_string(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/../src/ta-lib/ta_func_api.xml"
        ))
        .expect("read ta_func_api.xml");
        let templates = Templates::load(concat!(env!("CARGO_MANIFEST_DIR"), "/templates"));

        let funcs = parse_api(&xml);

        for f in &funcs {
            let rendered = render_indicator(f, &templates);
            assert!(
                !rendered.contains("${"),
                "unreplaced placeholder in {}",
                f.indicator
            );
            assert!(
                !rendered.contains("#plotly#") && !rendered.contains("#ggplot#"),
                "unstripped backend prefix in {}",
                f.indicator
            );
        }

        let render = |abbreviation: &str| {
            render_indicator(
                funcs
                    .iter()
                    .find(|f| f.indicator == abbreviation)
                    .unwrap_or_else(|| panic!("{abbreviation} not parsed")),
                &templates,
            )
        };

        // moving averages: spec-mode list with the TA_MAType
        // index and the main-chart methods
        let sma = render("SMA");
        assert!(sma.contains("simple_moving_average <- function("));
        assert!(sma.contains("maType = 0L"));
        assert!(
            sma.contains("timePeriod = if (missing(timePeriod)) 30L else as.integer(timePeriod)")
        );
        assert!(sma.contains("legendgroup = \"MovingAverage\""));
        assert!(sma.contains("label(\"SMA\", timePeriod)"));
        assert!(sma.contains("simple_moving_average.plotly <- function("));
        assert!(sma.contains("simple_moving_average.ggplot <- function("));
        assert!(sma.contains("simple_moving_average.numeric <- function("));

        // the MA formal ordering: x, extra series, options,
        // cols, na.bridge
        assert!(sma.contains("\tx,\n\ttimePeriod = 30,\n\tcols,\n\tna.bridge = FALSE,"));
        assert!(sma.contains("formula.default = ~close,"));

        // VWMA: volume is a formal of every method, coerced into
        // the .Call() next to the price column, with the formula
        // column as its fallback when not explicitly passed
        let vwma = render("VWMA");
        assert!(
            vwma.contains("\tx,\n\tvolume,\n\ttimePeriod = 30,\n\tcols,\n\tna.bridge = FALSE,")
        );
        assert!(
            vwma.contains("formula.default = if (missing(volume)) ~close + volume else ~close,")
        );
        assert!(
            vwma.contains("if (missing(volume)) {\n\t\tvolume <- constructed_series[[2]]\n\t}")
        );
        assert!(vwma.contains(
            "constructed_series[[1]],\n\t\tas.double(volume),\n\t\tas.integer(timePeriod)"
        ));
        assert!(vwma.contains("volume_weighted_moving_average.numeric <- function("));
        assert!(vwma.contains("as.double(x),\n\t\tas.double(volume),\n\t\tas.integer(timePeriod)"));
        assert!(vwma.contains(
            "#' @param volume ([numeric]). The volume series. Defaults to the 'volume' column of the 'cols' selection."
        ));

        // MAMA: the injected spec-only timePeriod is a formal and
        // a spec field but is absent from the .Call() arguments
        let mama = render("MAMA");
        assert!(
            mama.contains("timePeriod = if (missing(timePeriod)) 30L else as.integer(timePeriod)")
        );
        assert!(mama.contains(
            "constructed_series[[1]],\n\t\tas.double(fastLimit),\n\t\tas.double(slowLimit)"
        ));

        // every optional input beyond timePeriod/penetration is
        // documented with type, description and default
        let macd = render("MACD");
        assert!(macd.contains(
            "#' @param fastPeriod ([integer]). Number of period for the fast MA. Defaults to `12`."
        ));
        assert!(macd.contains(
            "#' @param signalPeriod ([integer]). Smoothing for the signal line (nb of period). Defaults to `9`."
        ));

        // MAVP: the passthrough 'periods' leads the formals as a
        // required argument (no default) and is passed to .Call()
        // coerced, between the series column and the coerced
        // optional inputs
        let mavp = render("MAVP");
        assert!(mavp.contains(
            "variable_moving_average_period <- function(\n\tx,\n\tcols,\n\tperiods,\n\tminimumPeriod = 2,"
        ));
        assert!(mavp.contains("default_formula = ~close,"));
        assert!(mavp.contains(
            "constructed_series[[1]],\n\t\tas.double(periods),\n\t\tas.integer(minimumPeriod)"
        ));
        assert!(mavp.contains("periods = periods,"));
        assert!(mavp.contains(
            "#' @param periods ([numeric]). Vector of periods, one per observation of the input series."
        ));

        // MAVP is univariate by series count: the numeric method
        // passes the raw vector plus the passthrough
        assert!(mavp.contains("variable_moving_average_period.numeric <- function("));
        assert!(mavp.contains("as.double(x),\n\t\tas.double(periods),"));

        // the lookback wrapper keeps taking only the
        // coerced optional inputs
        assert!(mavp.contains(
            "C_impl_ta_MAVP_lookback,\n\t\tas.integer(minimumPeriod),\n\t\tas.integer(maximumPeriod),\n\t\tas.maType(maType)\n\t)"
        ));

        // rolling statistics: protected .Call() region,
        // no chart methods
        let stddev = render("STDDEV");
        assert!(stddev.contains("rolling_standard_deviation <- function("));
        assert!(
            stddev.contains(
                "#' @param deviations ([double]). Number of deviations. Defaults to `1`."
            )
        );
        assert!(!stddev.contains("#' @param timePeriod"));
        assert!(stddev.contains("@template rolling_returns"));
        assert!(stddev.contains("## splice:call:start"));
        assert!(stddev.contains("as.double(x),"));
        assert!(!stddev.contains("as.double(y)"));
        assert!(!stddev.contains(".plotly"));
        assert!(!stddev.contains(".ggplot"));

        // the bivariate rolling statistics (inReal0/inReal1) take
        // the pair x/y and pass both series to the C routine
        let correl = render("CORREL");
        assert!(correl.contains("rolling_correlation <- function(\n\tx,\n\ty,"));
        assert!(correl.contains("as.double(x),\n\t\tas.double(y),\n\t\tas.integer(timePeriod)"));
        assert!(correl.contains("x = x,\n\t\ty = y,"));

        // candlesticks: the agnostic flag comes
        // from AGNOSTIC_PATTERNS
        assert!(render("CDLDOJI").contains("agnostic = TRUE"));
        assert!(render("CDLHAMMER").contains("agnostic = FALSE"));
    }
}
