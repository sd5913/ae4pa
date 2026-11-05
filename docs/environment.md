# 怪物员工通道环境配置

任务 04 已配置项目名称、画面、渲染器和输入映射。本文件供四名成员核对本机设置；任务 05—06 已建立主场景、管理器骨架和可移动走廊，可按 F5 运行。

## 安装与导入

团队使用 Godot 4.7.2 标准版和 GDScript。A 本机 MCP 与命令行均返回 `4.7.2.stable.official.ed1daf0bf`；B/C/D 的安装尚未核对。各成员可使用对应 Windows 或 macOS 的编辑器，准确版本保持一致。

使用 GitHub Desktop 克隆同一仓库，再在 Godot 项目管理器导入仓库中的 `project.godot`。已有本地修改时先检查和保存，不直接覆盖。不要为个人模块新建第二套项目，也不要用升级引擎的方式处理接入问题。

项目资源用 `res://` 路径，文件名小写英文和下划线。代码不依赖 A 本机 Godot 可执行文件或文档的绝对路径。

## 项目设置

| 设置 | 配置值 | 编辑器核对位置 |
|---|---|---|
| 项目名称 | 怪物员工通道 Monster Staff Access | 项目设置 → Application → Config → Name |
| 逻辑视口 | 1280×720 | Display → Window → Size → Viewport Width / Height |
| 初始窗口 | 1280×720 | Display → Window → Size → Window Width / Height Override |
| 缩放模式 | `canvas_items` | Display → Window → Stretch → Mode |
| 宽高比 | `keep` | Display → Window → Stretch → Aspect |
| 渲染器 | Compatibility（`gl_compatibility`） | 编辑器渲染器选择及 Rendering → Renderer |

部分设置需在项目设置中打开“高级设置”才能看到。保持 16:9，窗口比例不同时保留空边，避免拉伸人物和界面。实际画面与缩放试玩仍需等场景建立后进行。

## 输入映射

在“项目 → 项目设置 → 输入映射”核对以下动作；七个动作共九个按键绑定，使用物理键位。

| 动作名称 | 按键 | 后续处理者 |
|---|---|---|
| `move_left` | A、左箭头 | A 的 Player |
| `move_right` | D、右箭头 | A 的 Player |
| `interact` | E | B 的员工、A 的救援／出口；接入时统一有效目标 |
| `switch_id` | Q | B 的 CardManager 单一入口 |
| `open_bag` | I | D 的背包界面 |
| `open_help` | H | D 的手册界面 |
| `pause` | Esc | D 的界面请求、A 的流程管理 |

当前左右移动已实现，其余输入只登记映射。函数与信号见 [接口文档](interfaces.md)；背包和暂停的详细行为留到功能阶段确认。

## Git 与导出文件

`.godot/` 为本机缓存、`android/` 为生成目录、`builds/` 为约定的导出成品目录，均由根 `.gitignore` 忽略。现有规则也忽略 `.DS_Store`、临时文件和编辑器备份。

源码、场景、正式素材、必要的资源引用文件和 `.uid` 文件仍需跟踪。`.gitattributes` 已将文本换行统一为 LF；不需要成员为了本项目修改全局 Git 换行设置。

导出模板和目标平台导出配置留到导出阶段处理。公共底座完成后再由 Windows/macOS 成员分别试玩同一源项目，导出包另在对应系统验证；本轮未验证跨系统运行。

## 已完成的配置验证

2026-11-05（Asia/Hong_Kong），A 本机通过 Godot 独立进程重新读取实际项目文件，核对九项项目设置和七个输入动作的九个按键绑定，并模拟每个按键的按下与松开，确认动作状态激活和释放。Godot MCP 版本与项目信息查询均成功。

最初沙箱运行产生标准用户数据目录权限和系统证书读取错误；相同检查在正常权限下执行后没有这些错误，退出码为 0。此处是任务 04 的配置证据；后续任务 05—06 的脚本、场景及 Mac 原生画面检查另见进度记录。

其他成员接入时按上面的编辑器路径核对设置，记录 Godot 版本、系统和实际结果到 [进度记录](progress.md)。基础 QA B03 的配置检查已完成，其余运行检查按 [QA 清单](qa.md) 执行。
