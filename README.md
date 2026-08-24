# dsh-worklog —— 跨机 DSH 工作日志中心

让多台电脑（新山 / Pontian ...）共享同一份 DSH 工作记录，互相能追逆"哪台机器、什么时候、做了什么、做到哪、下一步"。

## 起因
在不同电脑上用 DSH 干活，另一台完全不知道对面做了啥，没法追逆，既容易重复又得反复对话。

## 文件说明

| 文件 | 内容 | 使用者 |
|---|---|---|
| `JOURNAL.md` | 按时间顺序的会话日志（人读） | 人 + DSH |
| `state.json` | 最新一条机器可读状态（机读） | DSH |
| `machines.json` | 各机器/地点的昵称与启用开关 | 人配置 |
| `.dsh/skills/dsh-journal-sync/SKILL.md` | 本工作流 skill 自身 | DSH（随仓库同步） |
| `setup_link.cmd` | 每台机一次性设置（建 skill 联接） | 人运行 |

## skill 的同步机制（免手动拷贝）

DSH 会扫描 `~\.dsh\skills`（用户级，任何会话都生效）。把该目录下的
`dsh-journal-sync` 做成 **junction 联接到本仓库** `.dsh/skills/dsh-journal-sync`：
文件只有仓库内一份，`git pull` 即更新，两端永远一致。每台电脑跑一次
`setup_link.cmd` 即可（或手动 `mklink /J`）。

## 工作方式（两端一致）

- **开工前**：`git pull --rebase --autostash origin main` → 读 `JOURNAL.md` 尾 + `state.json` → 报告上次在哪台机做到哪、下一步是什么，并作为本次上下文。
- **收尾时**：追加一条到 `JOURNAL.md` + 更新 `state.json` → `git add JOURNAL.md state.json` → `git pull --rebase --autostash` → `git push origin main`。

## 条目格式

```
## 2026-08-22 18:00 · 新山
- 做了什么：...
- 涉及文件：...
- 下一步：...
```
