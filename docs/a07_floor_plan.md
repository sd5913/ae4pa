# A-07 五层占位与切换实施记录

依据：[主策划](game-design.md)第 4、9、10 节及 [公共接口](interfaces.md)。用户已授权提前开发 A-07，并指定 `work/member-A-liuling`；11 月 6 日仅本地开发，11 月 7 日另行明确授权上传并经 PR 合入 main。

## 实施范围与选择

采用五个可编辑楼层场景、一个共用走廊脚本，由 GameManager 在指定 World 节点同步替换楼层。F5 原公共走廊保留；新增独立 F6 预览入口，明确提供跳过通行条件的开发按钮。这样成员测试入口不变，后续直接在楼层的 Marker2D 接入组件。

正式 `go_to_floor` 只允许 PLAYING 时前往下一层，1F 检查真实 `CardManager.has_all_cards()`，3F 检查 `has_friend`。换层不重置卡片和故事状态，旧场景移出树，新场景完成出生点与相机配置后再恢复 PLAYING、发 `floor_changed`。无效请求不改变现有场景。预览跳转只由编辑器可执行程序中的明确测试入口启用，不伪造卡片或救援数据。

不包含偷卡、怪物规则、救援、重试、正式 UI、淡入淡出或通关。A-07 的场景与切换可独立验收；11 月 7 日同步 B/C 交付后，已用真实 CardManager 补测三卡上楼和装备保留，实际偷卡／救援主线仍待组装。所有楼层按世界原点、无旋转、缩放 1 放置。

## 步骤

- [x] 新增 `scenes/tests/core/floor_flow_smoke.gd`，先确认缺少五层及换层接口导致失败。
- [x] 创建 `scenes/levels/floor_base.tscn`、`floor.gd` 及 `floor_1.tscn`—`floor_5.tscn`：出生点、主角、边界、相机、员工／房门／309／出口接入位和房号占位。
- [x] 扩展 `scripts/game_manager.gd`：楼层宿主、新局装载、顺序与通行检查、加载期间禁止游玩、完成后通知；新增受限制的开发预览调用。
- [x] 新增 `scenes/tests/core/floors_test.tscn` 及脚本：F6 可从 1F 预览到 5F，E 用真实条件，开发按钮明确跳过条件。
- [x] 运行新增流程检查与既有 foundation_smoke；覆盖场景替换、出生点、相机、单主角、非法／重复请求、失败状态拦截、真实缺卡／未救援拦截、预览不造数据、跨层保留故事状态和重开回 1F。
- [x] 在 Mac 实际渲染预览，核对中文、按钮与楼层画面；同步 README、接口、PLANS、接入说明和进度证据。

## 验证命令

Godot 可执行文件由实际环境定位；以下从仓库根目录运行：

```sh
godot --headless --path . --script res://scenes/tests/core/floor_flow_smoke.gd
godot --headless --path . --script res://scenes/tests/core/foundation_smoke.gd
git diff --check
```

检查当前不可覆盖的风险：B/C/D 实际 setup 与信号绑定、员工偷卡后的连续游玩、3F 救援后的真实交互、Windows 运行、正式淡入淡出。开发预览不得记为这些项目通过。
