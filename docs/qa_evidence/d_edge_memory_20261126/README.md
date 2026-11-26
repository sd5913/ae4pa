# 存档页／边缘HUD布局（2026-11-26）

基于 main `4ae5577`，分支 `work/member-D-hud-memory-layout`，最终实测运行代码 `c2a7047`。范围只包含D显示组件和独立测试，保留真实MemoryService、CardManager、暂停和任务请求入口。

- 存档页：保持橄榄绿／黄铜风格、整张底图等比缩放，固定三列两行，统一卡片、标题、标签及页脚宽度。自动存档切换放到底部。存档提供preview_path时可展示预览，未提供时展示真实存档元信息或空位，不伪造截图。
- HUD：移除右上楼层显示块；装备槽放大并与任务条并排；四功能按钮改成右边缘竖排图标，悬停／键盘聚焦向左展开，点击才触发原动作，离开收起。保留原按钮唯一名称与信号。
- 背包：关闭圆叉移到包外右上角；整包等比缩放并为关闭按钮留安全空间。
- 修正原全局按钮装饰器在节点重挂时重复连接信号的问题。

## 实测

Debian 13，Godot `4.7.2.stable.official.ed1daf0bf`。Compatibility／Mesa llvmpipe真实窗口（Xvfb TCP），中英文各960×540、1280×720、1920×1080。

| 检查 | 结果 |
| --- | --- |
| 资源导入 | 退出0 |
| edge_memory_layout_smoke.gd | headless退出0；图形退出0，真实GUI鼠标移动／按下／释放，悬停不激活、点击打开、包外圆叉关闭、六卡片等宽等高且完整可见 |
| memory_ui_smoke.gd | 图形退出0，真实后端绑定、历史、输入隔离、自动槽与确认流程原检测通过 |
| memory_service_smoke.gd | headless退出0，含预期写失败场景通过；该检查使用测试存储目录 |
| git diff --check | 通过 |

图形与回归结果见[results.json](results.json)、[图形日志](graphics.log)、[原存档UI回归](memory_regression.log)。代码实测于本次布局提交；后续证据提交不改变运行代码。无Windows/macOS人工或导出验收，不将这些结果登记为真人试玩。原UI回归在headless会等待frame_post_draw，本次以真实渲染窗口运行。

代表截图：[HUD](hud_zh_CN_1280.png) · [悬停展开](hover_zh_CN_1280.png) · [英文960存档页](save_en_960.png) · [包外关闭叉](bag_zh_CN_1280.png)。截图均来自正式main实例及实际UI，夹具只通过原开场完成回调到达一楼，使用独立测试存档目录，不写玩家正式存档。

复现：`godot --headless --path . --script res://scenes/tests/ui/edge_memory_layout_smoke.gd -- --ui-smoke`。有显示服务时去掉headless并设置 `AE4PA_EDGE_EVIDENCE` 到可写目录可生成截图。

初轮暴露的按钮重复信号已修正；包外X的初轮断言误把物理窗口尺寸与Godot逻辑视口混用，改成实际逻辑视口边界检测，并逐图确认屏幕内可点击。
