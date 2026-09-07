# Focused regression checks for PollsLive preparation and render variants.

source(file.path("R", "prepare_pollslive_quiz.R"))
source(file.path("R", "Functions", "prepare_presentation_variant.R"))
source(file.path("R", "Functions", "Theme_generation", "generate_presentation_components.R"))

run_tests <- function() {
  old_cache <- getOption("biostat.pollslive_preparation")
  on.exit(options(biostat.pollslive_preparation = old_cache), add = TRUE)

  cached <- list(enabled = TRUE, mode = "sync")
  options(biostat.pollslive_preparation = cached)

  same_mode <- prepare_pollslive_quiz(mode = "sync")
  stopifnot(identical(same_mode, cached))

  message <- tryCatch(
    {
      prepare_pollslive_quiz(mode = "offline")
      NA_character_
    },
    error = conditionMessage
  )

  stopifnot(
    is.character(message),
    length(message) == 1L,
    grepl("already ran in 'sync' mode", message, fixed = TRUE),
    grepl("refusing to reuse it for 'offline' mode", message, fixed = TRUE)
  )

  node <- Sys.which("node")
  stopifnot(nzchar(node))
  spaced_argument <- run_checked(
    command = node,
    args = c("-e", "console.log(process.argv[1])", "value with spaces")
  )
  stopifnot(identical(spaced_argument, "value with spaces"))

  variant_directory <- tempfile("pollslive-render-variants-")
  dir.create(variant_directory)
  on.exit(unlink(variant_directory, recursive = TRUE, force = TRUE), add = TRUE)
  source_qmd <- file.path(variant_directory, "presentation.qmd")
  writeLines(
    c(
      "---",
      "format:",
      "  revealjs:",
      '    output-file: "presentation"',
      "---",
      "",
      "{{< include ../pollslive/generated/active.qmd >}}"
    ),
    source_qmd,
    useBytes = TRUE
  )

  for (variant in c("active", "static", "offline")) {
    output_qmd <- file.path(variant_directory, paste0(".", variant, ".qmd"))
    output_stem <- paste0(".presentation-", variant)
    prepare_presentation_variant(
      source_qmd = source_qmd,
      output_qmd = output_qmd,
      output_stem = output_stem,
      quiz_variant = variant
    )
    output <- readLines(output_qmd, warn = FALSE, encoding = "UTF-8")
    stopifnot(
      sum(trimws(output) == paste0('output-file: "', output_stem, '"')) == 1L,
      sum(grepl(paste0("/", variant, ".qmd"), output, fixed = TRUE)) == 1L
    )
  }

  components_path <- tempfile(fileext = ".scss")
  generate_presentation_components(components_path)
  components <- paste(readLines(components_path, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  stopifnot(
    grepl("section.pollslive-join", components, fixed = TRUE),
    grepl(".quiz-options ul", components, fixed = TRUE),
    grepl(".quiz-answer", components, fixed = TRUE),
    grepl(".pollslive-file-fallback", components, fixed = TRUE)
  )
}

run_tests()
