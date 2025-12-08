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
    ns <- matrix(rnorm(2 * nrow(data), sd = 1 / 3), ncol = 2)
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
library(stringr)
source('tests/sandbox/utils.R')
devtools::load_all()

exapmle_fn <- function(genff, nn) {
  df <- genff(n = nn)
  dfr <- df |> mutate(x = round(x), y = round(y))
  pp <- vector(mode = 'list', length = 6)

  pp[[1]] <- df
  pp[[2]] <- dfr
  pr <- expand.grid(n = c('random', 'quasi'), d = c('local', 'global'))
  for (p in 1:4) {
    pp[[p + 2]] <- compute_jitter2D(dfr, noise = pr$n[p], dir = pr$d[p])
  }

  pr_nm <- pr |>
    mutate(
      p = c(2, 3, 5, 6),
      n = str_sub(n, 1, 1) |> toupper(),
      d = str_sub(d, 1, 1) |> toupper()
    ) |>
    unite('ll', n, d, sep = '-') |>
    unite('ll', p, ll, sep = ':') |>
    pull(ll)

  names(pp) <- c('1:Original', '4:Rounded', pr_nm)
  dd <- bind_rows(pp, .id = 'type')

  ggplot(dd, mapping = aes(x, y)) +
    geom_point() +
    facet_wrap(~type) +
    theme_bw() +
    theme(aspect.ratio = 1, axis.text = element_blank()) +
    labs(x = '', y = '')
}


exapmle_fn(genff = gendt_dayles, nn = 100)

exapmle_fn(genff = gendt_bimodal, nn = 50)

exapmle_fn(genff = gendt_nonlinear, nn = 50)

exapmle_fn(genff = gendt_mpg, nn = 50)
