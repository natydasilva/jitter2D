---
title: "Quasi-Random Sequences for Spatial Jittering"
author: "Conversation with Claude"
date: 2025-11-27
format: html
---

## Introduction

This document summarizes a conversation about quasi-random sequences (van der Corput, Halton, and Sobol) and their applications to spatial jittering, particularly when incorporating statistical properties of observed data.

# Van der Corput vs Sobol Sequences

Both van der Corput and Sobol sequences are **quasi-random (low-discrepancy) sequences** designed to cover space more uniformly than pseudo-random numbers.

## Van der Corput Sequence

The van der Corput sequence is one of the simplest and most fundamental low-discrepancy sequences. It works in **one dimension** using a clever construction:

1. Take a base (typically base 2)
2. Write the index n in that base
3. Reverse the digits and put them after a decimal point

**Example in base 2:**

- n=1 → binary 1 → reversed 1 → 0.1 (base 2) = 0.5
- n=2 → binary 10 → reversed 01 → 0.01 = 0.25
- n=3 → binary 11 → reversed 11 → 0.11 = 0.75
- n=4 → binary 100 → reversed 001 → 0.001 = 0.125

This creates a sequence that systematically fills [0,1] with very low discrepancy.

## Key Differences from Sobol

**Dimensionality**: Van der Corput is inherently 1D, while Sobol sequences are designed for multi-dimensional spaces. To extend van der Corput to multiple dimensions, you use different bases for each dimension (creating a **Halton sequence**).

**Construction**: Sobol sequences use more sophisticated mathematics involving primitive polynomials over finite fields and direction numbers, making them particularly well-suited for high-dimensional spaces.

**Performance**: For multi-dimensional applications, Sobol sequences generally have better uniformity properties than simple extensions of van der Corput, especially in higher dimensions.

# Halton vs Sobol for 2D Jittering

For 2D jittering, both Halton and Sobol are excellent choices and vastly outperform random jittering.

## Halton Sequences (bases 2,3) for 2D

- Simpler to implement
- Faster to compute
- Work well in low dimensions (2D-6D)
- Can develop correlation artifacts in higher dimensions (6+)
- Very good distribution properties in 2D specifically

## Sobol Sequences for 2D

- Better uniformity in multi-dimensional projections
- More consistent distribution properties
- Can show visible grid-like patterns at low sample counts
- Particularly robust when samples are transformed to other domains

## Academic Comparisons

Several key papers have compared these approaches:

1. **"Progressive Multi-Jittered Sample Sequences"** (Christensen et al., 2018, Pixar) - Found that both Halton and Owen-scrambled Sobol sequences converge at roughly O(N^-0.75) for various test functions.

2. **"Quasi-Monte Carlo Rendering with Adaptive Sampling"** (1996) - Found Halton generally produced the best quality images with 16 samples, with Sobol performing similarly but sometimes showing systematic artifacts.

3. **Physically Based Rendering** textbook (Pharr et al.) - Shows that for rendering depth of field, Halton had higher error (normalized MSE 1.44) compared to Sobol variants (MSE 0.64-0.96).

## Recommendation for 2D

Either will work great! Halton is slightly simpler and faster for 2D specifically. If extending to higher dimensions later or needing very robust behavior under transformations, Sobol might be the better long-term choice.

# Incorporating Data Correlations: Copulas + Quasi-Random Sequences

To incorporate statistical properties of observed data (such as correlations) into jittering, the established approach is to combine **copulas** with quasi-random sequences.

## What are Copulas?

Copulas are mathematical functions that allow you to:

1. Separate the marginal distributions (individual variable distributions) from the dependence structure (correlations)
2. Model complex correlation patterns between variables
3. Combine them with quasi-random sampling

## The Workflow

1. **Start with quasi-random sequences** (Halton/Sobol) to generate uniform [0,1] samples
2. **Apply a copula** (e.g., Gaussian copula with your observed correlation matrix) to induce the correlation structure
3. **Transform to your target distributions** using inverse CDFs

The process involves generating uniformly distributed data with desired correlations by simulating from a multivariate Gaussian with specific correlation structure, transforming marginals to uniform, then transforming those to whatever distribution you need.

## Key Research

**"Quasi-random numbers for copula models"** by Cambou, Hofert & Lemieux (2017) is the definitive paper on this topic. It addresses how sampling algorithms for copula models can be adapted for quasi-random numbers, showing that methods beyond the conditional distribution approach can improve upon classical Monte Carlo when using quasi-random generators.

The research demonstrates that quasi-random numbers for copula models can reduce standard deviations compared to pseudo-random numbers, and this holds for various sampling methods including the conditional distribution method and Marshall-Olkin representations.

## Practical Implementation

The R packages `copula` and `qrng` provide implementations of these methods, allowing you to use Halton or Sobol sequences with various copula families (Gaussian, t, Clayton, etc.).

## For 2D Jittering with Correlation

1. Estimate the correlation matrix from your observed 2D data
2. Use a Gaussian copula with that correlation structure
3. Feed Halton (bases 2,3) or Sobol sequences through the copula
4. This gives you uniformly-spaced jittering that respects your data's correlation structure

This approach provides the best of both worlds: efficient space-filling **and** respect for statistical dependencies in your data.

# References and Further Reading

## Key Papers

- Christensen, P., Kensler, A., & Kilpatrick, C. (2018). "Progressive Multi-Jittered Sample Sequences." *Computer Graphics Forum*, 37(4), 21-33. Pixar Animation Studios.

- Cambou, M., Hofert, M., & Lemieux, C. (2017). "Quasi-random numbers for copula models." *Statistics and Computing*, 27(5), 1307-1329. 
  - Paper link: https://link.springer.com/article/10.1007/s11222-016-9688-4

- Keller, A. (1996). "Quasi-Monte Carlo Methods in Computer Graphics: The Global Illumination Problem." *Lectures in Applied Mathematics*, 32, 455-469.

- Pharr, M., Jakob, W., & Humphreys, G. *Physically Based Rendering: From Theory to Implementation* (4th ed.). MIT Press.
  - Online version: https://pbr-book.org/

## Software Resources

- R package `copula`: https://cran.r-project.org/package=copula
- R package `qrng`: https://cran.r-project.org/package=qrng

## Additional Reading

For more information on quasi-random sequences in computer graphics and statistics:

- Owen, A. B. (2003). "Quasi-Monte Carlo Sampling." *Monte Carlo Ray Tracing: Siggraph* 2003 Course 44.
- Niederreiter, H. (1992). *Random Number Generation and Quasi-Monte Carlo Methods*. SIAM.
