# Focused regression checks for the in-session PollsLive preparation cache.

source(file.path("R", "prepare_pollslive_quiz.R"))

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
}

run_tests()
