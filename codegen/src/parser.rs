/// TA-Lib header parser
/// 
/// Functions are parsed from 'src/ta-lib/include/ta_func.h'
/// deterministically - All functions follows the same structure
/// TA_foo(InputIdx, Input, OptionalArguments, OutputIdx, Output)
/// which means that the entire header can just be mined directly.
/// 
/// Prior to this Rust parser, a BASH script were used to achieve the
/// same thing - however, it introduced a significant overhead when new
/// arguments were introduced on the R side and the BASH script kept
/// growing.
#[allow(non_camel_case_types)]
#[derive(Debug, Default, PartialEq)]
pub struct TA_Lib {
    pub indicator: String,
    pub argument_type: &'static str,
    pub input: Vec<String>,
    pub optional_input: Vec<String>,
    pub output_indicators: Vec<String>,
    pub output_names: Vec<String>
}

/// Each TA_Lib function defined in the header
/// is on the following form:
///
/// /*
///  * TA_ACCBANDS - Acceleration Bands
///  * 
///  * Input  = High, Low, Close
///  * Output = double, double, double
///  * 
///  * Optional Parameters
///  * -------------------
///  * optInTimePeriod:(From 2 to 100000)
///  *    Number of period
///  * 
///  * 
///  */
/// 
/// TA_LIB_API TA_RetCode TA_ACCBANDS(
///    int startIdx,
///    int endIdx,
///    const double inHigh[],
///    const double inLow[],
///    const double inClose[],
///    int optInTimePeriod, /* From 2 to 100000 */
///    int *outBegIdx,
///    int *outNBElement,
///    double outRealUpperBand[],
///    double outRealMiddleBand[],
///    double outRealLowerBand[]
/// );
///
/// So each function can be easily identified
/// and parsed accordingly
/// 
/// The goal is to build a X-Macro on the C-side
/// that is variadic to reduce the amount of code
/// in the wrapper
#[allow(non_snake_case)]
pub fn purge_comments(TA: &str) -> String {
    // delete all block comments
    // from the files
    let TA_bytes = TA.as_bytes();

    // the function outputs
    // a string
    let mut output = String::with_capacity(
        TA.len()
    );

    // strip all comments
    let mut i = 0;
    while i < TA_bytes.len() {
        if i + 1 < TA_bytes.len() && TA_bytes[i] == b'/' && TA_bytes[i + 1] == b'*' {
            i += 2;
            while i + 1 < TA_bytes.len() && !(TA_bytes[i] == b'*' && TA_bytes[i + 1] == b'/') {
                i += 1;
            }
            i += 2;
            output.push(' ');
        } else {
            output.push(TA_bytes[i] as char);
            i += 1;
        }
    }

    return output;
}

/// The identifier of a parameter: drop `[]`/`*` and take the last token.
fn parameter_identifier(param: &str) -> String {
    param
        .replace("[]", " ")
        .replace('*', " ")
        .split_whitespace()
        .last()
        .unwrap_or("")
        .to_string()
}

