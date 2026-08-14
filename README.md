![LeAFtool Logo](./inst/app/www/LeAFtool-long.png)

# LeAFtool — Lesion Area Finding tool（桌面版打包仓库）

[![Build LeAFtool desktop installers](https://github.com/lixiang117423/LeAFtool_desktop_app/actions/workflows/build-desktop.yml/badge.svg)](https://github.com/lixiang117423/LeAFtool_desktop_app/actions/workflows/build-desktop.yml)

LeAFtool 是一个用于**植物叶片病斑图像分析**的工具：基于监督式像素分类（LDA / QDA / SVM），
从扫描图像中自动分割叶片与病斑，并输出病斑数量、面积、形状等量化指标。

本仓库在**原始 LeAFtool R 包**的基础上，增加了**桌面应用打包**能力，
使没有 R 基础的用户也能通过双击安装包直接使用。

---

## 目录

- [桌面版：免安装 R 直接使用](#桌面版免安装-r-直接使用)
- [本仓库与原始项目的关系](#本仓库与原始项目的关系)
- [原始 R 包功能（供 R 用户参考）](#原始-r-包功能供-r-用户参考)
- [桌面版构建指南（开发者）](#桌面版构建指南开发者)
- [致谢](#致谢)
- [许可证](#许可证)

---

## 桌面版：免安装 R 直接使用

| 平台 | 安装包 | 说明 |
|---|---|---|
| macOS（Apple Silicon, M 系列芯片） | `LeAFtool-1.0.0-arm64.dmg` | 打开 dmg，把 LeAFtool.app 拖入"应用程序" |
| Windows（x64） | `LeAFtool-Setup-1.0.0.exe` | 双击安装，安装完成后从开始菜单启动 |

**下载地址**：本仓库的 [Actions 页面](https://github.com/lixiang117423/LeAFtool_desktop_app/actions)
（最新一次成功的构建 → 底部 Artifacts 下载）；
推送 tag（如 `v1.0.0`）后安装包也会自动挂到 [Releases 页面](https://github.com/lixiang117423/LeAFtool_desktop_app/releases)。

桌面版内置了完整的 R 运行时和全部依赖（含 EBImage），
**用户机器上不需要安装 R，首次启动也无需联网**。

### 首次打开提示

- **macOS**：应用未签名，首次打开请**右键点击 LeAFtool.app → 打开 → 再点"打开"**；
  或在终端执行 `xattr -dr com.apple.quarantine /Applications/LeAFtool.app`。
- **Windows**：SmartScreen 提示"未知发布者"时，点**更多信息 → 仍要运行**。

### 基本流程

1. **Training（训练）**：准备一个训练目录，包含 `background` / `limb` / `lesion` 三个子目录，
   放入对应类别的采样图像 → 选择方法（LDA/QDA/SVM）和颜色模型（RGB/HSV）→ Run。
2. **Analysis（分析）**：选择训练目录、样本图像目录和输出目录，设置叶片/病斑大小阈值等参数 → Run。
3. **Edit（编辑）**：对分析结果进行人工校正（删除误检病斑、按形状/面积过滤）。
4. **Toolbox（工具箱）**：批量缩放、切分图像。

---

## 本仓库与原始项目的关系

本仓库**源自** [sravel/LeAFtool_R](https://github.com/sravel/LeAFtool_R)（CIRAD 的 LeAFtool 原始 R 包），
在此基础上新增/修改了以下内容：

| 内容 | 说明 |
|---|---|
| 桌面打包工程 | 基于 [shinyelectron](https://r-pkg.thecoatlessprofessor.com/shinyelectron/)（Electron + 内置 portable R），一键产出 macOS .dmg 与 Windows .exe |
| GitHub Actions 工作流 | 推送即自动构建 macOS (arm64) 与 Windows (x64) 安装包 |
| Bug 修复 | `analyseImages()` 中 `fileImage` 参数被覆盖失效的问题；SVM 模式预测调用错误字段（`train$svm` → `train$svm11`）的问题 |
| 应用图标 | 由原始 Logo 生成的 `icns` / `ico` |
| 使用文档 | `DESKTOP-BUILD.md`（桌面版构建指南） |

原始算法、Shiny 界面与全部核心代码版权归原作者所有，详见下文致谢与许可证。

---

## 原始 R 包功能（供 R 用户参考）

> 原始项目的完整说明见[原始 README](https://github.com/sravel/LeAFtool_R)。

研究植物叶片病害需要获取定量数据来表征不同病原引起的症状。这些症状通常是病斑（lesion），
可通过颜色与纹理与叶片区分。LeAFtool 从实验室扫描图像出发，对每个叶片给出病斑的
数量、面积与形状特征。方法基于像素的监督分类（背景 / 叶片 / 病斑三类，可分子类），
噪声过滤使用基本形态学操作，图像处理基于 [EBImage](https://bioconductor.org/packages/EBImage)（Bioconductor）。

### 以 R 包方式安装（需要 R）

```r
install.packages("remotes")
remotes::install_github("sravel/LeAFtool_R")   # 原始仓库

if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("EBImage")
```

### 主要函数

```r
library(LeAFtool)

# 训练：输入目录须包含 background / limb / lesion 三个子目录
training(pathTraining, method = "lda", transform = NULL, colormodel = "rgb")

# 分析：对一批图像提取病斑特征
analyseImages(pathTraining, pathResult, pathImages,
              leafAreaMin = 1000, leafBorder = 5, lesionBorder = 3,
              lesionAreaMin = 10, lesionAreaMax = 120000,
              lesionEccentricityMin = 0, lesionEccentricityMax = 1,
              lesionColorBorder = "#0000FF11", lesionColorBodies = "#FE8E0000",
              blurDiameter = 0, outPosition = "right", parallelThreadsNum = 1)

# 工具箱
resizeImageDirectory(path, factor = 2)
splitImages(path, splitVertical = 2, splitHorizontal = 3)

# 启动图形界面
runLeAFtool()
```

---

## 桌面版构建指南（开发者）

详见 [DESKTOP-BUILD.md](./DESKTOP-BUILD.md)。核心要点：

- 桌面版 = shinyelectron（Electron 壳）+ 内置 portable R 4.5.3 + Bioconductor 3.22 二进制包（EBImage）。
- 本机构建 macOS 版（不动系统 R，使用 conda 环境）：
  ```bash
  mamba env create -f environment.yml
  mamba run -n leaftool-desktop Rscript -e 'pak::pak("coatless-rpkg/shinyelectron")'
  mamba run -n leaftool-desktop Rscript build-desktop.R
  ```
- Windows 版由 GitHub Actions 在 Windows runner 上自动构建（`.github/workflows/build-desktop.yml`）。

---

## 致谢

- **原始 LeAFtool 开发者**：Sébastien RAVEL、François BONNOT（CIRAD），Elisabeth FOURNIER（INRAE，原 INRA）。
  原始代码托管于 <https://github.com/sravel/LeAFtool_R>，其知识产权归 CIRAD 与 South Green 开发平台所有。
- **机构**：CIRAD、INRAE（原 INRA）及 [South Green](http://southgreen.fr/) 生物信息学平台。
- **核心依赖**：[EBImage](https://bioconductor.org/packages/EBImage)（Bioconductor 图像处理包）、
  [shiny](https://shiny.posit.co/) 及一系列 R 生态包。
- **桌面打包工具链**：[shinyelectron](https://github.com/coatless-rpkg/shinyelectron)（作者 James J. Balamuta / coatless-rpkg）、
  [portable-r](https://github.com/portable-r)（可移植 R 运行时）、Electron 与 electron-builder。
- 原始项目曾于 [JOBIM 2019](https://jobim2019.sciencesconf.org/) 展示海报（见 `inst/app/www/posterLeaftool-JOBIM2019.png`）。

本仓库仅出于易用性目的为原始项目补充桌面打包能力；若 LeAFtool 的算法与功能对你有用，
请优先引用/致谢原始项目及其作者。

---

## 许可证

沿用原始项目的许可证：**LGPL-3**（GNU Lesser General Public License v3），详见 [LICENSE](./LICENSE)。
原始代码版权 © 2019 CIRAD-INRA。本仓库新增的打包工程文件在相同许可证下发布。
