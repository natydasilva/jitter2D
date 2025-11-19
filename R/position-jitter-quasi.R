#' 2D Jitter points to avoid overplotting based on Sobolev sequence
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
#' @param loc logical, if its TRUE it uses the Sobol sequence to generate points locally, and it is false generate a complete sobol sequence for all points.
#' @export
position_jitter_quasi <- function(weight = NULL,  seed = NA) {
  ggplot2::ggproto(NULL, PositionJitterquasi,
                   weight = weight,
                   seed = seed
  )
}

#' @rdname position_jitter_quasi
#' @format NULL
#' @usage NULL
#' @export
#' @examples
#' ggplot2::mpg |> ggplot2::ggplot(ggplot2::aes(cty, hwy)) +
#'  geom_jitter_quasi() + ggplot2::theme(aspect.ratio = 1)
#'
PositionJitterquasi <- ggplot2::ggproto("PositionJitterquasi",  ggplot2:::Position,
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
                                          compute_jitter_quasi(data, params$weight, seed = params$seed, loc = params$loc)
                                        }
)


compute_jitter_quasi <- function(data, weight = NULL, seed = NA, loc = loc ) {

  weight <- weight  %||% (ggplot2::resolution(data$x, zero = FALSE, TRUE) * 0.4)

  if(loc){
  # Generate the Sobol sequence (uniform in [0,1])
    data_over <- data |> dplyr::group_by(data$x, data$y) |>
      dplyr::summarise(point = dplyr::n())

    sobol_aux<- function(x){
      randtoolbox::sobol(n = x[3], dim = 2) |> data.frame()
    }
    sobol_seq <- apply(data_over,1, sobol_aux ) |>
      dplyr::bind_rows() |> as.matrix()
  }else{

    sobol_seq <- randtoolbox::sobol(n = nrow(data), dim = 2)

  }

  # Transform uniform to standard normal using inverse normal CDF
  normal_seq <- stats::qnorm(sobol_seq)

  # Define parameters for bivariate Gaussian
  vv <- cbind(data$y, data$x)  |> as.matrix() |> stats::var(na.rm = TRUE)

  # Transform to desired bivariate Gaussian distribution
  # Using Cholesky decomposition
  L <- chol(vv)
  #gaussian seq
  noise <- t(L %*% t(normal_seq)) + rep(c(0, 0), each = nrow(data) )


  trans_x <- weight*noise[ , 2]
  trans_y <- weight*noise[ , 1]


  ggplot2::transform_position(data, function(x) x + trans_x, function(x) x + trans_y)


  }


