library(hexSticker)
library(png)

# Option 1: Using an external image directly
sticker(
  subplot = here::here("hexsticker/jitter2D.jpeg"),  # path to your image
  package = "jitter2D",
  p_size = 18,
  p_color = "#d95f02",
  s_x = 1, s_y = 0.8,      # adjust position
  s_width = 0.73, s_height = 0.73, # scale
  h_fill = "#FFFFFF",
  h_color = "#d95f02",
  filename = here::here("man/figures/logo.png")
)
