# DSH 跨机工作日志

> 每个会话/任务结束后自动追加一条。**最新在底部**。
> 由 skill `dsh-journal-sync` 自动维护，勿手改格式。

## 2026-08-22 18:30 · 初始化
- 做了什么：搭建 dsh-worklog 中心日志仓库；确立跨机工作同步方案（时间+主题+文件+下一步）。
- 涉及文件：README.md、JOURNAL.md、state.json、machines.json
- 下一步：在 GitHub 建空仓库 naiping87/dsh-worklog，登录凭证，把本地首次 push 上去。

## 2026-08-22 19:00 · 新山
- 做了什么：GitHub 建仓并首次 push（remote main=本地 HEAD）；验证 DSH 会自动发现项目根 `.dsh\skills`；把 skill 本体放进仓库 `.dsh/skills/dsh-journal-sync`，本地用 junction 联接到 `~\.dsh\skills`，实现 skill 随 git pull 自动同步；旧"每项目内嵌 PROGRESS.md"方案已弃用。
- 涉及文件：dsh-worklog/.dsh/skills/dsh-journal-sync/SKILL.md、setup_link.cmd、README.md、JOURNAL.md、state.json、machines.json
- 下一步：在 Pontian 那台电脑 clone 本仓库 + 跑 setup_link.cmd + 在 machines.json 配它机名。
