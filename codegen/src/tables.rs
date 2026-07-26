//! The hand-maintained lookup tables
//!
//! Everything else is mined from the TA-Lib sources; these tables
//! layer the per-indicator knowledge the sources cannot provide on
//! top: the R function name, the chart type, the family
//! classifications and the exclusions. This is the one file to
//! touch when customizing how an indicator is generated.

use crate::metadata::{tag_blocks, tag_text};

/// Maps <Abbreviation> to snake_case indicator names
/// and defaults to <Abbreviation>
pub const FUNCTION_NAMES: &[(&str, &str)] = &[
    ("ACCBANDS", "acceleration_bands"),
    ("AD", "chaikin_accumulation_distribution_line"),
    ("ADOSC", "chaikin_accumulation_distribution_oscillator"),
    ("ADX", "average_directional_movement_index"),
    ("ADXR", "average_directional_movement_index_rating"),
    ("APO", "absolute_price_oscillator"),
    ("AROON", "aroon"),
    ("AROONOSC", "aroon_oscillator"),
    ("ATR", "average_true_range"),
    ("AVGPRICE", "average_price"),
    ("AVGDEV", "average_deviation"),
    ("BBANDS", "bollinger_bands"),
    ("BETA", "rolling_beta"),
    ("BOP", "balance_of_power"),
    ("CCI", "commodity_channel_index"),
    ("CDL2CROWS", "two_crows"),
    ("CDL3BLACKCROWS", "three_black_crows"),
    ("CDL3INSIDE", "three_inside"),
    ("CDL3LINESTRIKE", "three_line_strike"),
    ("CDL3OUTSIDE", "three_outside"),
    ("CDL3STARSINSOUTH", "three_stars_in_the_south"),
    ("CDL3WHITESOLDIERS", "three_white_soldiers"),
    ("CDLABANDONEDBABY", "abandoned_baby"),
    ("CDLADVANCEBLOCK", "advance_block"),
    ("CDLBELTHOLD", "belt_hold"),
    ("CDLBREAKAWAY", "break_away"),
    ("CDLCLOSINGMARUBOZU", "closing_marubozu"),
    ("CDLCONCEALBABYSWALL", "concealing_baby_swallow"),
    ("CDLCOUNTERATTACK", "counter_attack"),
    ("CDLDARKCLOUDCOVER", "dark_cloud_cover"),
    ("CDLDOJI", "doji"),
    ("CDLDOJISTAR", "doji_star"),
    ("CDLDRAGONFLYDOJI", "dragonfly_doji"),
    ("CDLENGULFING", "engulfing"),
    ("CDLEVENINGDOJISTAR", "evening_doji_star"),
    ("CDLEVENINGSTAR", "evening_star"),
    ("CDLGAPSIDESIDEWHITE", "gaps_side_white"),
    ("CDLGRAVESTONEDOJI", "gravestone_doji"),
    ("CDLHAMMER", "hammer"),
    ("CDLHANGINGMAN", "hanging_man"),
    ("CDLHARAMI", "harami"),
    ("CDLHARAMICROSS", "harami_cross"),
    ("CDLHIGHWAVE", "high_wave"),
    ("CDLHIKKAKE", "hikakke"),
    ("CDLHIKKAKEMOD", "hikakke_mod"),
    ("CDLHOMINGPIGEON", "homing_pigeon"),
    ("CDLIDENTICAL3CROWS", "three_identical_crows"),
    ("CDLINNECK", "in_neck"),
    ("CDLINVERTEDHAMMER", "inverted_hammer"),
    ("CDLKICKING", "kicking"),
    ("CDLKICKINGBYLENGTH", "kicking_baby_length"),
    ("CDLLADDERBOTTOM", "ladder_bottom"),
    ("CDLLONGLEGGEDDOJI", "long_legged_doji"),
    ("CDLLONGLINE", "long_line"),
    ("CDLMARUBOZU", "marubozu"),
    ("CDLMATCHINGLOW", "matching_low"),
    ("CDLMATHOLD", "mat_hold"),
    ("CDLMORNINGDOJISTAR", "morning_doji_star"),
    ("CDLMORNINGSTAR", "morning_star"),
    ("CDLONNECK", "on_neck"),
    ("CDLPIERCING", "piercing"),
    ("CDLRICKSHAWMAN", "rickshaw_man"),
    ("CDLRISEFALL3METHODS", "rise_fall_3_methods"),
    ("CDLSEPARATINGLINES", "separating_lines"),
    ("CDLSHOOTINGSTAR", "shooting_star"),
    ("CDLSHORTLINE", "short_line"),
    ("CDLSPINNINGTOP", "spinning_top"),
    ("CDLSTALLEDPATTERN", "stalled_pattern"),
    ("CDLSTICKSANDWICH", "stick_sandwich"),
    ("CDLTAKURI", "takuri"),
    ("CDLTASUKIGAP", "tasuki_gap"),
    ("CDLTHRUSTING", "thrusting"),
    ("CDLTRISTAR", "tristar"),
    ("CDLUNIQUE3RIVER", "unique_3_river"),
    ("CDLUPSIDEGAP2CROWS", "upside_gap_2_crows"),
    ("CDLXSIDEGAP3METHODS", "xside_gap_3_methods"),
    ("CMO", "chande_momentum_oscillator"),
    ("CORREL", "rolling_correlation"),
    ("DEMA", "double_exponential_moving_average"),
    ("DX", "directional_movement_index"),
    ("EMA", "exponential_moving_average"),
    ("HT_DCPERIOD", "dominant_cycle_period"),
    ("HT_DCPHASE", "dominant_cycle_phase"),
    ("HT_PHASOR", "phasor_components"),
    ("HT_SINE", "sine_wave"),
    ("HT_TRENDLINE", "trendline"),
    ("HT_TRENDMODE", "trend_cycle_mode"),
    ("IMI", "intraday_movement_index"),
    ("KAMA", "kaufman_adaptive_moving_average"),
    ("MAVP", "variable_moving_average_period"),
    ("MACD", "moving_average_convergence_divergence"),
    ("MACDEXT", "extended_moving_average_convergence_divergence"),
    ("MACDFIX", "fixed_moving_average_convergence_divergence"),
    ("MAMA", "mesa_adaptive_moving_average"),
    ("MAX", "rolling_max"),
    ("MEDPRICE", "median_price"),
    ("MFI", "money_flow_index"),
    ("MIDPRICE", "midpoint_price"),
    ("MIDPOINT", "midpoint_period"),
    ("MIN", "rolling_min"),
    ("MINUS_DI", "minus_directional_indicator"),
    ("MINUS_DM", "minus_directional_movement"),
    ("MOM", "momentum"),
    ("NATR", "normalized_average_true_range"),
    ("OBV", "on_balance_volume"),
    ("PLUS_DI", "plus_directional_indicator"),
    ("PLUS_DM", "plus_directional_movement"),
    ("PPO", "percentage_price_oscillator"),
    ("ROC", "rate_of_change"),
    ("ROCR", "ratio_of_change"),
    ("RSI", "relative_strength_index"),
    ("SAR", "parabolic_stop_and_reverse"),
    ("SAREXT", "extended_parabolic_stop_and_reverse"),
    ("SMA", "simple_moving_average"),
    ("STDDEV", "rolling_standard_deviation"),
    ("STOCH", "stochastic"),
    ("STOCHF", "fast_stochastic"),
    ("STOCHRSI", "stochastic_relative_strength_index"),
    ("SUM", "rolling_sum"),
    ("T3", "t3_exponential_moving_average"),
    ("TEMA", "triple_exponential_moving_average"),
    ("TRANGE", "true_range"),
    ("TRIMA", "triangular_moving_average"),
    ("TRIX", "triple_exponential_average"),
    ("TYPPRICE", "typical_price"),
    ("ULTOSC", "ultimate_oscillator"),
    ("VAR", "rolling_variance"),
    ("VOLUME", "trading_volume"),
    ("WCLPRICE", "weighted_close_price"),
    ("WILLR", "williams_oscillator"),
    ("WMA", "weighted_moving_average"),
];

