# Plot hwy vs cyl from the web of geoom_jitter
# https://ggplot2.tidyverse.org/reference/geom_jitter.html

# 0) pkgs -------
library(ggplot2)
library(dplyr)
library(mvtnorm)
library(rngWELL)
library(randtoolbox)
library(rlang)

# 1) regular jitter ------------------
p <- ggplot(mpg, aes(cyl, hwy))
p + geom_jitter()

# jitter by hand
mpg |>
  mutate(hwy = hwy + runif( n(), -.5, .5) ) |>
  mutate( cyl = cyl + runif(n(), -.5, .5) ) |>
  ggplot() + geom_point( aes(cyl, hwy) ) +
  geom_jitter(data = mpg, aes(cyl, hwy), color = 'red', alpha = .3)


# 2) bivariate normal jitter --------------------
# instead or runif use mvnorm() for the noise
vv <- mpg |> select(hwy, cyl) |> var()

noise <- rmvnorm( nrow(mpg), sigma = vv )

mpg |>
  mutate(hwy = hwy + .3*noise[,1] ) |>
  mutate( cyl = cyl + .3*noise[,2]  ) |>
  ggplot( ) + geom_point( aes(cyl, hwy) ) +
  geom_jitter(data = mpg, aes(cyl, hwy), color = 'red', alpha = .3 )


mpg |>
  ggplot() +geom_jitter2D(aes(x= cyl, y =hwy))

#  model assisted  jitter ? ??
p + geom_point() + geom_smooth(method = 'lm')
mm <- lm(hwy ~ cyl, data = mpg)
mm

# 3 ) quasirandom bivariate normal jitter --------------------


# Generate 1000 points of a 2D Sobol sequence

n_points <- 1000
dimension <- 2

# Generate the Sobol sequence (uniform in [0,1])
sobol_seq <- sobol(n = n_points, dim = dimension)

# Transform uniform to standard normal using inverse normal CDF
normal_seq <- qnorm(sobol_seq)

# Define parameters for bivariate Gaussian
mu <- c(0, 0)           # mean vector
sigma <- matrix(c(4, 1.5,   # covariance matrix (creates ellipse shape)
                  1.5, 1),
                nrow = 2, byrow = TRUE)

# Transform to desired bivariate Gaussian distribution
# Using Cholesky decomposition
L <- chol(sigma)
gaussian_seq <- t(L %*% t(normal_seq)) + rep(mu, each = n_points)

# Plot comparison
par(mfrow = c(1, 2))

# Original uniform Sobol sequence
plot(sobol_seq[,1], sobol_seq[,2],
     xlab = "Dimension 1", ylab = "Dimension 2",
     main = "Uniform Sobol Sequence",
     pch = 16, cex = 0.5)

# Transformed bivariate Gaussian
plot(gaussian_seq[,1], gaussian_seq[,2],
     xlab = "X", ylab = "Y",
     main = "Bivariate Gaussian Sobol Sequence",
     pch = 16, cex = 0.5)

# Add confidence ellipses to show the Gaussian shape
library(car)
dataEllipse(gaussian_seq[,1], gaussian_seq[,2],
            levels = c(0.68, 0.95), plot.points = FALSE,
            add = TRUE, col = "red", lwd = 2)


