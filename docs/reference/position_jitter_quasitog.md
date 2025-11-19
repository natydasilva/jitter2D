# 2D Jitter points to avoid overplotting based on Sobol sequence (toggle local/global)

2D Jitter points to avoid overplotting based on Sobol sequence (toggle
local/global)

## Usage

``` r
position_jitter_quasitog(weight = NULL, seed = NA, loc = FALSE)
```

## Arguments

- weight:

  Spread factor. If omitted, it is automatically set from the data.

- seed:

  Random seed for reproducibility.

- loc:

  Logical. If TRUE, generates points locally per (x,y) duplicate. If
  FALSE, generates a global Sobol sequence for all points.

## See also

Other position adjustments:
[`position_jitter_gauss()`](https://github.com/natydasilva/jitter2D/reference/position_jitter_gauss.md),
[`position_jitter_quasi()`](https://github.com/natydasilva/jitter2D/reference/position_jitter_quasi.md),
[`position_jitter_quasiloc()`](https://github.com/natydasilva/jitter2D/reference/position_jitter_quasiloc.md)