/// The snake_case R name of an indicator,
/// e.g. BBANDS -> bollinger_bands
pub fn function_name(abbreviation: &str) -> &str {
    FUNCTION_NAMES
        .iter()
        .find(|(alias, _)| *alias == abbreviation)
        .map(|(_, fun)| *fun)
        .unwrap_or(abbreviation)
}

/// Main indicators overlay the candlestick chart itself while
/// Sub indicators get their own panel below it. Indicators absent
/// from CHART_TYPES are not chartable and get no chart methods
#[derive(Debug, PartialEq)]
pub enum ChartType {
    Main,
    Sub,
}

pub const CHART_TYPES: &[(&str, ChartType)] = &[
    ("ACCBANDS", ChartType::Main),
    ("AD", ChartType::Sub),
    ("ADOSC", ChartType::Sub),
    ("ADX", ChartType::Sub),
    ("ADXR", ChartType::Sub),
    ("APO", ChartType::Sub),
    ("AROON", ChartType::Sub),
    ("AROONOSC", ChartType::Sub),
    ("ATR", ChartType::Sub),
    ("BBANDS", ChartType::Main),
    ("BOP", ChartType::Sub),
    ("CCI", ChartType::Sub),
    ("CMO", ChartType::Sub),
    ("DX", ChartType::Sub),
    ("HT_DCPERIOD", ChartType::Sub),
    ("HT_DCPHASE", ChartType::Sub),
    ("HT_PHASOR", ChartType::Sub),
    ("HT_SINE", ChartType::Sub),
    ("HT_TRENDLINE", ChartType::Main),
    ("HT_TRENDMODE", ChartType::Sub),
    ("IMI", ChartType::Sub),
    ("MAVP", ChartType::Main),
    ("MACD", ChartType::Sub),
    ("MACDEXT", ChartType::Sub),
    ("MACDFIX", ChartType::Sub),
    ("MFI", ChartType::Sub),
    ("MINUS_DI", ChartType::Sub),
    ("MINUS_DM", ChartType::Sub),
    ("MOM", ChartType::Sub),
    ("NATR", ChartType::Sub),
    ("OBV", ChartType::Sub),
    ("PLUS_DI", ChartType::Sub),
    ("PLUS_DM", ChartType::Sub),
    ("PPO", ChartType::Sub),
    ("ROC", ChartType::Sub),
    ("ROCR", ChartType::Sub),
    ("RSI", ChartType::Sub),
    ("SAR", ChartType::Main),
    ("SAREXT", ChartType::Main),
    ("STOCH", ChartType::Sub),
    ("STOCHF", ChartType::Sub),
    ("STOCHRSI", ChartType::Sub),
    ("TRANGE", ChartType::Sub),
    ("TRIX", ChartType::Sub),
    ("ULTOSC", ChartType::Sub),
    ("VOLUME", ChartType::Sub),
    ("WILLR", ChartType::Sub),
];

