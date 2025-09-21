#' 2D Jitter points to avoid overplotting
#'
#'
#' @family position adjustments
#' @param width,height Amount of vertical and horizontal jitter. The jitter
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
position_jitter2D <- function(width = NULL, height = NULL, seed = NA) {
  ggproto(NULL, PositionJitter2D,
          width = width,
          height = height,
          seed = seed
  )
}

#' @rdname Position
#' @format NULL
#' @usage NULL
#' @export
PositionJitter2D <- ggproto("PositionJitter2D", Position,
                          seed = NA,
                          required_aes = c("x", "y"),

                          setup_params = function(self, data) {
                            if (!is.null(self$seed) && is.na(self$seed)) {
                              seed <- sample.int(.Machine$integer.max, 1L)
                            } else {
                              seed <- self$seed
                            }
                            list(
                              width = self$width,
                              height = self$height,
                              seed = seed
                            )
                          },

                          compute_panel = function(self, data, params, scales) {
                            compute_jitter2D(data, params$width, params$height, seed = params$seed)
                          }
)

compute_jitter2D <- function(data, width = NULL, height = NULL, seed = NA) {

   width  <- width  %||% (resolution(data$x, zero = FALSE, TRUE) * 0.4)
   height <- height %||% (resolution(data$y, zero = FALSE, TRUE) * 0.4)

   vv <- var(data$y, data$x)

   noise <- rmvnorm( nrow(data), sigma = vv )
  # trans_x <- if (width > 0)  function(x) jitter(x, amount = width)
  # trans_y <- if (height > 0) function(x) jitter(x, amount = height)
   trans_x <- noise[ , 2]
   trans_y <- noise[ , 1]

   x_aes <- intersect(ggplot_global$x_aes, names(data))
  # x <- if (length(x_aes) == 0) 0 else data[[x_aes[1]]]
  #
   y_aes <- intersect(ggplot_global$y_aes, names(data))
  # y <- if (length(y_aes) == 0) 0 else data[[y_aes[1]]]

  # jitter <- data_frame0(x = x, y = y, .size = nrow(data))
  # jitter <- with_seed_null(seed, transform_position(jitter, trans_x, trans_y))

  # x_jit <- jitter$x - x
  # x_jit[is.infinite(x)] <- 0
  #
  # y_jit <- jitter$y - y
  # y_jit[is.infinite(y)] <- 0

  transform_position(data, function(x) x + trans_x, function(x) x + trans_y)
}
