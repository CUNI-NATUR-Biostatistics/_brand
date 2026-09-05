#----------------------------------------------------------#
#
#
#                         _brand
#
#                  Render presentation
#
#
#                       O. Mottl
#                         2026
#
#----------------------------------------------------------#

library(here)
library(quarto)
library(fs)

if (!isTRUE(getOption("biostat.theme_sync_complete"))) {
  source(here::here("R", "generate_theme.R"))
}

source(here::here("R", "Functions", "render_presentation_outputs.R"))
render_presentation_outputs()
