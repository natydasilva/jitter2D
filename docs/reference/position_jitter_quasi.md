# 2D Jitter points to avoid overplotting based on Sobolev sequence

2D Jitter points to avoid overplotting based on Sobolev sequence

## Usage

``` r
position_jitter_quasi(weight = NULL, seed = NA, loc = FALSE)
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

- loc:

  logical, if its TRUE it uses the Sobol sequence to generate points
  locally, and it is false generate a complete sobol sequence for all
  points.

## See also

Other position adjustments:
[`position_jitter_gauss()`](https://github.com/natydasilva/jitter2D/reference/position_jitter_gauss.md),
[`position_jitter_quasiloc()`](https://github.com/natydasilva/jitter2D/reference/position_jitter_quasiloc.md),
[`position_jitter_quasitog()`](https://github.com/natydasilva/jitter2D/reference/position_jitter_quasitog.md)

## Examples

``` r
ggplot2::mpg |> ggplot2::ggplot(ggplot2::aes(cty, hwy)) +
 geom_jitter_quasi() + ggplot2::theme(aspect.ratio = 1)

```
