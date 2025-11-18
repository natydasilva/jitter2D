#' Jittered 2D points based on Sobolev sequence
#'
#' The jitter geom is a convenient shortcut for
#' `geom_point(position = "jitterquasi")`. It adds a small amount of random
#' variation to the location of each point using bivariate normal distribution, and is a useful way of handling
#' overplotting caused by discreteness in smaller datasets.
#'
#' @section Aesthetics GeomPoint
#' @inheritParams ggplot2::layer
#' @inheritParams ggplot2::geom_point
#' @inheritParams position_jitter_quasi
#' @seealso
#'  [geom_point()] for regular, unjittered points,
#'  [geom_boxplot()] for another way of looking at the conditional
#'     distribution of a variable
#' @export
#' @examples
#' # plot categorical variables of mtcars
#' require("ggplot2")
#' data(mpg)
#' ggplot(mpg, aes(x=cty, y=hwy)) + geom_point()
#' ggplot(mpg, aes(x=cty, y=hwy)) + geom_jitter_quasi()
geom_jitter_quasi <- function(mapping = NULL, data = NULL,
                              stat = "identity", position = "jitterquasi",
                              ...,
                              weight = NULL,
                              na.rm = FALSE,
                              show.legend = NA,
                              inherit.aes = TRUE) {
  if (!missing(weight)) {
    if (!missing(position)) {
      cli::cli_abort(c(
        "Both {.arg position} and {.arg width} were supplied.",
        "i" = "Choose a single approach to alter the position."
      ))
    }

    position <- position_jitter_quasi(weight = weight)
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
