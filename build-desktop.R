#!/usr/bin/env Rscript
#############################################################################
# build-desktop.R — local desktop build entry point
#
# Prerequisites (see DESKTOP-BUILD.md):
#   1. conda env "leaftool-desktop" created from environment.yml
#   2. shinyelectron installed inside that env:
#        mamba run -n leaftool-desktop Rscript -e 'pak::pak("coatless-rpkg/shinyelectron")'
#
# Usage (from the repository root, conda env activated):
#   Rscript build-desktop.R              # macOS + current architecture
#   Rscript build-desktop.R mac arm64    # macOS arm64 (Apple Silicon)
#
# NOTE: bundled Windows builds must run on Windows — use the GitHub Actions
# workflow (.github/workflows/build-desktop.yml) for the .exe.
#############################################################################

args <- commandArgs(trailingOnly = TRUE)
platform <- if (length(args) >= 1) args[[1]] else "mac"
arch <- if (length(args) >= 2) args[[2]] else {
  if (Sys.info()[["machine"]] == "arm64") "arm64" else "x64"
}

stopifnot(platform %in% c("mac", "win"))
stopifnot(arch %in% c("arm64", "x64"))
if (platform == "win") {
  stop("Bundled Windows builds cannot be created on macOS. ",
       "Push to GitHub and let the workflow .github/workflows/build-desktop.yml ",
       "produce the .exe, or run this script on a Windows machine.",
       call. = FALSE)
}

# this script lives at the repository root
root <- dirname(sub(
  "^--file=", "", grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)[1]
))
root <- normalizePath(root, mustWork = FALSE)

# 1. assemble the self-contained Shiny app (app/)
source(file.path(root, "scripts", "assemble-app.R"))
assemble_app(root = root, verbose = TRUE)

# 2. build with shinyelectron (bundled portable R + packages + Electron)
library(shinyelectron)
sitrep_shinyelectron()

result <- shinyelectron::export(
  appdir = file.path(root, "app"),
  destdir = file.path(root, "build"),
  app_name = "LeAFtool",
  app_type = "r-shiny",
  runtime_strategy = "bundled",
  platform = platform,
  arch = arch,
  sign = FALSE,
  overwrite = TRUE,
  verbose = TRUE
)

cat("
=== Build finished ===
")
cat("electron app:", result[["electron_app"]], "
")
cat("dist:        ", file.path(result[["electron_app"]], "dist"), "
")
