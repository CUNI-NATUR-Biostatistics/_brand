# Render RevealJS and its static PDF variant, then publish outputs together.

render_presentation_outputs <- function() {
  source(here::here("R", "prepare_pollslive_quiz.R"))
  quiz <- prepare_pollslive_quiz()

  source_qmd <- here::here("Presentation", "presentation.qmd")
  presentation_directory <- dirname(source_qmd)
  live_html <- file.path(presentation_directory, ".presentation-live.html")
  static_qmd <- file.path(presentation_directory, ".presentation-static.qmd")
  static_html <- file.path(presentation_directory, ".presentation-static.html")
  raw_pdf <- file.path(presentation_directory, ".presentation-raw.pdf")
  final_pdf <- file.path(presentation_directory, ".presentation-final.pdf")
  temporary_files <- c(live_html, static_qmd, static_html, raw_pdf, final_pdf)
  unlink(temporary_files, force = TRUE)
  on.exit(unlink(temporary_files, force = TRUE), add = TRUE)

  quarto::quarto_render(
    input = source_qmd,
    output_file = basename(live_html)
  )

  static_source <- readLines(source_qmd, warn = FALSE, encoding = "UTF-8")
  if (isTRUE(quiz$enabled)) {
    replaced <- grepl("/active.qmd", static_source, fixed = TRUE)
    if (sum(replaced) != 1L) {
      stop("The presentation must include exactly one generated PollsLive active.qmd file.")
    }
    static_source[replaced] <- sub("/active.qmd", "/static.qmd", static_source[replaced], fixed = TRUE)
  }
  writeLines(static_source, static_qmd, useBytes = TRUE)
  quarto::quarto_render(
    input = static_qmd,
    output_file = basename(static_html)
  )

  decktape <- Sys.which(if (.Platform$OS.type == "windows") "decktape.cmd" else "decktape")
  if (!nzchar(decktape)) {
    stop("DeckTape is required to export the presentation PDF.")
  }
  status <- system2(
    command = decktape,
    args = c(
      "reveal", "--fragments=false",
      "--size", "1050x700",
      # `system2()` requires path arguments containing spaces to be quoted.
      shQuote(static_html),
      shQuote(raw_pdf)
    )
  )
  if (!identical(status, 0L)) {
    stop("DeckTape failed with status ", status, ".")
  }
  qpdf::pdf_compress(input = raw_pdf, output = final_pdf)

  final_html <- here::here("Presentation", "presentation.html")
  final_pdf_path <- here::here("Presentation", "presentation.pdf")
  docs_html <- here::here("docs", "index.html")
  dir.create(dirname(docs_html), recursive = TRUE, showWarnings = FALSE)
  if (!file.copy(live_html, final_html, overwrite = TRUE)) stop("Could not publish presentation.html.")
  if (!file.copy(final_pdf, final_pdf_path, overwrite = TRUE)) stop("Could not publish presentation.pdf.")
  if (!file.copy(live_html, docs_html, overwrite = TRUE)) stop("Could not publish docs/index.html.")

  invisible(list(html = final_html, pdf = final_pdf_path, docs = docs_html, quiz = quiz))
}