pub fn chart_type(abbreviation: &str) -> Option<&'static ChartType> {
    CHART_TYPES
        .iter()
        .find(|(alias, _)| *alias == abbreviation)
        .map(|(_, kind)| kind)
}

/// The TA-Lib moving averages and their TA_MAType index,
/// rendered via 'codegen/templates/moving_average_template.R'.
/// The index fills ${MA_TYPE} in the spec-mode list returned
/// when the MA is called without 'x' (used by e.g. stochastic()
/// to construct its smoothing lines)
pub const MOVING_AVERAGES: &[(&str, &str)] = &[
    ("SMA", "0L"),
    ("EMA", "1L"),
    ("WMA", "2L"),
    ("DEMA", "3L"),
    ("TEMA", "4L"),
    ("TRIMA", "5L"),
    ("KAMA", "6L"),
    ("MAMA", "7L"),
    ("T3", "8L"),
];

/// The TA_MAType index literal of a moving average;
/// None for everything that is not a moving average
pub fn ma_type(indicator: &str) -> Option<&'static str> {
    MOVING_AVERAGES
        .iter()
        .find(|(abbreviation, _)| *abbreviation == indicator)
        .map(|(_, index)| *index)
}

/// The candlestick patterns (Abbreviation starting with "CDL")
/// that are OHLC order agnostic; fills ${AGNOSTIC} with TRUE in
/// the pattern_ly()/pattern_gg() chart markers
pub const AGNOSTIC_PATTERNS: &[&str] = &[
    "CDLCLOSINGMARUBOZU",
    "CDLDOJI",
    "CDLHIGHWAVE",
    "CDLKICKINGBYLENGTH",
    "CDLLONGLEGGEDDOJI",
    "CDLLONGLINE",
    "CDLPIERCING",
    "CDLSHOOTINGSTAR",
    "CDLSHORTLINE",
];

