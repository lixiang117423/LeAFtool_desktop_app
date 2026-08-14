![LeAFtool Logo](./inst/app/www/LeAFtool-long.png)

# LeAFtool — Lesion Area Finding tool (Desktop Packaging Repository)

[中文版](./README.md) | English

[![Build LeAFtool desktop installers](https://github.com/lixiang117423/LeAFtool_desktop_app/actions/workflows/build-desktop.yml/badge.svg)](https://github.com/lixiang117423/LeAFtool_desktop_app/actions/workflows/build-desktop.yml)

LeAFtool is a tool for **quantitative analysis of plant leaf disease lesions**. Based on supervised pixel
classification (LDA / QDA / SVM), it automatically segments leaves and lesions from scanned images and
outputs quantitative traits such as lesion number, area and shape.

This repository builds on the **original LeAFtool R package** and adds **desktop app packaging**, so users
without any R background can use the tool by simply double-clicking an installer.

---

## Table of Contents

- [Desktop App: Use Without Installing R](#desktop-app-use-without-installing-r)
- [Relationship to the Original Project](#relationship-to-the-original-project)
- [Original R Package Features (for R Users)](#original-r-package-features-for-r-users)
- [Desktop Build Guide (Developers)](#desktop-build-guide-developers)
- [Acknowledgements](#acknowledgements)
- [License & Compliance](#license--compliance)

---

## Desktop App: Use Without Installing R

| Platform | Installer | Notes |
|---|---|---|
| macOS (Apple Silicon, M-series) | `leaftool-<version>-arm64.dmg` | Open the dmg and drag LeAFtool.app into Applications |
| Windows (x64) | `leaftool.Setup.<version>.exe` | Double-click to install, then launch from the Start menu |

**Download**: go to the [Releases page](https://github.com/lixiang117423/LeAFtool_desktop_app/releases) —
every version tag push (e.g. `v1.0.1`) automatically builds the installers and publishes a Release with
them attached. You can also download from the [Actions page](https://github.com/lixiang117423/LeAFtool_desktop_app/actions)
(latest successful run → Artifacts).

The desktop app bundles a complete R runtime and all dependencies (including EBImage):
**no R installation and no internet connection are required, even on first launch**.

### First-Launch Notes

- **macOS**: the app is unsigned. On first launch, **right-click LeAFtool.app → Open → Open**;
  or run `xattr -dr com.apple.quarantine /Applications/LeAFtool.app` in the terminal.
- **Windows**: when SmartScreen shows "Unknown publisher", click **More info → Run anyway**.

### Basic Workflow

1. **Training**: prepare a training folder with three sub-folders — `background`, `limb` and `lesion` —
   containing sample images of each class → choose the method (LDA/QDA/SVM) and color model (RGB/HSV) → Run.
2. **Analysis**: select the training folder, the sample-image folder and an output folder,
   set leaf/lesion size thresholds and other parameters → Run.
3. **Edit**: manually curate the results (remove false detections, filter by shape/area).
4. **Toolbox**: batch resize and split images.

---

## Relationship to the Original Project

This repository is **derived from** [sravel/LeAFtool_R](https://github.com/sravel/LeAFtool_R)
(the original LeAFtool R package from CIRAD). The following has been added or changed on top of it:

| Item | Description |
|---|---|
| Desktop packaging | Based on [shinyelectron](https://r-pkg.thecoatlessprofessor.com/shinyelectron/) (Electron + embedded portable R); one command produces macOS .dmg and Windows .exe installers |
| GitHub Actions workflow | Every push builds macOS (arm64) and Windows (x64) installers automatically |
| Bug fixes | `analyseImages()`: the `fileImage` argument was overwritten and ineffective; SVM mode predicted with the wrong field (`train$svm` → `train$svm11`); Windows 11 startup crash caused by the removed `wmic` command |
| App icons | `icns` / `ico` generated from the original logo |
| Documentation | `DESKTOP-BUILD.md` (desktop build guide) |

Copyright of the original algorithms, the Shiny interface and all core code remains with the original
authors; see Acknowledgements and License below.

---

## Original R Package Features (for R Users)

> See the [original README](https://github.com/sravel/LeAFtool_R) for the complete documentation.

Research on plant leaf diseases requires quantitative data to characterize symptoms caused by different
pathogens. These symptoms are usually lesions that differ from the leaf blade by their color and texture.
From a scanned laboratory image, LeAFtool reports for each leaf the number, area and shape of its lesions.
The method is based on supervised pixel classification (background / limb / lesion classes, optionally
subdivided into sub-classes); noise filtering uses basic morphological operations; image processing is
based on [EBImage](https://bioconductor.org/packages/EBImage) (Bioconductor).

### Install as an R Package (requires R)

```r
install.packages("remotes")
remotes::install_github("sravel/LeAFtool_R")   # original repository

if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("EBImage")
```

### Main Functions

```r
library(LeAFtool)

# Training: the input folder must contain background / limb / lesion sub-folders
training(pathTraining, method = "lda", transform = NULL, colormodel = "rgb")

# Analysis: extract lesion features from a set of images
analyseImages(pathTraining, pathResult, pathImages,
              leafAreaMin = 1000, leafBorder = 5, lesionBorder = 3,
              lesionAreaMin = 10, lesionAreaMax = 120000,
              lesionEccentricityMin = 0, lesionEccentricityMax = 1,
              lesionColorBorder = "#0000FF11", lesionColorBodies = "#FE8E0000",
              blurDiameter = 0, outPosition = "right", parallelThreadsNum = 1)

# Toolbox
resizeImageDirectory(path, factor = 2)
splitImages(path, splitVertical = 2, splitHorizontal = 3)

# Launch the GUI
runLeAFtool()
```

---

## Desktop Build Guide (Developers)

See [DESKTOP-BUILD.md](./DESKTOP-BUILD.md) for details. Key points:

- Desktop app = shinyelectron (Electron shell) + embedded portable R 4.5.3 + Bioconductor 3.22 binary
  packages (EBImage).
- Build the macOS version locally (leaves your system R untouched, uses a conda environment):
  ```bash
  mamba env create -f environment.yml
  mamba run -n leaftool-desktop Rscript -e 'pak::pak("coatless-rpkg/shinyelectron")'
  mamba run -n leaftool-desktop Rscript build-desktop.R
  ```
- The Windows version is built automatically by GitHub Actions on a Windows runner
  (`.github/workflows/build-desktop.yml`).
- Release automation: pushing a version tag (e.g. `git tag v1.0.1 && git push --tags`) builds both
  installers and publishes a GitHub Release with them attached; the tag version is written into the app
  and into the installer file names.

---

## Acknowledgements

- **Original LeAFtool developers**: Sébastien RAVEL, François BONNOT (CIRAD), Elisabeth FOURNIER
  (INRAE, formerly INRA). The original code is hosted at <https://github.com/sravel/LeAFtool_R>;
  intellectual property belongs to CIRAD and the South Green development platform.
- **Institutions**: CIRAD, INRAE (formerly INRA) and the [South Green](http://southgreen.fr/)
  bioinformatics platform.
- **Core dependencies**: [EBImage](https://bioconductor.org/packages/EBImage) (Bioconductor image
  processing package), [shiny](https://shiny.posit.co/) and the wider R ecosystem.
- **Desktop packaging toolchain**: [shinyelectron](https://github.com/coatless-rpkg/shinyelectron)
  (James J. Balamuta / coatless-rpkg), [portable-r](https://github.com/portable-r) (portable R runtime),
  Electron and electron-builder.
- The original project was presented as a poster at [JOBIM 2019](https://jobim2019.sciencesconf.org/)
  (see `inst/app/www/posterLeaftool-JOBIM2019.png`).

This repository only adds desktop packaging for convenience. If LeAFtool's algorithms and features are
useful to you, please cite/acknowledge the original project and its authors first.

---

## License & Compliance

- **Original LeAFtool code**: DESCRIPTION declares **LGPL-3** (the LICENSE file in the repository contains
  the GPL-3 full text — an inconsistency inherited from the original repository, kept as-is; the source
  headers also mention CeCILL-C). Copyright © 2019 CIRAD-INRA.
- **Compliance**: the complete source code is published in this repository and is distributed inside the
  desktop app **as R source files**; all third-party components and their license texts are bundled with
  the app (see [THIRD-PARTY-NOTICES.md](./THIRD-PARTY-NOTICES.md), covering shinyelectron AGPL-3, R
  GPL-2/3, EBImage LGPL, Electron MIT, etc.); the R package library inside the app consists of ordinary
  read/writable files, so users can replace or modify any package (LGPL relinking requirement).
- **Note**: for commercial distribution, please contact the original authors to confirm the final
  licensing status.
