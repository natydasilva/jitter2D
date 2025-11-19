#' 2D Jitter points to avoid overplotting based on Sobol sequence (toggle local/global)
#'
#' @family position adjustments
#' @param weight Spread factor.
#'   If omitted, it is automatically set from the data.
#' @param seed Random seed for reproducibility.
#' @param loc Logical. If TRUE, generates points locally per (x,y) duplicate.
#'   If FALSE, generates a global Sobol sequence for all points.
#' @export
position_jitter_quasitog <- function(weight = NULL, seed = NA, loc = FALSE) {
  ggplot2::ggproto(
    NULL, PositionJitterQuasitog,
    weight = weight,
    seed = seed,
    loc = loc
  )
}

PositionJitterQuasitog <- ggplot2::ggproto(
  "PositionJitterQuasitog",
  ggplot2:::Position,
  seed = NA,
  loc = FALSE,
  required_aes = c("x", "y"),

  setup_params = function(self, data) {
    if (!is.null(self$seed) && is.na(self$seed)) {
      seed <- sample.int(.Machine$integer.max, 1L)
    } else {
      seed <- self$seed
    }

    list(
      weight = self$weight,
      seed = seed,
      loc = self$loc
    )
  },

  compute_panel = function(self, data, params, scales) {
    compute_jitter_quasitog(data, weight = params$weight, seed = params$seed, loc = params$loc)
  }
)

compute_jitter_quasitog <- function(data, weight = NULL, seed = NA, loc = TRUE) {

  weight <- weight %||% (ggplot2::resolution(data$x, zero = FALSE, TRUE) * 0.4)

  if (isTRUE(loc)) {
    # Local Sobol: generate sequence per (x,y) duplicate
    data_over <- data |>
      dplyr::count(x, y, name = "point")

    sobol_seq <- purrr::map_dfr(data_over$point, function(n) {
      randtoolbox::sobol(n = n, dim = 2) |> as.data.frame()
    }) |>
      as.matrix()

  } else {
    # Global Sobol
    sobol_seq <- randtoolbox::sobol(n = nrow(data), dim = 2)
  }

  # Transform uniform to standard normal
  normal_seq <- stats::qnorm(sobol_seq)

  # Bivariate Gaussian transformation
  vv <- stats::var(cbind(data$y, data$x), na.rm = TRUE)
  L <- chol(vv)
  noise <- t(L %*% t(normal_seq))

  trans_x <- weight * noise[, 2]
  trans_y <- weight * noise[, 1]

  ggplot2::transform_position(data,
                              function(x) x + trans_x,
                              function(y) y + trans_y)
}
