//! Driver
//!
//! One `cargo run` regenerates everything the codegen owns:
//!
//!   1. `src/TA-Lib.h` — the C X-macro lines (see c_header.rs)
//!   2. `R/ta_<ALIAS>.R` — the R wrappers (see render.rs), with
//!      hand-edited splice regions of the existing files preserved
//!   3. `tests/testthat/test-ta_<ALIAS>.R` — the unit tests
//!      (see testthat.rs), overwritten on every run

mod c_header;
mod metadata;
mod render;
mod tables;
mod testthat;

use std::fs;

fn main() {
    let list = fs::read_to_string("src/ta-lib/ta_func_list.txt").expect("read ta_func_list.txt");
    let header = fs::read_to_string("src/ta-lib/include/ta_func.h").expect("read ta_func.h");
    let xml = fs::read_to_string("src/ta-lib/ta_func_api.xml").expect("read ta_func_api.xml");

    // excluded by name or GroupId; applies to both
    // the C and R generation below
    let excluded = tables::excluded_indicators(&xml);

    let names: Vec<String> = list
        .lines()
        .filter_map(|l| l.split_whitespace().next())
        .filter(|n| !excluded.iter().any(|e| e == n))
        .map(str::to_string)
        .collect();

    fs::write("src/TA-Lib.h", c_header::render_header(&names, &header))
        .expect("write src/TA-Lib.h");

    let templates = render::Templates::load("codegen/templates");

    for f in metadata::parse_api(&xml) {
        let path = format!("R/ta_{}.R", f.indicator);
        let mut rendered = render::render_indicator(&f, &templates);

        // protected regions: hand-edited splice content in the
        // existing wrapper survives regeneration. Only a missing
        // file (first generation) may skip the splice — any other
        // read error must not silently overwrite the hand edits
        // with template defaults
        match fs::read_to_string(&path) {
            Ok(existing) => rendered = render::preserve_regions(&rendered, &existing),
            Err(e) if e.kind() == std::io::ErrorKind::NotFound => {}
            Err(e) => panic!("read {path}: {e}"),
        }

        fs::write(path, rendered).expect("write R wrapper");

        fs::write(
            format!("tests/testthat/test-ta_{}.R", f.indicator),
            testthat::render_test(&f),
        )
        .expect("write unit test");
    }
}
