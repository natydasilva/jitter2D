#' 2D Jitter points to avoid overplotting
#'
#'
#' @family position adjustments
#' @param weight, Amount of vertical and horizontal jitter. The jitter
#'   is added in both positive and negative directions, so the total spread
#'   is twice the value specified here.
#'
#'   If omitted, defaults to 40% of the resolution of the data: this means the
#'   jitter values will occupy 80% of the implied bins. Categorical data
#'   is aligned on the integers, so a width or height of 0.5 will spread the
#'   data so it's not possible to see the distinction between the categories.
#' @param seed A random seed to make the jitter reproducible.
#'   Useful if you need to apply the same jitter twice, e.g., for a point and
#'   a corresponding label.
#'   The random seed is reset after jittering.
#'   If `NA` (the default value), the seed is initialised with a random value;
#'   this makes sure that two subsequent calls start with a different seed.
#'   Use `NULL` to use the current random seed and also avoid resetting
#'   (the behaviour of \pkg{ggplot} 2.2.1 and earlier).
#' @export
position_jitter2D <- function(weight = NULL,  seed = NA) {
          ggproto(NULL, PositionJitter2D,
          weight = weight,
          seed = seed
  )
}

#' @rdname Position
#' @format NULL
#' @usage NULL
#' @export
PositionJitter2D <- ggproto("PositionJitter2D",  ggplot2:::Position,
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
                            compute_jitter2D(data, params$weight, seed = params$seed)
                          }
)


compute_jitter2D <- function(data, weight= NULL, seed = NA) {

   weight <- weight  %||% (resolution(data$x, zero = FALSE, TRUE) * 0.4)

   vv <- cbind(data$y, data$x) |> as.matrix() |> var(na.rm = TRUE)

   noise <-   mvtnorm::rmvnorm( nrow(data), sigma = vv )

   trans_x <- weight*noise[ , 2]
   trans_y <- weight*noise[ , 1]


  transform_position(data, function(x) x + trans_x, function(x) x + trans_y)
}
