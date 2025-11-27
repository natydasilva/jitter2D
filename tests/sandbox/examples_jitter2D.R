# Examples of jittering2D
#
#
# Combine 3 parameters for describe jitter in 2D, each parameter has two posible levels.
#' @param  noise: Random or Quasirandom
#' @param dir: Global or Local
#' @param Voronoi: True or False (not implemented yet)
#' @param weight: spread factor (copied from ggplot2::geom_jitter, not used)
#' @param seed: simulation seed (copied from ggplot2::geom_jitter, not used)

compute_jitter2D <- function(
  data,
  noise = 'quasi',
  dir = 'global',
  weight = NULL,
  seed = NA
) {
  # weight <- weight  %||% (ggplot2::resolution(data$x, zero = FALSE, TRUE) * 0.4)
  weight = 1

  rho <- 0
  if (dir == 'local') {
    rho <- local_correlation(data)
  } else if (dir == 'global') {
    rho <- stats::cor(data$y, data$x) |> rep(nrow(data))
  }

  ns <- NULL
  if (noise == 'random') {
    ns <- matrix(rnorm(2 * nrow(data)), ncol = 2)
  } else if (noise == 'quasi') {
    ns <- sobol_seq_fn(data)
  }

  trans_x <- as.numeric(nrow(data))
  trans_y <- as.numeric(nrow(data))
  for (i in 1:nrow(data)) {
    S <- matrix(c(1, rho[i], rho[i], 1), ncol = 2) |> chol()
    ns <- S %*% ns[i, ] |> t()
  }

  trans_x <- weight * ns[, 2]
  trans_y <- weight * ns[, 1]

  # ggplot2::transform_position(data, function(x) x + trans_x, function(x) x + trans_y)
  data.frame(x = data$x + trans_x, data$y + trans_y)
}
# ==============================================

# ==============================================

library(tidyverse)
source('tests/sandbox/utils.R')

df <- gendt_bimodal(n = 500)
dfr <- df |> mutate(x = round(x), y = round(y))

ggplot() +
  geom_point(data = df, aes(x, y), size = .5) +
  geom_point(data = dfr, aes(x, y), color = 'chocolate')


df1 <- compute_jitter2D(dfr, noise = 'quasi', dir = 'local')
