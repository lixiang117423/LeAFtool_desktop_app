# LeAFtool 桌面版打包指南（Desktop Build Guide）

把 LeAFtool（R Shiny + EBImage）打包成**无需安装 R** 的桌面应用：

| 平台 | 产物 | 构建方式 |
|---|---|---|
| macOS（Apple Silicon） | `LeAFtool-1.0.0-arm64.dmg` | 本机构建 或 GitHub Actions |
| Windows（x64） | `LeAFtool-Setup-1.0.0.exe` | GitHub Actions（Windows 必须在其自身平台构建） |

基于 [shinyelectron](https://r-pkg.thecoatlessprofessor.com/shinyelectron/)（Electron 壳 + 内置 portable R 运行时，
`runtime_strategy = bundled`）。用户双击应用即可使用，完全离线，无需安装 R、无需联网。

## 一、原理

```
┌─────────────────────────────────────────────┐
│ Electron 窗口（LeAFtool.app / LeAFtool.exe） │
│  ┌───────────────────────────────────────┐  │
│  │ Shiny 应用（inst/app + R/ 核心函数）    │  │
│  └───────────────────────────────────────┘  │
│  ┌───────────────────────────────────────┐  │
│  │ 内置 portable R 4.5.3 + 私有包库         │  │
│  │ (EBImage 等来自 Bioconductor 3.22)     │  │
│  └───────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
```

- `app/` 目录由 `scripts/assemble-app.R` 在构建时组装：复制 `inst/app`（Shiny
  UI/server）+ `R/`（核心函数），并在 `global.R` 末尾注入 `source()` 语句——
  桌面版不是已安装的 R 包，所以必须直接 source 核心函数。
- `packaging/_shinyelectron.yml` 是 shinyelectron 配置。**R 固定为 4.5.3**：
  Bioconductor 3.22 是最后一个同时为 R 4.5.x 提供 macOS arm64 和 Windows
  二进制 EBImage 的版本。
- portable R 会自动修补二进制包中硬编码的 `/Library/Frameworks/...` 路径
  （macOS），无需额外处理。

## 二、本机构建 macOS 版（推荐用 conda 环境，不动系统 R）

### 1. 创建 conda 环境（mamba / miniforge）

```bash
cd LeAFtool_desktop_app
mamba env create -f environment.yml
```

### 2. 在环境内安装 shinyelectron（GitHub 包，conda-forge 没有）

```bash
mamba run -n leaftool-desktop Rscript -e 'pak::pak("coatless-rpkg/shinyelectron")'
```

### 3. 构建（约 15–40 分钟，需联网下载 portable R 和依赖包）

```bash
mamba run -n leaftool-desktop Rscript build-desktop.R
```

产物在 `build/<electron-app>/dist/`：`LeAFtool-1.0.0-arm64.dmg`。
构建成功后可以把 .dmg 复制到 `dist/` 目录分发。

## 三、Windows 版（GitHub Actions）

Windows 的 bundled 构建必须在 Windows 上执行。仓库里已配好工作流
`.github/workflows/build-desktop.yml`：

1. 把仓库推送到 GitHub（main 分支）：
   ```bash
   git add . && git commit -m "desktop packaging" && git push -u origin main
   ```
2. GitHub 上打开 Actions 页 → Build LeAFtool desktop installers → Run workflow；
   或者直接推送一个 tag（`git tag v1.0.0 && git push origin main --tags`）自动触发并把
   安装包挂到 Release 页。
3. 产物：
   - `LeAFtool-mac-arm64` → `LeAFtool-1.0.0-arm64.dmg`
   - `LeAFtool-win-x64` → `LeAFtool-Setup-1.0.0.exe`

## 四、给最终用户的分发说明

**macOS（未签名构建）**：第一次打开时，右键点击 LeAFtool.app →
“打开” → 再点“打开”即可（Gatekeeper 拦截一次）。或者用
`xattr -dr com.apple.quarantine LeAFtool.app` 清除隔离标记。

**Windows（未签名构建）**：SmartScreen 可能提示“未知发布者”，
点“更多信息”→“仍要运行”。如需去除提示，需要购买代码签名证书
（配置方法见 shinyelectron 的 Code Signing 文档）。

**使用要点**：
- 训练（Training）和分析（Analysis）需要选择本机目录读写，
  请给应用完整的文件访问权限（macOS 若提示授权请允许）。
- 多线程分析使用本机多核，首次运行会在后台启动 R 进程，
  稍候几秒即可。

## 五、常见问题

- **构建失败：找不到 EBImage 二进制** → 检查 Bioconductor 版本与 R 版本对应
  （R 4.5.x ↔ Bioc 3.22）。升级 R 需同步调整
  `packaging/_shinyelectron.yml` 中的 `dependencies.r.version` 和
  `dependencies.r.repos`。
- **应用体积**：内置 R + 全部依赖约 300–500 MB，属正常。
- **修改应用代码后**：直接改 `inst/app/` 或 `R/` 源码，重新跑组装+构建即可，
  不需要维护 `app/` 副本（`app/`、`build/`、`dist/` 均已 gitignore）。

## 六、文件清单

| 文件 | 作用 |
|---|---|
| `packaging/_shinyelectron.yml` | shinyelectron 配置（R 版本、依赖包、仓库源） |
| `scripts/assemble-app.R` | 组装自包含 Shiny 应用 `app/` |
| `build-desktop.R` | 本机一键构建入口 |
| `.github/workflows/build-desktop.yml` | CI 构建 macOS .dmg + Windows .exe |
| `environment.yml` | 本机构建用的 conda 环境定义 |