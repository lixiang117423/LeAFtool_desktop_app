# 第三方组件与许可证声明（Third-Party Notices）

本仓库分发的 LeAFtool 桌面应用（.dmg / .exe）内包含以下第三方组件。
本文件随应用一起打包（位于应用内 licenses/ 目录），各组件许可证全文亦一并附带。

## 1. LeAFtool 原始代码（本应用主体）

- 来源：<https://github.com/sravel/LeAFtool_R>（CIRAD）
- 作者：Sébastien RAVEL、François BONNOT、Elisabeth FOURNIER
- 许可证：DESCRIPTION 声明为 **LGPL-3**，仓库内 LICENSE 文件为 **GPL-3 全文**
  （原始仓库自身即存在此不一致，本仓库如实保留）。
- 源码头部同时提及 **CeCILL-C**（法国开源许可证）。
- 合规说明：
  - 完整源代码随本仓库公开发布（GitHub），并随应用以 **R 源文件形式**分发
    （应用内 shiny-app/R/ 目录），满足 LGPL/GPL 的源码可得性要求；
  - 所有版权头与 LICENSE 均原样保留；
  - 应用内的 R 包库（runtime/R/library/）为普通可读写的文件目录，
    用户可以自行替换/修改其中的任何 R 包（LGPL 重新链接要求），
    并可直接编辑 shiny-app/R/ 下的源码后重启应用即可生效。
- 建议：如需商业分发，建议联系原始作者确认最终许可状态。

## 2. shinyelectron（Electron 壳层代码）

- 来源：<https://github.com/coatless-rpkg/shinyelectron>
- 作者：James J. Balamuta（coatless-rpkg）
- 许可证：**AGPL-3.0-or-later**（全文见 licenses/AGPL-3.0.txt）
- 说明：应用的 Electron 启动壳层（main.js、native-r.js 等）来自 shinyelectron，
  按 AGPL-3 分发，其对应源码见上述仓库。应用自身的 R/Shiny 代码不受 AGPL 约束。

## 3. R 运行时（portable R）

- 来源：<https://github.com/portable-r/portable-r-macos> /
  <https://github.com/portable-r/portable-r-windows>（基于官方 R）
- R 许可证：**GPL-2 | GPL-3**（R 本身的 COPYING 已包含在应用内）
- R 对应源码：<https://cran.r-project.org/src/base/R-4/>
- 基础/推荐包许可证：见应用内 share/licenses/ 目录。

## 4. Electron 与 Chromium

- 许可证：Electron **MIT**；Chromium **BSD-3-Clause** 等
- 许可文本由 electron-builder 自动包含在应用内
  （LICENSE.electron.txt、LICENSES.chromium.html）。

## 5. R 扩展包（EBImage 等，来自 CRAN / Bioconductor 3.22）

- 主要包：EBImage（Bioconductor，**LGPL**）、BiocGenerics（**Artistic-2.0**）、
  RCurl（**BSD_3_clause**）、fftwtools（**GPL**）、
  shiny、shinydashboard、DT、ggplot2、ParallelLogger 等（CRAN，许可各异）。
- 说明：每个 R 包目录内均自带其 LICENSE/COPYRIGHTS 文件
  （应用内 runtime/R/library/<包名>/），构成完整的许可证清单。

## 6. 图形素材

- LeAFtool Logo / favicon / 示例图片：来自原始 LeAFtool 仓库，版权归原作者所有。
- CIRAD / BGPI 机构 Logo：商标权归相应机构，仅作为原应用的组成部分使用。
