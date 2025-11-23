#' Jittered 2D points based on Sobol sequence (toggle local/global)
#'
#' The jitter geom is a convenient shortcut for
#' `geom_point(position = "jitterquasi")`. It adds a small amount of variation
#' to the location of each point using bivariate normal distribution derived from
#' Sobol sequences. This is useful for handling overplotting in smaller datasets.
#'
#' @section Aesthetics GeomPoint
#' @inheritParams ggplot2::layer
#' @inheritParams ggplot2::geom_point
#' @param loc Logical. If TRUE, generates points locally per (x,y) duplicate.
#'   If FALSE, generates a global Sobol sequence for all points.
#' @param weight Spread factor. If omitted, it is computed automatically.
#' @seealso
#'  [geom_point()] for regular, unjittered points,
#'  [geom_boxplot()] for another way of looking at the conditional distribution of a variable
#' @export
#' @examples
#' library(ggplot2)
#' data(mpg)
#' ggplot(mpg, aes(x = cty, y = hwy)) + geom_point()
#' ggplot(mpg, aes(x = cty, y = hwy)) + geom_jitter_quasi(loc = TRUE)
#' ggplot(mpg, aes(x = cty, y = hwy)) + geom_jitter_quasi(loc = FALSE)
geom_jitter_quasi <- function(
    mapping = NULL,
    data = NULL,
    stat = "identity",
    position = NULL,  # <- default NULL instead of "jitterquasi"
    ...,
    weight = NULL,
    na.rm = FALSE,
    show.legend = NA,
    inherit.aes = TRUE,
    loc = FALSE
) {

  if (is.null(position)) {
    position <- position_jitter_quasi(weight = weight, loc = loc)
  }

  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = ggplot2::GeomPoint,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = rlang::list2(
      na.rm = na.rm,
      ...
    )
  )
}

