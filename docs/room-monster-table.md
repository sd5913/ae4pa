# 2F–5F 房号与怪物摆放表（V4）

依据[主策划 V4](game-design.md)第 7、9 节和 [C 的 V4 房门目录](../scenes/doors/v4_door_catalog.gd)。当前 M1 的 201 是任务门，202 仍是普通门。表中其余配置用于主线接入，5F 标为建议的房号待 A 确认。

经理对白结束即可从 1F 上 2F。工作证按任务取得，1F 没有怪物房门。普通门只在开门且进入检测范围时执行判定，违规后警告并退回安全点。下表的卡片条件只适用于普通门检查，任务门另按交付条件放行。

| 楼层 | 房号 | 怪物 ID | 普通门判定 | 任务 / 配置说明 |
|---|---|---|---|---|
| 2F | 201 | 长鼻客 `NOSE` | 当前卡为 `CLEANER`，否则触发 `WRONG_CARD` | `TASK_01_CLEAN` |
| 2F | 202 | 独眼客 `EYE` | 当前卡为 `SECURITY`，否则触发 `WRONG_CARD` | `TASK_02_PARCEL` |
| 2F | 203 | 大耳客 `EAR` | 停步，移动触发 `MOVED_NEAR_EAR` | 普通门 |
| 2F | 204 | 核验客 `CHECKER` | 不切卡或换装，变更触发 `SWITCHED_NEAR_CHECKER` | 普通门 |
| 2F | 205 | 礼帽客 `HAT` | 当前卡为 `MANAGER`，否则触发 `WRONG_CARD` | 普通门 |
| 3F | 301 | 独眼客 `EYE` | 当前卡为 `SECURITY`，否则触发 `WRONG_CARD` | 普通门 |
| 3F | 302 | 核验客 `CHECKER` | 不切卡或换装，变更触发 `SWITCHED_NEAR_CHECKER` | 普通门 |
| 3F | 303 | 礼帽客 `HAT` | 当前卡为 `MANAGER`，否则触发 `WRONG_CARD` | `TASK_03_AUTHORIZE` |
| 3F | 304 | 长鼻客 `NOSE` | 当前卡为 `CLEANER`，否则触发 `WRONG_CARD` | 普通门 |
| 3F | 305 | 大耳客 `EAR` | 停步，移动触发 `MOVED_NEAR_EAR` | 普通门 |
| 3F | 309 | — | — | 闺蜜救援，须先批准登记 |
| 4F | 401 | 大耳客 `EAR` | 停步，移动触发 `MOVED_NEAR_EAR` | 普通门 |
| 4F | 402 | 独眼客 `EYE` | 当前卡为 `SECURITY`，否则触发 `WRONG_CARD` | `TASK_04_PATROL` |
| 4F | 403 | 长鼻客 `NOSE` | 当前卡为 `CLEANER`，否则触发 `WRONG_CARD` | 普通门 |
| 4F | 404 | 核验客 `CHECKER` | 不切卡或换装，变更触发 `SWITCHED_NEAR_CHECKER` | 普通门 |
| 4F | 405 | 礼帽客 `HAT` | 当前卡为 `MANAGER`，否则触发 `WRONG_CARD` | 普通门 |
| 5F | 501 | 礼帽客 `HAT` | 当前卡为 `MANAGER`，否则触发 `WRONG_CARD` | 建议房号，待 A 确认 |
| 5F | 502 | 长鼻客 `NOSE` | 当前卡为 `CLEANER`，否则触发 `WRONG_CARD` | 建议房号，待 A 确认 |
| 5F | 503 | 核验客 `CHECKER` | 不切卡或换装，变更触发 `SWITCHED_NEAR_CHECKER` | `TASK_05_EXIT` |
| 5F | 504 | 独眼客 `EYE` | 当前卡为 `SECURITY`，否则触发 `WRONG_CARD` | 建议房号，待 A 确认 |
| 5F | 505 | 大耳客 `EAR` | 停步，移动触发 `MOVED_NEAR_EAR` | 建议房号，待 A 确认 |
| 5F | EXIT | — | — | 完成离店任务后逃脱，无数字房号 |

待 A 确认各门最终位置、间距、检测范围、三段时长和初始相位，以及 309 与 EXIT 的交互坐标。
