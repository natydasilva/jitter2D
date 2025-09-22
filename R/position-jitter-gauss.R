#' 2D Jitter points to avoid overplotting based on Gaussian bivariate distribution
#'
#'
#' @family position adjustments
#' @param weight, spread factor.
#'
#'   If omitted, just include the spread in the data.
#' @param seed A random seed to make the jitter reproducible.
#'   Useful if you need to apply the same jitter twice, e.g., for a point and
#'   a corresponding label.
#'   The random seed is reset after jittering.
#'   If `NA` (the default value), the seed is initialised with a random value;
#'   this makes sure that two subsequent calls start with a different seed.
#'   Use `NULL` to use the current random seed and also avoid resetting
#'   (the behaviour of \pkg{ggplot} 2.2.1 and earlier).
#' @export
position_jitter_gauss <- function(weight = NULL,  seed = NA) {
          ggplot2::ggproto(NULL, PositionJittergauss,
          weight = weight,
          seed = seed
  )
}

#' @rdname position_jitter_gauss
#' @format NULL
#' @usage NULL
#' @export
PositionJittergauss <- ggplot2::ggproto("PositionJittergauss",  ggplot2:::Position,
                          seed = NA,
                          required_aes = c("x", "y"),

                          setup_params = function(self, data) {
                            if (!is.null(self$seed) && is.na(self$seed)) {
                              seed <- sample.int(.Machine$integer.max, 1L)
                            } else {
                              seed <- self$seed
                            }
                            list(
                              weight = self$weight,
                              seed = seed
                            )
                          },

                          compute_panel = function(self, data, params, scales) {
                            compute_jitter_gauss(data, params$weight, seed = params$seed)
                          }
)


compute_jitter_gauss <- function(data, weight= NULL, seed = NA) {

   weight <- weight  %||% (ggplot2::resolution(data$x, zero = FALSE, TRUE) * 0.4)

   vv <- cbind(data$y, data$x) |> as.matrix() |> stats::var(na.rm = TRUE)

   noise <-   mvtnorm::rmvnorm( nrow(data), sigma = vv )

   trans_x <- weight*noise[ , 2]
   trans_y <- weight*noise[ , 1]


  ggplot2::transform_position(data, function(x) x + trans_x, function(x) x + trans_y)
}
