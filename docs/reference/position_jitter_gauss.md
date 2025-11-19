# 2D Jitter points to avoid overplotting based on Gaussian bivariate distribution

2D Jitter points to avoid overplotting based on Gaussian bivariate
distribution

## Usage

``` r
position_jitter_gauss(weight = NULL, seed = NA)
```

## Arguments

- weight, :

  spread factor.

  If omitted, just include the spread in the data.

- seed:

  A random seed to make the jitter reproducible. Useful if you need to
  apply the same jitter twice, e.g., for a point and a corresponding
  label. The random seed is reset after jittering. If \`NA\` (the
  default value), the seed is initialised with a random value; this
  makes sure that two subsequent calls start with a different seed. Use
  \`NULL\` to use the current random seed and also avoid resetting (the
  behaviour of ggplot 2.2.1 and earlier).

## See also

Other position adjustments:
[`position_jitter_quasi()`](https://github.com/natydasilva/jitter2D/reference/position_jitter_quasi.md),
[`position_jitter_quasiloc()`](https://github.com/natydasilva/jitter2D/reference/position_jitter_quasiloc.md),
[`position_jitter_quasitog()`](https://github.com/natydasilva/jitter2D/reference/position_jitter_quasitog.md)

## Examples

``` r
ggplot2::mpg |> ggplot2::ggplot(ggplot2::aes(cty, hwy)) +
 geom_jitter_gauss() + ggplot2::theme(aspect.ratio = 1)
```
