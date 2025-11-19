# Examples and attemps

library(ggplot2)

devtools::load_all() # load jitter2d functions

library(ggplot2)
data(mpg)

p <- mpg |> ggplot(aes(x = cty, y = hwy))

p0 <- p + geom_point() + theme(aspect.ratio = 1) + labs(title = 'Original')


p2 <- p +
  geom_jitter_gauss() +
  theme(aspect.ratio = 1) +
  labs(title = 'gaussian')

p1 <- p + geom_jitter() + theme(aspect.ratio = 1) + labs(title = 'jitter')

p3 <- p +
  geom_jitter_quasi(loc = FALSE) +
  theme(aspect.ratio = 1) +
  labs(title = 'quasi')

p4 <- p +
  geom_jitter_quasiloc() +
  theme(aspect.ratio = 1) +
  labs(title = 'quasiloc')

library(patchwork)

p3 + p4

(p0 + p1) / (p2 + p3)
#===================================================

data <- mpg[, c('cty', 'hwy')]

# Load required packages
library(randtoolbox)
library(rngWELL)

# Generate the Sobol sequence (uniform in [0,1])
sobol_seq <- sobol(n = nrow(data), dim = 2)

# Transform uniform to standard normal using inverse normal CDF
normal_seq <- qnorm(sobol_seq)

# Define parameters for bivariate Gaussian
vv <- data |> as.matrix() |> stats::var(na.rm = TRUE)

# Transform to desired bivariate Gaussian distribution
# Using Cholesky decomposition
L <- chol(vv)
gaussian_seq <- t(L %*% t(normal_seq)) + rep(c(0, 0), each = nrow(data))

library(dplyr)
p3 <- mpg |>
  mutate(cty = cty + gaussian_seq[, 1], hwy = hwy + gaussian_seq[, 2]) |>
  ggplot(aes(x = cty, y = hwy)) +
  geom_point() +
  theme(aspect.ratio = 1) +
  labs(title = 'quasi')


library(patchwork)
p1 + p2 + p3

#===================================================
data <- mpg[, c('cty', 'hwy')]
library(dplyr)

# Load required packages
library(randtoolbox)
library(rngWELL)
library(dplyr)
# Generate the Sobol sequence (uniform in [0,1])
sobol_seq <- sobol(n = nrow(data), dim = 2)

mpg |> ggplot(aes(x = cty, y = hwy)) + geom_point()

data_ovrplt <- data |>
  group_by(cty, hwy) |>
  summarise(points = n())

sb_fun <- function(x) {
  sobol(n = x[3], dim = 2)
}

apply(data_ovrplt, 1, sb_fun)


data_ovrplt |>
  reframe()


data.frame(x = letters[1:4], y = 100:103, w = c(3, 4, 2, 1))


data <- mpg

names(data)[8] <- "x"

names(data)[9] <- "y"

data_over <- data |>
  dplyr::group_by(data$x, data$y) |>
  dplyr::summarise(point = dplyr::n())

sobol_aux <- function(x) {
  randtoolbox::sobol(n = x[3], dim = 2) |> data.frame()
}
sobol_seq <- apply(data_over, 1, sobol_aux) |>
  dplyr::bind_rows()

# =========================================================
# =========================================================

library(tidyverse)

data <- data.frame(x = rep(1:10, times = c(rep(1, 5), rep(4, 5)))) |>
  mutate(y = x + c(1:5, rep(-1, 10), rep(1, 10)))

ggplot(data, aes(x, y)) + geom_point()

ggplot(data, aes(x, y)) +
  geom_point(color = 'red', size = .5) +
  geom_jitter_quasiloc() +
  scale_x_continuous(breaks = 1:10)

var(data)

# Generate the Sobol sequence (uniform in [0,1])
data_over <- data |>
  dplyr::group_by(data$x, data$y) |>
  dplyr::summarise(point = dplyr::n())

sobol_aux <- function(x) {
  randtoolbox::sobol(n = x[3], dim = 2) |> data.frame()
}

sobol_seq <- apply(data_over, 1, sobol_aux) |>
  dplyr::bind_rows() |>
  as.matrix()

# Transform uniform to standard normal using inverse normal CDF
normal_seq <- stats::qnorm(sobol_seq)

# Define parameters for bivariate Gaussian
vv <- cbind(data$y, data$x) |> as.matrix() |> stats::var(na.rm = TRUE)

# Transform to desired bivariate Gaussian distribution
# Using Cholesky decomposition
L <- chol(vv)
#gaussian seq
noise <- t(L %*% t(normal_seq)) + rep(c(0, 0), each = nrow(data))

weight <- 1
trans_x <- weight * noise[, 2]
trans_y <- weight * noise[, 1]

ggplot(data) +
  geom_jitter_quasiloc(aes(x + trans_x, y + trans_y)) +
  geom_point(aes(x, y), color = 'red', size = .5) +
  scale_x_continuous(breaks = 1:10)
