//! ta_func_api.xml mining
//!
//! The metadata driving the R side is mined from
//! 'src/ta-lib/ta_func_api.xml' where each indicator is described
//! as a <FinancialFunction> block:
//!
//! ```xml
//! <FinancialFunction>
//!     <Abbreviation>BBANDS</Abbreviation>
//!     <ShortDescription>Bollinger Bands</ShortDescription>
//!     <GroupId>Overlap Studies</GroupId>
//!     <RequiredInputArguments>...</RequiredInputArguments>
//!     <OptionalInputArguments>...</OptionalInputArguments>
//!     <OutputArguments>...</OutputArguments>
//! </FinancialFunction>
//! ```
//!
//! The XML is attribute-free and machine-generated, so the
//! hand-rolled tag_blocks()/tag_text() mining below is sufficient
//! and keeps the crate dependency-free.

use crate::tables::{EXCLUDED_GROUPS, is_excluded};

/// A <FinancialFunction> reduced to what the R generation needs
#[derive(Debug, Default, PartialEq)]
pub struct MetaData {
    pub title: String,
    pub indicator: String,
    pub family: String,
    pub input: Vec<String>,
    /// Required inputs that are not price series (MAVP: inPeriods).
    /// Rendered as required formals passed straight to .Call()
    /// instead of being routed through the column formula
    pub passthrough: Vec<String>,
    pub optional_input: Vec<OptionalArg>,
}

impl MetaData {
    /// Default column formula, deduplicated in input order,
    /// e.g. [high, low, close] -> ~high + low + close
    pub fn default_formula(&self) -> String {
        let mut cols: Vec<&str> = Vec::new();
        for col in &self.input {
            if !cols.contains(&col.as_str()) {
                cols.push(col);
            }
        }
        format!("~{}", cols.join(" + "))
    }
}

/// An <OptionalInputArgument> reduced to what the
/// R signature needs: an argument name, its type
/// (for the .Call() coercion), its default value and
/// its one-line description (for the @param docs)
#[derive(Clone, Debug, PartialEq)]
pub struct OptionalArg {
    pub name: String,
    pub kind: OptionalType,
    pub default: String,
    pub description: String,
}

#[derive(Clone, Debug, PartialEq)]
pub enum OptionalType {
    Integer,
    Double,
    MAType,
}

/// All <tag>...</tag> contents in document order
pub(crate) fn tag_blocks<'a>(xml: &'a str, tag: &str) -> Vec<&'a str> {
    let open = format!("<{tag}>");
    let close = format!("</{tag}>");

    let mut blocks = Vec::new();
    let mut rest = xml;

    while let Some(start) = rest.find(&open) {
        let after = &rest[start + open.len()..];
        let end = after
            .find(&close)
            .unwrap_or_else(|| panic!("unclosed <{tag}>"));

        blocks.push(after[..end].trim());
        rest = &after[end + close.len()..];
    }

    blocks
}

/// First <tag>...</tag> content, if any
pub(crate) fn tag_text<'a>(xml: &'a str, tag: &str) -> Option<&'a str> {
    let open = format!("<{tag}>");
    let close = format!("</{tag}>");

    let start = xml.find(&open)?;
    let after = &xml[start + open.len()..];
    let end = after.find(&close)?;

    Some(after[..end].trim())
}

/// 'Fast-K Period' -> fastKPeriod, 'Bollinger Bands' -> bollingerBands
fn camel_case(s: &str) -> String {
    let mut out = String::new();
    let mut boundary = false;

    for c in s.chars() {
        if c.is_ascii_alphanumeric() {
            if boundary && !out.is_empty() {
                out.push(c.to_ascii_uppercase());
            } else {
                out.push(c.to_ascii_lowercase());
            }
            boundary = false;
        } else {
            boundary = true;
        }
    }

    out
}

