#############################################################################
# assemble-app.R
#
# Assembles a self-contained Shiny app directory ("app/") for shinyelectron
# from the package sources:
#
#   inst/app/  ->  app/   (Shiny ui.R/server.R/global.R, ui_code, server_code,
#                          www, helpfiles)
#   R/         ->  app/R/  (core functions: analysis, training, toolbox)
#   packaging/_shinyelectron.yml -> app/_shinyelectron.yml
#
# The desktop bundle is NOT an installed R package, so app/global.R is patched
# to source() the core R functions directly.
#
# Usage:
#   Rscript scripts/assemble-app.R        # from the repository root
#   source("scripts/assemble-app.R"); assemble_app()   # from R code
#############################################################################

repo_root <- function() {
  # locate the repository root relative to this script
  this_file <- NULL
  args <- commandArgs(trailingOnly = FALSE)
  file_arg <- grep("^--file=", args, value = TRUE)
  if (length(file_arg) > 0) {
    this_file <- normalizePath(sub("^--file=", "", file_arg[1]), mustWork = FALSE)
  }
  if (!is.null(this_file)) {
    return(normalizePath(file.path(dirname(this_file), ".."), mustWork = FALSE))
  }
  # fallback: current working directory (assumed to be the repository root)
  normalizePath(getwd(), mustWork = FALSE)
}

assemble_app <- function(root = repo_root(), version = Sys.getenv("LEAFTOOL_VERSION", unset = ""), verbose = TRUE) {
  appdir <- file.path(root, "app")
  src_app <- file.path(root, "inst", "app")
  src_r <- file.path(root, "R")
  cfg <- file.path(root, "packaging", "_shinyelectron.yml")

  stopifnot(dir.exists(src_app), dir.exists(src_r), file.exists(cfg))

  if (verbose) message("Assembling app into: ", appdir)

  # clean and recreate app/
  unlink(appdir, recursive = TRUE, force = TRUE)
  dir.create(appdir, recursive = TRUE, showWarnings = FALSE)

  # copy the whole Shiny app
  ok <- file.copy(
    list.files(src_app, full.names = TRUE, all.files = TRUE, no.. = TRUE),
    appdir, recursive = TRUE
  )
  if (!all(ok)) stop("Failed to copy inst/app content", call. = FALSE)

  # copy the core R sources (not runApp.R: irrelevant for the desktop app)
  dir.create(file.path(appdir, "R"), showWarnings = FALSE)
  core_files <- c("analysis_functions_v6.r", "training_functions_V6.r", "toolbox.R")
  ok <- file.copy(file.path(src_r, core_files), file.path(appdir, "R"))
  if (!all(ok)) stop("Failed to copy R/ core sources", call. = FALSE)

  # patch global.R: source the core functions at the end of the file
  global_file <- file.path(appdir, "global.R")
  stopifnot(file.exists(global_file))
  global_lines <- readLines(global_file, warn = FALSE)

  marker <- "## ---- Desktop packaging: source LeAFtool core functions ----"
  if (!any(grepl(marker, global_lines, fixed = TRUE))) {
    patch <- c(
      "",
      marker,
      "## The desktop bundle is not an installed R package, so the core",
      "## functions (training, analyseImages, resizeImageDirectory, splitImages)",
      "## are sourced directly from the bundled R/ folder.",
      'if (file.exists(file.path("R", "analysis_functions_v6.r"))) {',
      '  source(file.path("R", "analysis_functions_v6.r"), local = TRUE)',
      '  source(file.path("R", "training_functions_V6.r"), local = TRUE)',
      '  source(file.path("R", "toolbox.R"), local = TRUE)',
      "}",
      ""
    )
    global_lines <- c(global_lines, patch)
    writeLines(global_lines, global_file)
    if (verbose) message("Patched global.R to source core functions")
  }

  # copy the shinyelectron configuration
  cfg_out <- file.path(appdir, "_shinyelectron.yml")
  file.copy(cfg, cfg_out, overwrite = TRUE)

  # inject the build version (from LEAFTOOL_VERSION env var, e.g. tag-derived)
  if (nzchar(version) && grepl("^[0-9]+\\.[0-9]+\\.[0-9]+", version)) {
    cl <- readLines(cfg_out, warn = FALSE)
    i_app <- grep("^app:", cl)[1]
    i_ver <- grep("^  version:", cl)
    i_ver <- i_ver[i_ver > i_app][1]
    if (!is.na(i_ver)) {
      cl[i_ver] <- paste0('  version: "', version, '"')
      writeLines(cl, cfg_out)
      if (verbose) message("Set app version to: ", version)
    }
  }

  # copy app icons (referenced by icons.mac / icons.win in the config)
  src_icons <- file.path(root, "packaging", "icons")
  if (dir.exists(src_icons)) {
    dir.create(file.path(appdir, "icons"), showWarnings = FALSE)
    file.copy(list.files(src_icons, full.names = TRUE),
              file.path(appdir, "icons"), overwrite = TRUE)
  }

  if (verbose) message("Assembled OK: ", appdir)
  invisible(appdir)
}

# run when executed as a script
if (!interactive() && !is.null(repo_root())) {
  assemble_app()
}
