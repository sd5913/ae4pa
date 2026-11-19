# 推送前干净副本验证 · 2026-11-19

- 从暂存树 `26af5b965ece1c2275cb8dbfbf8d56518a15387c` 导出，不带本机 `.godot` 缓存；基线为 `caf862d`。本轮随后只改当前状态文档并追加本验证记录，未改受测运行代码。
- 使用 Godot `4.7.2.stable.official.ed1daf0bf` 在 macOS 全新导入，退出0；30次 headless 检查全部退出0且无脚本／资源错误，命令与结果见 [suite_results.json](suite_results.json)，逐项 stdout/stderr 同目录保留。
- 导出保留上游 `project.godot` 的 stretch/aspect 设置；仅在临时副本加入专用 `application/config/use_custom_user_dir` 与 `application/config/custom_user_dir_name`，隔离语言偏好，不改玩家存档。生产配置原文哈希及运行文件哈希见 [source_sha256.json](source_sha256.json)。
- 此证据取代旧 task03 索引中本机 project.godot 哈希对本次发布配置的证明；旧日志和哈希不回写。没有新增原生截图；原生夹具画面另见 task03、英文UI目录。
- 三份独立只读评审覆盖测试／状态机、对抗逻辑和文档／计划，未发现阻断缺陷；发现的旧状态表已更新。外部模型审查配置为关闭，未发送代码给外部审查。
- 用户201六项和202成功／超时结果保留；30次自动检查不代表03真人、实际240秒等待、Windows、完整309救援／跟随、04／05或完整五层通过。
