# Examples and attemps

library(ggplot2)

devtools::load_all() # load jitter2d functions

library(ggplot2)
data(mpg)

p <- mpg |> ggplot(aes(x = cty, y = hwy))

p0 <- p + geom_point() + theme(aspect.ratio = 1) + labs(title = 'Original')

p + geom_jitter2D(weight = .05)

p2 <- p +
  geom_jitter_gauss() +
  theme(aspect.ratio = 1) +
  labs(title = 'gaussian')

p1 <- p + geom_jitter() + theme(aspect.ratio = 1) + labs(title = 'jitter')

p3 <- p + geom_jitter_quasi() + theme(aspect.ratio = 1) + labs(title = 'quasi')


library(patchwork)
(p0 + p1) / (p2 + p3) # ojaldre
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
