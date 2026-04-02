#----------------------------------------------------------#
#
#
#                         _brand
#
#         Canonical Theme Generation Script — _internal
#         Downloads pre-compiled HTML brand assets, JSON
#         config, and the Typst theme generator from
#         _brand (GitHub raw), caches them locally, then
#         generates the Typst theme file used by Quarto
#         PDF output inside the _internal repo.
#
#         This is the single source of truth for _internal.
#         The repo bootstraps this script at render time.
#
#
#                       O. Mottl
#                         2026
#
#----------------------------------------------------------#
# The bootstrapper in _internal/R/generate_theme.R downloads
# this file and sources it. On failure it falls back to the
# local R/cache/generate_theme_canonical.R.

# Setup -----

library(here)
library(jsonlite)

dir.create(here::here("theme"), recursive = TRUE, showWarnings = FALSE)
dir.create(
  here::here("R", "Functions", "Theme_generation"),
  recursive = TRUE,
  showWarnings = FALSE
)

# Helper: download one file, fall back to cache on error -----

download_asset <- function(base_url, filename, dest_dir) {
  url_src <-
    paste0(base_url, "/", filename)
  path_dest <-
    file.path(dest_dir, filename)
  tryCatch(
    expr = {
      download.file(url_src, path_dest, quiet = TRUE, mode = "wb")
      message("  Downloaded: ", filename)
    },
    error = function(e) {
      message(
        "  WARNING: Could not download ", filename,
        " \u2014 using cached copy.\n",
        "  (", e$message, ")"
      )
    }
  )
}

# Download pre-compiled HTML theme assets -----

message("Downloading HTML theme assets from _brand...\n")

brand_theme_url <-
  "https://raw.githubusercontent.com/CUNI-NATUR-Biostatistics/_brand/main/theme"

for (f in c("brand_theme.scss", "fonts-include.html")) {
  download_asset(brand_theme_url, f, here::here("theme"))
}

# Download brand JSON config files (needed to generate Typst theme) -----

message("\nDownloading brand JSON config from _brand...\n")

brand_json_url <-
  "https://raw.githubusercontent.com/CUNI-NATUR-Biostatistics/_brand/main/quarto"

for (f in c("colors.json", "fonts.json")) {
  download_asset(brand_json_url, f, here::here("theme"))
}

# Download Typst theme generator function from _brand -----

message("\nDownloading Typst theme generator from _brand...\n")

brand_functions_url <-
  "https://raw.githubusercontent.com/CUNI-NATUR-Biostatistics/_brand/main/R/Functions/Theme_generation"

download_asset(
  brand_functions_url,
  "generate_skripta_typst_theme.R",
  here::here("R", "Functions", "Theme_generation")
)

# Generate Typst theme file -----

message("\nGenerating Typst theme...\n")

source(
  here::here("R", "Functions", "Theme_generation", "generate_skripta_typst_theme.R")
)

generate_skripta_typst_theme(
  colors_file = here::here("theme", "colors.json"),
  fonts_file = here::here("theme", "fonts.json"),
  output_file = here::here("obecne", "nove", "pruvodce_theme.typ")
)

message("\nTheme assets ready.\n")
