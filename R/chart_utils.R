

is_subplot <- function(p) {
  flag <- p$x$subplot
  if (is.null(flag)) {
    return(FALSE)
  }
  flag
}




# extract_subplot <- function(p, panel = 1) {
#   if (!is_subplot(p)) {
#     return(p)
#   }
#   b <- plotly::plotly_build(p)

#   xref <- paste0("x", if (panel > 1) panel else "")
#   yref <- paste0("y", if (panel > 1) panel else "")

#   # keep only traces for this axis pair
#   keep <- vapply(b$x$data, function(tr) {
#     (is.null(tr$xaxis) || tr$xaxis == xref) &&
#       (is.null(tr$yaxis) || tr$yaxis == yref)
#   }, logical(1))
#   b$x$data <- b$x$data[keep]

#   # rewrite trace axis refs to defaults ("x","y") for a single-panel figure
#   b$x$data <- lapply(b$x$data, function(tr) { tr$xaxis <- NULL; tr$yaxis <- NULL; tr })

#   la <- b$x$layout
#   ax_x <- la[[paste0("xaxis", if (panel > 1) panel else "")]]
#   ax_y <- la[[paste0("yaxis", if (panel > 1) panel else "")]]

#   # normalize axes: remove subplot positioning/links and fill the canvas
#   scrub <- c("domain","anchor","matches","overlaying","side","position",
#              "scaleanchor","scaleratio","constrain","constraintoward")
#   ax_x[scrub] <- NULL; ax_y[scrub] <- NULL
#   ax_x$domain <- c(0, 1); ax_y$domain <- c(0, 1)
#   ax_x$anchor <- "y";     ax_y$anchor <- "x"

#   globals <- la[intersect(names(la),
#     c("margin","font","template","legend","hovermode","hoverlabel",
#       "paper_bgcolor","plot_bgcolor","barmode","barnorm","colorway"))]

#   b$x$layout <- c(list(xaxis = ax_x, yaxis = ax_y), globals)

#   # keep layout objects scoped to this panel or to 'paper'
#   keep_by_ref <- function(objs) Filter(function(o) {
#     xr <- is.null(o$xref) || o$xref %in% c(xref, "paper")
#     yr <- is.null(o$yref) || o$yref %in% c(yref, "paper")
#     xr && yr
#   }, objs)

#   if (!is.null(la$shapes))      b$x$layout$shapes      <- keep_by_ref(la$shapes)
#   if (!is.null(la$annotations)) b$x$layout$annotations <- keep_by_ref(la$annotations)
#   if (!is.null(la$images))      b$x$layout$images      <- keep_by_ref(la$images)

#   # defensive: remove any subplot/grid residue
#   b$x$layout$grid <- NULL
#   b$x$layout$subplot <- NULL

#   b
# }

# extract_subplot <- function(p, panel = 1) {
#   if (!is_subplot(p)) return(p)

#   x <- p$x

#   xref <- paste0("x", if (panel > 1) panel else "")
#   yref <- paste0("y", if (panel > 1) panel else "")

#   # keep only traces for this axis pair
#   x$data <- Filter(function(tr)
#     (is.null(tr$xaxis) || tr$xaxis == xref) &&
#     (is.null(tr$yaxis) || tr$yaxis == yref), x$data)

#   # normalize trace axis refs to defaults for a single-panel figure
#   x$data <- lapply(x$data, function(tr) { tr$xaxis <- NULL; tr$yaxis <- NULL; tr })

#   la   <- x$layout
#   ax_x <- la[[paste0("xaxis", if (panel > 1) panel else "")]]
#   ax_y <- la[[paste0("yaxis", if (panel > 1) panel else "")]]

#   # fill canvas and drop subplot positioning/links
#   scrub <- c("domain","anchor","matches","overlaying","side","position",
#              "scaleanchor","scaleratio","constrain","constraintoward")
#   ax_x[scrub] <- NULL; ax_y[scrub] <- NULL
#   ax_x$domain <- c(0, 1); ax_y$domain <- c(0, 1)
#   ax_x$anchor <- "y";     ax_y$anchor <- "x"

#   globals <- la[intersect(names(la),
#     c("margin","font","template","legend","hovermode","hoverlabel",
#       "paper_bgcolor","plot_bgcolor","barmode","barnorm","colorway"))]

#   x$layout <- c(list(xaxis = ax_x, yaxis = ax_y), globals)

