#----------------------------------------------------------#
#
#
#                        _brand
#
#         Generate theme/brand_theme.scss and
#         theme/fonts-include.html from the
#         canonical JSON files in quarto/.
#
#         Run this script whenever quarto/*.json changes,
#         then re-render with `quarto render`.
#
#                       O. Mottl
#                         2026
#
#----------------------------------------------------------#
# This repo IS the canonical source for the R theme
# generation functions. No download step is needed here —
# the functions are sourced directly from the local
# R/Functions/Theme_generation/ folder.

# Setup -----

library(here)
library(jsonlite)
library(purrr)

here::i_am("README.md")

# Source helper functions (local — this repo is the source) -----

message("Loading theme generation functions...\n")

c(
  "generate_skripta_html_theme.R",
  "generate_fonts_html.R"
) |>
  purrr::walk(
    .f = ~ source(here::here("R/Functions/Theme_generation", .x))
  )

message("All functions loaded.\n\n")

# Generate theme artefacts -----

message("Starting brand theme generation...\n\n")

tryCatch(
  expr = {
    # Generate brand_theme.scss from quarto/*.json
    # (uses generate_skripta_html_theme — same Bootstrap-compatible SCSS format)
    generate_skripta_html_theme(
      colors_file       = here::here("quarto/colors.json"),
      fonts_file        = here::here("quarto/fonts.json"),
      custom_theme_file = here::here("quarto/custom_theme.json"),
      output_file       = here::here("theme/brand_theme.scss")
    )

    # Generate fonts-include.html from quarto/fonts.json
    generate_fonts_html(
      fonts_file  = here::here("quarto/fonts.json"),
      output_file = here::here("theme/fonts-include.html")
    )

    message("\nBrand theme generation complete. Generated files:\n")
    message("  theme/brand_theme.scss\n")
    message("  theme/fonts-include.html\n")
  },
  error = function(e) {
    message("\nERROR: Brand theme generation failed!\n")
    message(paste("Error:", e$message, "\n"))
    stop(e)
  }
)
