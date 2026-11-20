# UI 美术来源

本目录正式 UI 素材基于项目成员提供的 AI 生成设计图整理：

- `security_card.png`、`cleaner_card.png`、`manager_card.png`：由横排三卡图等宽拆分，顺序对应 `SECURITY`、`CLEANER`、`MANAGER`；保留原 PNG 透明通道、统一 724×724 画布。
- `handbook_spread.png`：展开员工手册底图，来源为用户提供的 AI 生成设计图。图片本身为不透明完整画面，正文区域使用透明 UI 控件叠加。

来源性质：AI 生成图（由项目成员提供）；非项目原生绘制素材。

## 视觉小说开场素材

`visual_novel/` 中的场景背景、对话框和两张六格人物表情图均取自项目成员提供的 AI 生成素材；经理立绘由提供的 AI 生成原图去白底生成透明衍生图。表情图按 3 列 × 2 行使用 AtlasTexture 取图，保留原图和透明通道。

- `bedroom_rain.png`：深夜房间。
- `cafe_sunset.png`：傍晚咖啡馆回忆。
- `hotel_exterior_rain.png`：雨夜旅馆外景。
- `hotel_lobby.png`：旅馆一楼大堂。
- `protagonist_expressions.png`、`friend_expressions.png`：女主与闺蜜六表情。
- `manager_portrait.png`：经理透明立绘衍生图。
- `dialogue_frame.png`：透明奶油金对白框。

## 黄铜旅馆界面

`hotel_interface/` 中的雨夜封面、中英字标、五格行李箱、状态栏、进度轨道、双状态卡槽和手机外框来自本项目的 AI 生成 UI 素材包。手机圆形头像从既有的安和闺蜜立绘裁切，震动线为序章提示素材。仅导入场景实际使用的 PNG。

### 2026-11-19 界面按钮与功能栏

同一套参考图生成了六种按钮纹理、任务纸页、黄铜工具栏／状态条／提示纸页，以及背包、笔记、钥匙、沙漏、暂停和返回菜单六个图标。素材已拆分为透明 PNG，由实际 UI 控件覆盖文字。封面闪电、短暂黑场、字标上升和按钮反馈由 Godot Tween 驱动。