#   # keep layout objects scoped to this panel or to 'paper'
#   keep_by_ref <- function(objs) Filter(function(o) {
#     xr <- is.null(o$xref) || o$xref %in% c(xref, "paper")
#     yr <- is.null(o$yref) || o$yref %in% c(yref, "paper")
#     xr && yr
#   }, objs)

#   if (!is.null(la$shapes))      x$layout$shapes      <- keep_by_ref(la$shapes)
#   if (!is.null(la$annotations)) x$layout$annotations <- keep_by_ref(la$annotations)
#   if (!is.null(la$images))      x$layout$images      <- keep_by_ref(la$images)

#   # clear subplot residue/flag
#   x$layout$grid <- NULL
#   x$layout$subplot <- NULL
#   x$subplot <- NULL

#   plotly::as_widget(x)
# }

extract_subplot <- function(p, panel = 1) {
  if (!isTRUE(p$x$subplot)) return(p)
  b <- plotly::plotly_build(p)

  xref <- paste0("x", if (panel > 1) panel else "")
  yref <- paste0("y", if (panel > 1) panel else "")

  # keep traces for the requested axis pair and reset axis refs to defaults
  trs <- Filter(function(tr)
    (is.null(tr$xaxis) || tr$xaxis == xref) &&
    (is.null(tr$yaxis) || tr$yaxis == yref), b$x$data)
  trs <- lapply(trs, function(tr) { tr$xaxis <- NULL; tr$yaxis <- NULL; tr })

  # normalize axes to fill the canvas
  ax_x <- b$x$layout[[paste0("xaxis", if (panel > 1) panel else "")]]
  ax_y <- b$x$layout[[paste0("yaxis", if (panel > 1) panel else "")]]
  scrub <- c("domain","anchor","matches","overlaying","side","position",
             "scaleanchor","scaleratio","constrain","constraintoward")
  ax_x[scrub] <- NULL; ax_y[scrub] <- NULL
  ax_x$domain <- c(0,1); ax_y$domain <- c(0,1); ax_x$anchor <- "y"; ax_y$anchor <- "x"

  # create a fresh (unbuilt) figure and add cloned traces
  out <- plotly::plot_ly()
  out <- plotly::layout(out, xaxis = ax_x, yaxis = ax_y)
  for (tr in trs) out <- do.call(plotly::add_trace, c(list(out), tr))
  out
}

`%||%` <- function(a, b) if (is.null(a)) b else a

.panel_count <- function(p) {
  la <- p$x$layout
  ys <- grep("^yaxis(\\d+)?$", names(la), value = TRUE)
  if (!length(ys)) 1L else max(as.integer(sub("^yaxis$", "1", sub("^yaxis", "", ys))), na.rm = TRUE)
}

.stack_rows <- function(p, rows, heights = NULL, gap = 0.02, shareX = TRUE) {
  stopifnot(rows >= 1L)

  # default: top gets 0.7, rest split the remainder
  if (is.null(heights)) {
    heights <- if (rows == 1L) 1 else c(0.7, rep(0.3/(rows - 1L), rows - 1L))
  }
  heights <- as.numeric(heights)
  if (length(heights) != rows) heights <- rep(heights, length.out = rows)

  # normalize to available vertical space after gaps
  avail <- 1 - gap * (rows - 1L)
  h_topdown <- heights / sum(heights) * avail

  # convert to bottom-up order for stacking math
  h_bu <- rev(h_topdown)

  # bottom-up cumulative positions
  bottoms_bu <- c(0, cumsum(h_bu[-length(h_bu)] + gap))
  tops_bu    <- bottoms_bu + h_bu

  la <- p$x$layout
  key <- function(i) if (i > 1L) as.character(i) else ""

  for (i in seq_len(rows)) {
    j <- rows - i + 1L
    yk <- paste0("yaxis", key(i))
    xk <- paste0("xaxis", key(i))

    ya <- (la[[yk]] %||% list())
    xa <- (la[[xk]] %||% list())

    ya$domain <- c(bottoms_bu[j], tops_bu[j])
    ya$anchor <- paste0("x", key(i))
    xa$domain <- c(0, 1)
    xa$anchor <- paste0("y", key(i))
    if (shareX && i > 1L) xa$matches <- "x"

    la[[yk]] <- ya
    la[[xk]] <- xa
  }

  p$x$layout <- la
  p
}