/// Parse 'src/ta-lib/ta_func_api.xml' into one MetaData
/// per <FinancialFunction>, skipping the exclusions
pub fn parse_api(xml: &str) -> Vec<MetaData> {
    tag_blocks(xml, "FinancialFunction")
        .iter()
        .map(|block| {
            let mut f = MetaData {
                indicator: tag_text(block, "Abbreviation")
                    .expect("Abbreviation")
                    .to_string(),
                title: tag_text(block, "ShortDescription")
                    .expect("ShortDescription")
                    .to_string(),
                family: tag_text(block, "GroupId").expect("GroupId").to_string(),
                ..Default::default()
            };

            // Required inputs become R column names; price series
            // map to their OHLCV column while plain double arrays
            // (inReal) default to the 'close' column. Anything else
            // (MAVP: inPeriods -> periods) is no price series and
            // becomes a passthrough formal passed straight to
            // .Call() instead of a formula column
            for arg in tag_blocks(block, "RequiredInputArgument") {
                let input_type = tag_text(arg, "Name").expect("input Type");

                f.input.push(match input_type {
                    "Open" | "High" | "Low" | "Close" | "Volume" => {
                        input_type.to_lowercase().replace("in", "")
                    }
                    "inReal" => "close".to_string(),
                    // inReal0: x and inReal1: y
                    // is affiliated with Price Transforms, Statistics Functions and Math Transforms
                    "inReal0" => "x".to_string(),
                    "inReal1" => "y".to_string(),
                    other => {
                        let name = other.strip_prefix("in").unwrap_or(other);
                        let mut chars = name.chars();
                        let name = match chars.next() {
                            Some(c) => c.to_ascii_lowercase().to_string() + chars.as_str(),
                            None => panic!("empty required input name"),
                        };

                        f.passthrough.push(name);
                        continue;
                    }
                });
            }

            // Optional inputs; the DefaultValue of doubles is stored
            // in scientific notation (2.000000e-2) and is reformatted
            // as a plain R literal (0.02)
            for arg in tag_blocks(block, "OptionalInputArgument") {
                let name = camel_case(tag_text(arg, "Name").expect("optional Name"));
                let default = tag_text(arg, "DefaultValue").expect("DefaultValue");

                // the ShortDescription becomes the @param text; the
                // XML is entity-escaped and carries a few wording
                // slips ('fro', 'Nb of') worth fixing at the source
                let description = tag_text(arg, "ShortDescription")
                    .expect("optional ShortDescription")
                    .replace("&gt;", ">")
                    .replace("&lt;", "<")
                    .replace("&amp;", "&")
                    .replace(" fro ", " for ")
                    .replace("Nb of", "Number of")
                    .trim_end_matches('.')
                    .to_string();

                let (kind, default) = match tag_text(arg, "Type").expect("optional Type") {
                    "Integer" => (OptionalType::Integer, default.to_string()),
                    "MA Type" => (OptionalType::MAType, default.to_string()),
                    "Double" => (
                        OptionalType::Double,
                        format!("{}", default.parse::<f64>().expect("double default")),
                    ),
                    unknown => panic!("unknown optional type: {unknown}"),
                };

                f.optional_input.push(OptionalArg {
                    name,
                    kind,
                    default,
                    description,
                });
            }

            f
        })
        .filter(|f| !EXCLUDED_GROUPS.contains(&f.family.as_str()))
        .filter(|f| !is_excluded(&f.indicator))
        .collect()
}

