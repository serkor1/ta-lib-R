OK good. Now to a proper challenge. I need to run it in a for loop:
## script: Generate unit-tests
## information:
##
## All tests are basically the same
## with only variation in function, alias
## and col arg
##
## So instead of rewriting all damned
## tests everytime, I use a boilerplate
## template.
##
## NOTE: This could also work for the 'C'-wrappers
##       actually.
##
## 1) construct function
##    for generating test-files
all_functions <- list(
  `test-ta_ACCBANDS` = list(
    alias = quote(ACCBANDS),
    main  = quote(acceleration_bands),
    cols  = quote(~ open + high + close)
  ),
  `test-ta_AD` = list(
    alias = quote(AD),
    main  = quote(chaikin_AD_line),
    cols  = quote(~ high + low + close + volume)
  )
)

## 2) comment-aware emitter (your version, unchanged)
.as_lines <- function(x) if (inherits(x, "ta_comment")) paste0("## ", x) else deparse(x, width.cutoff = 80)
.indent   <- function(x, n = 1L) paste0(strrep("\t", n), x)

write_ta_test <- function(file, main, alias, cols, style = TRUE) {
  add_text <- function(...) structure(paste(..., collapse = " "), class = "ta_comment")

  main_sym  <- substitute(main)
  alias_sym <- substitute(alias)
  cols_expr <- substitute(cols)
  alias_chr <- deparse(alias_sym)

  if (!grepl("\\.R$", file, ignore.case = TRUE)) file <- paste0(file, ".R")
  outdir <- file.path("tests", "testthat")
  dir.create(outdir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(outdir, file)

  body <- list(
    add_text("1) calculate values", "with and without alias"),
    bquote(output <- .(main_sym)(SPY)),
    bquote(alias  <- .(alias_sym)(SPY)),

    add_text("1.1) check if the values", "are equal"),
    bquote(testthat::expect_equal(object = output, expected = alias)),

    add_text("2) test that charting", "works"),
    bquote(output <- testthat::expect_no_error({
      chart(BTC)
      indicator(.(main_sym))
    })),

    add_text("2.1) test that it outputs", "a plotly object"),
    quote(testthat::expect_true(inherits(output, "plotly"))),

    add_text("3) test class-in and class-out", "equality"),
    add_text("3.1) matrix"),
    bquote(testthat::expect_true(inherits(.(main_sym)(SPY), class(SPY)))),

    add_text("3.2) data.frame"),
    bquote(testthat::expect_true(inherits(.(main_sym)(BTC), class(BTC)))),

    add_text("4) test that default", "values equals"),
    bquote(testthat::expect_equal(
      object   = .(main_sym)(BTC),
      expected = .(main_sym)(BTC, cols = .(cols_expr))
    ))
  )

  lines <- c(
    sprintf("## script: %s", alias_chr),
    "## author: Serkan Korkmaz",
    sprintf('testthat::test_that(desc = "%s", code = {', alias_chr),
    .indent(unlist(lapply(body, .as_lines)), 1L),
    "})"
  )

  if (style && requireNamespace("styler", quietly = TRUE)) {
    lines <- styler::style_text(lines)
  }
  writeLines(lines, path)
  invisible(path)
}

## 3) generate all files — preserve expressions with quote=TRUE
for (nm in names(all_functions)) {
  spec <- all_functions[[nm]]
  do.call(
    write_ta_test,
    args = c(list(file = nm), spec, list(style = TRUE)),
    quote = TRUE
  )
}