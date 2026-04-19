## script: Generate Functions
## objective:
## Consolidate functions
## for generators
##
##
## 1) main generator function
impl_generate_indicator <- function(
	title,
	fun,
	family,
	ta_fun,
	formula = "~close",
	plotly = 1L,
	subchart = 1L,
	args,
	agnostic = NULL,
	candlestick = 0,
	maType = -1,
	rolling = 0,
	univariate = NULL,
	n_default = 30L
) {
	if (is.null(formula)) formula <- "~close"
	if (missing(univariate) | is.null(univariate)) {
		has_numeric <- as.integer(
			as.logical(
				length(all.vars(as.formula(formula))) == 1
			)
		)
	} else {
		has_numeric <- univariate
	}

	args <- gsub("([()])", "\\\\\\1", args, perl = TRUE)
	args <- gsub("\\s+", "", args, perl = TRUE)
	system2(
		command = "bash",
		args = c("./codegen/generate_indicator.sh", args),
		env = c(
			sprintf("TITLE='%s'", title),
			sprintf("FUN='%s'", fun),
			sprintf("FAMILY='%s'", family),
			sprintf("TA_FUN='%s'", ta_fun),
			sprintf("FORMULA='%s'", formula),
			sprintf("PLOTLY='%s'", plotly),
			sprintf("AGNOSTIC='%s'", agnostic),
			sprintf("CANDLESTICK='%s'", candlestick),
			sprintf("maType='%s'", maType),
			sprintf("ROLLING='%s'", rolling),
			sprintf("SUBCHART='%s'", subchart),
			sprintf(
				"NUMERIC='%s'",
				has_numeric
			),
			sprintf("N_DEFAULT='%s'", as.integer(n_default))
		)
	)
}

impl_generate_test <- function(
	fun,
	ta_fun,
	formula = "~close",
	plotly = 1,
	rolling = 0,
	args = NULL
) {
	if (is.null(formula)) formula <- "~close"
	args <- gsub("([()])", "\\\\\\1", args, perl = TRUE)
	args <- gsub("\\s+", "", args, perl = TRUE)

	system2(
		command = "bash",
		args = c("./codegen/generate_unit-tests.sh", args),
		env = c(
			sprintf("FUN='%s'", fun),
			sprintf("TA_FUN='%s'", ta_fun),
			sprintf("FORMULA='%s'", formula),
			sprintf("PLOTLY='%s'", plotly),
			sprintf("ROLLING='%s'", rolling),
			sprintf(
				"NUMERIC='%s'",
				as.integer(
					as.logical(
						length(all.vars(as.formula(formula))) == 1
					)
				)
			)
		)
	)
}