#[cfg(test)]
pub(crate) const SAMPLE: &str = r#"
    <FinancialFunctions>
        <FinancialFunction>
            <Abbreviation>BBANDS</Abbreviation>
            <CamelCaseName>Bbands</CamelCaseName>
            <ShortDescription>Bollinger Bands</ShortDescription>
            <GroupId>Overlap Studies</GroupId>
            <RequiredInputArguments>
                <RequiredInputArgument>
                    <Type>Double Array</Type>
                    <Name>inReal</Name>
                </RequiredInputArgument>
            </RequiredInputArguments>
            <OptionalInputArguments>
                <OptionalInputArgument>
                    <Name>Time Period</Name>
                    <ShortDescription>Number of period</ShortDescription>
                    <Type>Integer</Type>
                    <Range>
                        <Minimum>2</Minimum>
                        <Maximum>100000</Maximum>
                    </Range>
                    <DefaultValue>5</DefaultValue>
                </OptionalInputArgument>
                <OptionalInputArgument>
                    <Name>Deviations up</Name>
                    <ShortDescription>Deviation multiplier for upper band</ShortDescription>
                    <Type>Double</Type>
                    <DefaultValue>2.000000e+0</DefaultValue>
                </OptionalInputArgument>
                <OptionalInputArgument>
                    <Name>MA Type</Name>
                    <ShortDescription>Type of Moving Average</ShortDescription>
                    <Type>MA Type</Type>
                    <DefaultValue>0</DefaultValue>
                </OptionalInputArgument>
            </OptionalInputArguments>
            <OutputArguments>
                <OutputArgument>
                    <Type>Double Array</Type>
                    <Name>outRealUpperBand</Name>
                </OutputArgument>
                <OutputArgument>
                    <Type>Double Array</Type>
                    <Name>outRealLowerBand</Name>
                </OutputArgument>
            </OutputArguments>
        </FinancialFunction>
        <FinancialFunction>
            <Abbreviation>CDLDOJI</Abbreviation>
            <ShortDescription>Doji</ShortDescription>
            <GroupId>Pattern Recognition</GroupId>
            <RequiredInputArguments>
                <RequiredInputArgument>
                    <Type>Open</Type>
                    <Name>Open</Name>
                </RequiredInputArgument>
                <RequiredInputArgument>
                    <Type>High</Type>
                    <Name>High</Name>
                </RequiredInputArgument>
                <RequiredInputArgument>
                    <Type>Low</Type>
                    <Name>Low</Name>
                </RequiredInputArgument>
                <RequiredInputArgument>
                    <Type>Close</Type>
                    <Name>Close</Name>
                </RequiredInputArgument>
            </RequiredInputArguments>
            <OutputArguments>
                <OutputArgument>
                    <Type>Integer Array</Type>
                    <Name>outInteger</Name>
                </OutputArgument>
            </OutputArguments>
        </FinancialFunction>
    </FinancialFunctions>
    "#;

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_optional_inputs() {
        let f = &parse_api(SAMPLE)[0];

        assert_eq!(f.indicator, "BBANDS");
        assert_eq!(f.title, "Bollinger Bands");
        assert_eq!(f.family, "Overlap Studies");
        assert_eq!(f.input, ["close"]);
        assert_eq!(f.default_formula(), "~close");
        assert_eq!(
            f.optional_input,
            [
                OptionalArg {
                    name: "timePeriod".to_string(),
                    kind: OptionalType::Integer,
                    default: "5".to_string(),
                    description: "Number of period".to_string()
                },
                OptionalArg {
                    name: "deviationsUp".to_string(),
                    kind: OptionalType::Double,
                    default: "2".to_string(),
                    description: "Deviation multiplier for upper band".to_string()
                },
                OptionalArg {
                    name: "maType".to_string(),
                    kind: OptionalType::MAType,
                    default: "0".to_string(),
                    description: "Type of Moving Average".to_string()
                }
            ]
        );
    }

    #[test]
    fn parses_ohlc_inputs() {
        let f = &parse_api(SAMPLE)[1];

        assert_eq!(f.input, ["open", "high", "low", "close"]);
        assert_eq!(f.default_formula(), "~open + high + low + close");
        assert!(f.optional_input.is_empty());
    }

    #[test]
    fn parses_full_api() {
        let xml = std::fs::read_to_string(concat!(
            env!("CARGO_MANIFEST_DIR"),
            "/../src/ta-lib/ta_func_api.xml"
        ))
        .expect("read ta_func_api.xml");

        // 161 functions minus the 15 Math Transforms and the
        // 18 EXCLUDED_INDICATORS
        let funcs = parse_api(&xml);
        assert_eq!(funcs.len(), 128);
        assert!(funcs.iter().all(|f| f.family != "Math Transform"));
        assert!(!funcs.iter().any(|f| f.indicator == "ACOS"));
        assert!(!funcs.iter().any(|f| f.indicator == "MA"));

        // MAVP: inPeriods is a passthrough formal, not a
        // formula column
        let mavp = funcs.iter().find(|f| f.indicator == "MAVP").expect("MAVP");
        assert_eq!(mavp.input, ["close"]);
        assert_eq!(mavp.passthrough, ["periods"]);
        assert_eq!(mavp.default_formula(), "~close");

        // every other indicator has no passthrough inputs
        assert!(
            funcs
                .iter()
                .all(|f| f.indicator == "MAVP" || f.passthrough.is_empty())
        );
    }
}
