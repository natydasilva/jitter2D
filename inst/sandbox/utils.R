# utils functions

# Epanechnikov kernel function
epanechnikov_kernel <- function(u) {
  # u is the scaled distance (distance / bandwidth)
  # Returns 0 for |u| > 1
  ifelse(abs(u) <= 1, 0.75 * (1 - u^2), 0)
}

gaussian_kernel <- function(u, v = 1) {
  exp(-u^2 / (2 * v))
}


# Weighted mean function
weighted_mean <- function(x, weights) {
  sum(weights * x) / sum(weights)
}

# Weighted correlation function
weighted_correlation <- function(x, y, weights) {
  # Compute weighted means
  x_mean <- weighted_mean(x, weights)
  y_mean <- weighted_mean(y, weights)

  # Centered values
  x_centered <- x - x_mean
  y_centered <- y - y_mean

  # Weighted covariance and variances
  cov_xy <- sum(weights * x_centered * y_centered)
  var_x <- sum(weights * x_centered^2)
  var_y <- sum(weights * y_centered^2)

  # Correlation coefficient
  r <- cov_xy / sqrt(var_x * var_y)

  return(r)
}

# Main function: Local correlation for each point
local_correlation <- function(data, bandwidth = .5, coords = NULL) {
  # data: data frame or matrix with two columns (x and y variables)
  # bandwidth: kernel bandwidth
  # coords: optional matrix of coordinates (n x 2). If NULL, uses data itself

  # Convert to matrix if data frame
  # if (is.data.frame(data)) {
  #   data <- as.matrix(data)
  # }

  x <- data$x
  y <- data$y
  n <- nrow(data)

  # If no coordinates provided, use the data itself as coordinates
  if (is.null(coords)) {
    coords <- as.matrix(data)
  } else if (is.data.frame(coords)) {
    coords <- as.matrix(coords)
  }

  # Initialize vector for local correlations
  local_cor <- numeric(n)

  # Compute local correlation for each point
  dds <- dist(data)
  bw <- quantile(dds, probs = bandwidth)
  dds <- as.matrix(dds)

  for (i in 1:n) {
    # Calculate distances from point i to all points
    distances <- dds[i, ]
    #distances <- sqrt(rowSums((coords - matrix(coords[i, ], n, 2, byrow = TRUE))^2))

    # Calculate weights using Epanechnikov kernel
    weights <- gaussian_kernel(distances / bandwidth)

    # Check if we have enough non-zero weights
    if (sum(weights > 0) < 3) {
      local_cor[i] <- 0
      #warning(paste("Point", i, "has fewer than 3 neighbors within bandwidth"))
    } else {
      # Compute weighted correlation
      local_cor[i] <- weighted_correlation(x, y, weights)
    }
  }

  return(local_cor)
}

# sobol sequence generation in each repeted point
sobol_seq_fn <- function(data) {
  data_over <- data |>
    dplyr::count(x, y, name = "point")

  sobol_seq <- purrr::map_dfr(data_over$point, function(n) {
    randtoolbox::sobol(n = n, dim = 2) |>
      as.data.frame()
  }) |>
    as.matrix()
}

# generates a 2-mixture dataset
gendt_bimodal <- function(n = 500) {
  # Create bivariate data with correlation structure
  n1 <- round(0.6 * n)
  n2 <- n - n1

  # First component (correlated)
  mean1 <- c(1, 1)
  sigma1 <- matrix(c(1, 0.8, 0.8, 1.5), 2, 2)
  data1 <- MASS::mvrnorm(n1, mean1, sigma1)

  # Second component (correlated)
  mean2 <- c(4, 4)
  sigma2 <- matrix(c(1.0, -0.8, -0.8, 1.5), 2, 2)
  data2 <- MASS::mvrnorm(n2, mean2, sigma2)

  data <- rbind(data1, data2)
  colnames(data) <- c("x", "y")
  return(as.data.frame(data))
}

gendt_dayles <- function(n = 1) {
  n <- nrow(dayles)
  colnames(dayles) <- c("x", "y")
  dayles[1:n, ]
}

gendt_nonlinear <- function(n = 500) {
  x <- runif(n, 0, 10)
  y <- sin(x) + rnorm(n, sd = 0.3)
  data <- data.frame(x = x, y = y)
  return(data)
}

gendt_mpg <- function(n = 1) {
  n <- nrow(mpg)
  dt <- mpg[1:n, c('cyl', 'hwy')]
  colnames(dt) <- c("x", "y")
  dt
}
