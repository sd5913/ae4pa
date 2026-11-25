# D 角色美术同步 main 与验证记录（2026-11-25）

已将最新 main `d0f57a700f87ac920c8d1eba19a6e8554ec9d30d` 合入 `work/member-D-character-art-v2`，无冲突，未把功能分支合回 main。

远端合并提交：`fdf8d710e2684dd71c568cc7742b449407cef463`。通过连接的 GitHub 通道上传，远端内容树 `adb9d7402ba118af882e31ebd51063ebadde6cac` 与本地实测合并提交 `be4c7dcbe0972067bdf7d927c10f2705941c8c0e` 完全一致；仅提交元数据不同。原本地三项美术提交及合并历史保存在本地备份分支 `backup/member-D-character-art-localmerge-20261125`。

## 本轮实际验证

环境：Debian 13，Godot `4.7.2.stable.official.ed1daf0bf`。以下为无界面自动化，不等于 Windows/macOS 人工或导出包验收。命令均在仓库根目录运行。

| 命令（前缀 godot --headless --path .） | 实际结果 |
| --- | --- |
| --editor --import --quit | 退出0，无资源或脚本错误 |
| --script res://scenes/tests/core/foundation_smoke.gd | 退出0 |
| --script res://scenes/tests/ui/character_art_v2_smoke.gd -- --ui-smoke | 退出0，三角色表情固定画布、脚底对齐、八帧行走、固定待机、三种身份外观和新Terese跟随美术通过 |
| --script res://scenes/tests/staff/final_visual_integration_smoke.gd -- --ui-smoke | 退出0 |
| --script res://scenes/tests/core/full_mainline_escape_smoke.gd -- --ui-smoke | 退出0，日志确认正常新局、八项真实任务及实际309 CG路线通过 |

完整路线最终输出：`PASS: full_mainline_escape from normal new game, all eight real tasks and actual309 CG`。日志仍有203/205工作点 `TASK_INACTIVE` 诊断，但没有导致本次回归失败。此前同步main前在2F旅行处失败的结果属于旧提交，不作为本次合并后的结论。

`git diff --check` 通过。既有未跟踪导入侧车和历史截图未清理、未批量提交。

## 美术与接入

更新了Carol、Terese、经理的半身立绘与Q版；补齐三人六表情和Carol清扫姿势；更新309三张CG、三员工抓包三张CG及雨夜封面人物。用户包17张PNG原样保留，见[源图清单](../../../assets/final/characters/refresh_v2/manifest.json)和[美术说明](../../../assets/final/characters/refresh_v2/README.md)。

沿用现有资源路径、节点及信号，不修改卡片数据、任务规则、309结算或EXIT资格。跑步/体力功能本轮未新增；相关原始动作图集保留。审查和实机验收完成后再由A决定是否合并main。

## A 审查修复复测

- 经理保留新版站姿和八帧行走。转身、怀疑、抓包使用原有独立反应帧，状态优先级沿用原规则。
- macOS Apple M5、Godot `4.7.2.stable.official.ed1daf0bf`：干净导入退出 0，沙箱系统字体诊断不影响以下结果。角色美术测试先确认原分支三个经理反应断言失败，修复后全部通过。
- `character_art_v2_smoke.gd -- --ui-smoke`、`player_identity_outfit_smoke.gd` 和 `foundation_smoke.gd` 的无界面运行均退出 0。换装测试也在本机 Compatibility 图形模式退出 0，逐帧校验全八帧与清扫姿态的经理外套着色，以及脸部和下装像素不变。此次复测未执行 Windows、导出包或人工试玩。