/// Extract Signature - Like finding a needle in a haystack
/// Params:
///     indicator: The name of the indicator
///     header: Relative path to the the header
/// Returns
///     A TA-Lib struct with all relevant fields otherwise
///     it will panic if not found
pub fn extract_signature(indicator: &str, header: &str) -> TA_Lib {
    let needle = format!("TA_RetCode TA_{indicator}(");

    let start = header
        .find(&needle)
        .unwrap_or_else(|| panic!("prototype not found: {indicator}"));

    let after = &header[start + needle.len()..];

    let end = after
        .find(')')
        .unwrap_or_else(|| panic!("no closing paren for {indicator}"));

    let params: Vec<&str> = after[..end]
        .split(',')
        .map(str::trim)
        .filter(|s| !s.is_empty())
        .collect();

    let mut f = TA_Lib {
        indicator: indicator.to_string(),
        argument_type: "TA_DOUBLE",
        ..Default::default()
    };

    for (_idx, p) in params.iter().enumerate() {
        // skip TA_INDICATOR(int startIdx, int endIdx, ...)
        if p.contains("startIdx") || p.contains("endIdx") {
            continue;
        }
        // skip TA_INDICATOR(..., int *outBegIdx, int *outNBElement, ...)
        if p.contains("outBegIdx") || p.contains("outNBElement") {
            continue; // int *outBegIdx, int *outNBElement
        }

        // The TA_INDICATOR contains two types
        // of arrays - immutable input arrays, and mutable
        // output arrays. Input arrays are *always* doubles
        // while output can be integer arrays (candlestick patterns)
        if p.contains("[]") {
            // if its an array determine whether
            // its an input or output array
            let nm = parameter_identifier(p);

            if p.contains("const") {
                f.input.push(nm); // if its constant strip the keyword
            } else {
                // determine the type of the array
                // if its an output arrays and set
                // output indicator arrays (e.g outReal)
                f.argument_type = if p.contains("double") { "TA_DOUBLE" } else { "TA_INTEGER" };
                f.output_indicators.push(nm);
            }
        } else {
            // the remainder of the TA_INDICATOR(..., int optInTimePeriod, ...)
            // can either be a double, integer or MAType
            let nm = parameter_identifier(p);

            // determine the optional input
            // type in the indicator
            f.optional_input.push(if p.contains("TA_MAType") {
                format!("OPTIONAL_MATYPE({nm})")
            } else if p.contains("double") {
                format!("OPTIONAL_DOUBLE({nm})")
            } else {
                format!("OPTIONAL_INTEGER({nm})")
            });
        }
    }

    // The output names are given as outReal, outRealUpperBand
    // which needs to be stripped so it ouputs UpperBand and
    // for univariate output where outReal is not identifiable
    // from the outputs the indicator name is replaced so
    // outReal becomes SMA for TA_SMA()
    for output in &f.output_indicators {

        // strip the following strings
        // from the output: 'out', 'Real' and 'Integer'
        let bare = output.strip_prefix("out").unwrap_or(output);
        let bare = bare.strip_prefix("Real").unwrap_or(bare);
        let bare = bare.strip_prefix("Integer").unwrap_or(bare);

        // replace with indicator name or
        // stripped names
        f.output_names.push(if bare.is_empty() {
            f.indicator.clone()
        } else {
            bare.to_string()
        });
    }
    f
}

#[cfg(test)]
mod tests {
    use super::*;

    const SAMPLE: &str = "
        TA_LIB_API TA_RetCode TA_RSI(
            int startIdx, 
            int endIdx,
            const double inReal[],
            int optInTimePeriod,
            int *outBegIdx, 
            int *outNBElement,
            double outReal[]
        );
        
        TA_LIB_API TA_RetCode TA_BBANDS(
            int startIdx, int endIdx,
            const double inReal[],
            int optInTimePeriod, 
            double optInNbDevUp,
            double optInNbDevDn,
            TA_MAType optInMAType,
            int *outBegIdx, 
            int *outNBElement,
            double outRealUpperBand[],
            double outRealMiddleBand[],
            double outRealLowerBand[]
        );

        TA_LIB_API TA_RetCode TA_CDLDOJI(
            int startIdx, 
            int endIdx,
            const double inOpen[], 
            const double inHigh[],
            const double inLow[], 
            const double inClose[],
            int *outBegIdx, 
            int *outNBElement,
            int outInteger[]
        );
    ";

    #[test]
    fn parses_single_real() {
        let f = extract_signature("RSI", SAMPLE);
        assert_eq!(f.argument_type, "TA_DBL");
        assert_eq!(f.input, ["inReal"]);
        assert_eq!(f.optional_input, ["OPT_INT(optInTimePeriod)"]);
        assert_eq!(f.output_indicators, ["outReal"]);
        assert_eq!(f.output_names, ["RSI"]);
    }

    #[test]
    fn parses_multi_out_and_matypes() {
        let f = extract_signature("BBANDS", SAMPLE);
        assert_eq!(f.input, ["inReal"]);
        assert_eq!(
            f.optional_input,
            [
                "OPT_INT(optInTimePeriod)",
                "OPT_DBL(optInNbDevUp)",
                "OPT_DBL(optInNbDevDn)",
                "OPT_MA(optInMAType)"
            ]
        );
        assert_eq!(f.output_indicators, ["outRealUpperBand", "outRealMiddleBand", "outRealLowerBand"]);
        assert_eq!(f.output_names, ["UpperBand", "MiddleBand", "LowerBand"]);
    }

    #[test]
    fn parses_int_output_and_ohlc() {
        let f = extract_signature("CDLDOJI", SAMPLE);
        assert_eq!(f.argument_type, "TA_INT");
        assert_eq!(f.input, ["inOpen", "inHigh", "inLow", "inClose"]);
        assert!(f.optional_input.is_empty());
        assert_eq!(f.output_indicators, ["outInteger"]);
        assert_eq!(f.output_names, ["CDLDOJI"]);
    }

    #[test]
    fn strips_comments() {
        assert_eq!(purge_comments("a /* x */ b"), "a   b");
    }
}