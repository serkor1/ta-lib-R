## script: series
## objective: create an S3 function
## for preparing data passed into C
## and plotly

series <- function(
    x,
    default,
    data,
    ...
) {
    target <- if (!missing(x)) x else default
    UseMethod("series", target)
}

## plotly series
#' @export
series.plotly <- function(
    x,
    formula,
    default,
    data,
    ...
) {
    ## if the data is not provided
    ## extract the data from the plotly
    ## object
    ##
    ## NOTE: If volume is missing
    ##       there might be an issue
    if (missing(data)) {
        ## extract data
        data <- .plotting_environment$x
    }

    series.formula(
        x = formula,
        default = default,
        data = data,
        ...
    )
}

# #' @export
# series.data.frame <- function(
#     x,
#     default,
#     data,
#     ...
# ) {
#     series.formula(
#         x = x,
#         default = default,
#         data = data,
#         ...
#     )
# }

## formula series
#' @export
series.formula <- function(
    x,
    default,
    data,
    ...
) {
    ## coerce to data.frame
    ## for downstream compatibility
    if (!is.data.frame(data)) {
        data <- as.data.frame(
            data
        )
    }

    ## if the formula is missing
    ## replace with the default
    ## value
    if (missing(x)) {
        x <- default
    }

    ## if additional arguments are
    ## not passed we extract the data
    ## by name to avoid the additional
    ## cost of model.frame
    if (...length() == 0) {
        output <- data[,
            all.vars(x),
            drop = FALSE
        ]
    } else {
        ## return data.frame
        output <- model.frame(
            formula = x,
            data = data,
            ...
        )
    }

    return(output)
}
