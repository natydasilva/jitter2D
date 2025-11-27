# from claude
# Sobol Sampling from Empirical Distribution using Copulas
# Install required packages if needed:
# install.packages(c("randtoolbox", "copula", "ggplot2", "gridExtra"))

library(randtoolbox)
library(copula)
library(ggplot2)
library(gridExtra)

# Set seed for reproducibility
set.seed(123)

# ============================================================================
# 1. Generate synthetic dataset (mixture of Gaussians)
# ============================================================================
generate_dataset <- function(n = 500) {
  # Create bivariate data with correlation structure
  n1 <- round(0.6 * n)
  n2 <- n - n1

  # First component (correlated)
  mean1 <- c(2, 2)
  sigma1 <- matrix(c(1.5, 0.8, 0.8, 1.0), 2, 2)
  data1 <- MASS::mvrnorm(n1, mean1, sigma1)

  # Second component (correlated)
  mean2 <- c(6, 6)
  sigma2 <- matrix(c(1.0, -0.6, -0.6, 1.5), 2, 2)
  data2 <- MASS::mvrnorm(n2, mean2, sigma2)

  data <- rbind(data1, data2)
  colnames(data) <- c("X", "Y")
  return(as.data.frame(data))
}

# ============================================================================
# 2. Fit empirical copula to the data
# ============================================================================
fit_empirical_copula <- function(data) {
  # Convert data to pseudo-observations (ranks / (n+1))
  n <- nrow(data)
  u <- pobs(data)

  # Fit several copula types and choose the best
  # Try Gaussian, t, Clayton, Gumbel, Frank

  # Gaussian copula
  fit_normal <- fitCopula(normalCopula(dim = 2), u, method = "mpl")

  # t-copula
  fit_t <- fitCopula(tCopula(dim = 2), u, method = "mpl")

  # Clayton copula
  fit_clayton <- fitCopula(claytonCopula(dim = 2), u, method = "mpl")

  # Gumbel copula
  fit_gumbel <- fitCopula(gumbelCopula(dim = 2), u, method = "mpl")

  # Frank copula
  fit_frank <- fitCopula(frankCopula(dim = 2), u, method = "mpl")

  # Compare AIC
  aics <- c(
    Normal = AIC(fit_normal),
    t = AIC(fit_t),
    Clayton = AIC(fit_clayton),
    Gumbel = AIC(fit_gumbel),
    Frank = AIC(fit_frank)
  )

  cat("Copula AIC values:\n")
  print(aics)
  cat("\nBest copula:", names(which.min(aics)), "\n\n")

  # Return the best fit
  best_fit <- list(
    fit_normal,
    fit_t,
    fit_clayton,
    fit_gumbel,
    fit_frank
  )[[which.min(aics)]]

  return(list(
    fit = best_fit,
    copula_name = names(which.min(aics)),
    u = u
  ))
}

# ============================================================================
# 3. Generate Sobol samples through copula and empirical marginals
# ============================================================================
generate_sobol_copula_samples <- function(data, copula_fit, n_samples = 100) {
  # Generate Sobol sequence in [0,1]^2
  sobol_seq <- sobol(n = n_samples, dim = 2)

  # Transform through fitted copula to get correlated uniform samples
  # We need to use the copula's conditional sampling
  cop <- copula_fit$fit@copula

  # Use the copula to transform Sobol sequence
  # This preserves the low-discrepancy property while adding correlation
  u_correlated <- cCopula(sobol_seq, copula = cop, inverse = TRUE)

  # Transform through empirical marginals (inverse ECDF)
  x_samples <- quantile(data$X, probs = u_correlated[, 1], type = 1)
  y_samples <- quantile(data$Y, probs = u_correlated[, 2], type = 1)

  return(data.frame(X = x_samples, Y = y_samples))
}

# ============================================================================
# 4. Generate random samples for comparison (also using copula)
# ============================================================================
generate_random_copula_samples <- function(data, copula_fit, n_samples = 100) {
  # Generate random uniform samples
  cop <- copula_fit@copula
  u_random <- rCopula(n_samples, cop)

  # Transform through empirical marginals
  x_samples <- quantile(data$X, probs = u_random[, 1], type = 1)
  y_samples <- quantile(data$Y, probs = u_random[, 2], type = 1)

  return(data.frame(X = x_samples, Y = y_samples))
}

# ============================================================================
# 5. Generate naive samples (independent marginals, no copula)
# ============================================================================
generate_sobol_independent <- function(data, n_samples = 100) {
  sobol_seq <- sobol(n = n_samples, dim = 2)

  x_samples <- quantile(data$X, probs = sobol_seq[, 1], type = 1)
  y_samples <- quantile(data$Y, probs = sobol_seq[, 2], type = 1)

  return(data.frame(X = x_samples, Y = y_samples))
}