/// Returns true if the indicator is
/// a candlestick pattern
pub fn is_candlestick(indicator: &str) -> bool {
    indicator.starts_with("CDL")
}

/// The R literal for the pattern's OHLC order agnosticism
pub fn agnostic(indicator: &str) -> &'static str {
    if AGNOSTIC_PATTERNS.contains(&indicator) {
        "TRUE"
    } else {
        "FALSE"
    }
}

/// Indicators excluded from porting altogether, by TA-Lib
/// abbreviation: filtered out of both the C wrapper generation
/// (src/TA-Lib.h) and the R wrapper generation (R/ta_*.R)
pub const EXCLUDED_INDICATORS: &[&str] = &[
    "MA",
    "ROC",
    "ROCP",
    "ROCR",
    "ROCR100",
    "LINEARREG",
    "LINEARREG_ANGLE",
    "LINEARREG_SLOPE",
    "LINEARREG_INTERCEPT",
];

/// GroupIds excluded from generation altogether;
/// R already ships vectorized math (sqrt, log, sin, ...)
/// so the Math Transform indicators are redundant
pub const EXCLUDED_GROUPS: &[&str] = &["Math Transform", "Math Operators"];

/// Returns true if the indicator should be
/// skipped by the generators
pub fn is_excluded(indicator: &str) -> bool {
    EXCLUDED_INDICATORS.contains(&indicator)
}

/// All excluded abbreviations, listed directly or via their GroupId;
/// mined from 'src/ta-lib/ta_func_api.xml' since the C generation
/// inputs (ta_func_list.txt, ta_func.h) carry no group information
pub fn excluded_indicators(xml: &str) -> Vec<String> {
    tag_blocks(xml, "FinancialFunction")
        .iter()
        .filter(|block| EXCLUDED_GROUPS.contains(&tag_text(block, "GroupId").expect("GroupId")))
        .map(|block| {
            tag_text(block, "Abbreviation")
                .expect("Abbreviation")
                .to_string()
        })
        .chain(EXCLUDED_INDICATORS.iter().map(|s| s.to_string()))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn function_name_falls_back_to_abbreviation() {
        assert_eq!(function_name("BBANDS"), "bollinger_bands");
        assert_eq!(function_name("NOT_A_REAL_FUNC"), "NOT_A_REAL_FUNC");
    }

    #[test]
    fn excludes_by_group() {
        let xml = "\
<FinancialFunction>
    <Abbreviation>ACOS</Abbreviation>
    <GroupId>Math Transform</GroupId>
</FinancialFunction>
<FinancialFunction>
    <Abbreviation>ADD</Abbreviation>
    <GroupId>Math Operators</GroupId>
</FinancialFunction>
<FinancialFunction>
    <Abbreviation>BBANDS</Abbreviation>
    <GroupId>Overlap Studies</GroupId>
</FinancialFunction>";

        let excluded = excluded_indicators(xml);

        // group-mined abbreviations are in, the rest are not
        assert!(excluded.contains(&"ACOS".to_string()));
        assert!(excluded.contains(&"ADD".to_string()));
        assert!(!excluded.contains(&"BBANDS".to_string()));

        // the name-based list is chained in
        for name in EXCLUDED_INDICATORS {
            assert!(excluded.contains(&name.to_string()));
        }
    }
}
