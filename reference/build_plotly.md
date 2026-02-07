# build_plotly

A high-level builder for the -methods.

## Usage

``` r
build_plotly(init, traces, decorators = list(), name, data, title = NULL, ...)
```

## Arguments

- init:

  A -object to be built, or built upon.

- traces:

  A nested \<[list](https://rdrr.io/r/base/list.html)\> of arguments.

- decorators:

  A \<[list](https://rdrr.io/r/base/list.html)\> of functions that
  decorates the -objecty. Can be an empty
  \<[list](https://rdrr.io/r/base/list.html)\>.

- name:

  A \<[character](https://rdrr.io/r/base/character.html)\>-vector of
  [length](https://rdrr.io/r/base/length.html) 1. The name of the
  indicator; relevant mainly for univariate series.

- data:

  A \<[data.frame](https://rdrr.io/r/base/data.frame.html)\> with the
  calculated indicator.

- title:

  A \<[character](https://rdrr.io/r/base/character.html)\>-vector of
  [length](https://rdrr.io/r/base/length.html) 1. This adds a title to
  the subchart.

## Value

A -object