# ============================================================================
# 6. Visualization
# ============================================================================
create_plots <- function(
  data,
  sobol_copula,
  random_copula,
  sobol_indep,
  n_samples
) {
  # Original data
  p1 <- ggplot(data, aes(x = X, y = Y)) +
    geom_point(alpha = 0.4, color = "steelblue", size = 1.5) +
    ggtitle(paste("Original Data (n =", nrow(data), ")")) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))

  # Sobol + Copula
  p2 <- ggplot(sobol_copula, aes(x = X, y = Y)) +
    geom_point(color = "#2ecc71", size = 2) +
    ggtitle(paste("Sobol + Copula (n =", n_samples, ")")) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))

  # Random + Copula
  p3 <- ggplot(random_copula, aes(x = X, y = Y)) +
    geom_point(color = "#e74c3c", size = 2) +
    ggtitle(paste("Random + Copula (n =", n_samples, ")")) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))

  # Sobol Independent (no copula)
  p4 <- ggplot(sobol_indep, aes(x = X, y = Y)) +
    geom_point(color = "#f39c12", size = 2) +
    ggtitle(paste("Sobol Independent (n =", n_samples, ")")) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))

  # Overlay comparison
  overlay_data <- rbind(
    cbind(sobol_copula, Method = "Sobol+Copula"),
    cbind(random_copula, Method = "Random+Copula")
  )

  p5 <- ggplot(overlay_data, aes(x = X, y = Y, color = Method)) +
    geom_point(size = 2, alpha = 0.6) +
    scale_color_manual(
      values = c("Sobol+Copula" = "#2ecc71", "Random+Copula" = "#e74c3c")
    ) +
    ggtitle("Overlay: Sobol vs Random (both with Copula)") +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold"),
      legend.position = "bottom"
    )

  # Arrange plots
  grid.arrange(
    p1,
    p2,
    p3,
    p4,
    p5,
    ncol = 2,
    top = "Sobol Sampling with Copulas vs Alternatives"
  )
}

# ============================================================================
# 7. Calculate discrepancy measures
# ============================================================================
calculate_discrepancy <- function(samples, data) {
  # Simple measure: average minimum distance to original data points
  dists <- numeric(nrow(samples))
  for (i in 1:nrow(samples)) {
    dists[i] <- min(sqrt((data$X - samples$X[i])^2 + (data$Y - samples$Y[i])^2))
  }
  return(mean(dists))
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

cat("========================================\n")
cat("Sobol Sampling with Copulas\n")
cat("========================================\n\n")

# Generate dataset
cat("1. Generating synthetic dataset...\n")
data <- generate_dataset(n = 500)
cat("   Dataset generated with", nrow(data), "points\n")
cat("   Correlation:", cor(data$X, data$Y), "\n\n")

# Fit copula
cat("2. Fitting copula to data...\n")
copula_fit <- fit_empirical_copula(data)

# Generate samples
n_samples <- 100
cat("3. Generating", n_samples, "samples...\n")
sobol_copula <- generate_sobol_copula_samples(data, copula_fit, n_samples)
random_copula <- generate_random_copula_samples(data, copula_fit$fit, n_samples)
sobol_indep <- generate_sobol_independent(data, n_samples)

cat("   Samples generated\n\n")

# Calculate correlations
cat("4. Comparing correlations:\n")
cat("   Original data:       ", round(cor(data$X, data$Y), 3), "\n")
cat(
  "   Sobol + Copula:      ",
  round(cor(sobol_copula$X, sobol_copula$Y), 3),
  "\n"
)
cat(
  "   Random + Copula:     ",
  round(cor(random_copula$X, random_copula$Y), 3),
  "\n"
)
cat(
  "   Sobol Independent:   ",
  round(cor(sobol_indep$X, sobol_indep$Y), 3),
  "\n\n"
)

# Calculate discrepancy
cat("5. Average minimum distance to original data:\n")
cat(
  "   Sobol + Copula:      ",
  round(calculate_discrepancy(sobol_copula, data), 3),
  "\n"
)
cat(
  "   Random + Copula:     ",
  round(calculate_discrepancy(random_copula, data), 3),
  "\n"
)
cat(
  "   Sobol Independent:   ",
  round(calculate_discrepancy(sobol_indep, data), 3),
  "\n\n"
)

# Create visualizations
cat("6. Creating visualizations...\n")
create_plots(data, sobol_copula, random_copula, sobol_indep, n_samples)

cat("\nDone!\n")

# ============================================================================
# Optional: Save samples for further analysis
# ============================================================================
# write.csv(sobol_copula, "sobol_copula_samples.csv", row.names = FALSE)

# ============================================================================
# Optional: Apply to your own data
# ============================================================================
# To use with your own data:
# my_data <- read.csv("your_data.csv")
# copula_fit <- fit_empirical_copula(my_data)
# samples <- generate_sobol_copula_samples(my_data, copula_fit$fit, n_samples = 200)
