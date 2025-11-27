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
    ns[i, ] <- S %*% ns[i, ] |> t()
  }

  trans_x <- weight * ns[, 2]
  trans_y <- weight * ns[, 1]

  # ggplot2::transform_position(data, function(x) x + trans_x, function(x) x + trans_y)
  data.frame(x = data$x + trans_x, y = data$y + trans_y)
}
# ==============================================

# ==============================================

library(tidyverse)
library(patchwork)
source('tests/sandbox/utils.R')

df <- gendt_bimodal(n = 500)
dfr <- df |> mutate(x = round(x), y = round(y))

pp <- vector(mode = 'list', length = 6)
base <- ggplot(mapping = aes(x, y)) +
  theme_bw() +
  theme(aspect.ratio = 1) +
  labs(x = '', y = '')

pp[[1]] <- base + geom_point(data = df) + ggtitle('Original data')
pp[[2]] <- base + geom_point(data = dfr) + ggtitle('Input data')

pr <- expand.grid(n = c('random', 'quasi'), d = c('local', 'global'))

for (p in 1:4) {
  df1 <- compute_jitter2D(dfr, noise = pr$n[p], dir = pr$d[p])
  titu <- paste0('noise: ', pr$n[p], '--', 'dir: ', pr$d[p])
  pp[[p + 2]] <- base + geom_point(data = df1) + ggtitle(titu)
}

(pp[[2]] + pp[[3]] + pp[[5]]) / (pp[[1]] + pp[[4]] + pp[[6]])
