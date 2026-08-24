---
name: dsh-journal-sync
description: "跨机 DSH 工作追逆中心。用专属 GitHub 仓库 dsh-worklog 当共享日志：会话/任务结束时自动追加一条『时间+地点/哪台机+做了什么+涉及文件+下一步』到 JOURNAL.md 并更新 state.json，push 到 GitHub 的 main；另一台电脑（新山/Pontian 等）开工时 DSH 自动 pull 并读取这批日志当作上下文，就能知道对面做了什么、做到哪，无需反复对话。命中『看看另一边做了什么/上次做到哪/记录今天进度/同步进度/追逆/继续上次/做了什么』等说法，或某次 DSH 会话结束且要跨机可追时，直接套用本技能。skill 本体随仓库 .dsh\\skills 目录经 GitHub 同步（本机通过 junction 联接），git pull 即更新。只修改 JOURNAL.md 与 state.json，绝不 add/commit 用户其它文件，绝不推机密。"
---

# 跨机 DSH 工作追逆（中心日志仓库）

解决"在两台电脑（如新山、Pontian）各自用 DSH 干活，另一台不知道对面做了啥、没法追逆"的问题。用**一个专属 GitHub 仓库 `naiping87/dsh-worklog`** 当两端的共享记事本，DSH 自动写、自动读。

## 已确认的约定

| 项 | 取值 |
|---|---|
| 类型 | **中心统一日志**（把 DSH 里做的一切，含不在 git 仓库的散文件工作，都记成可追逆条目） |
| 中心仓库 | `naiping87/dsh-worklog`（private；本地路径两端统一） |
| 分支 | `main` |
| 记录内容 | 时间 + 地点/哪台机 + 做了什么 + 涉及文件 + 下一步 |
| 读取 | 另一台机 DSH **开工自动 pull+读**当上下文 |
| 触发 | 每次会话/任务结束自动记一条并 push |

> 现状（2026-08-22 已打通）：本地仓库已建好并 **push 成功**（远端 main = 本地 HEAD）。凭证走系统级 Git Credential Manager（`credential.helper=manager`）。skill 本体已放仓库 `.dsh/skills/dsh-journal-sync/SKILL.md`，本机 `~\.dsh\skills\dsh-journal-sync` 由 junction 指向它。

## 中心仓库路径（两端必须一致）

默认：`C:\Users\User\Documents\deep seek harness\dsh-worklog`
（是一个可 push 的 git 仓库；skill 通过 `git -C <repo> ...` 定位。若两端工作区路径不同，以实际为准。）

### 文件

- `JOURNAL.md` — 人读，逐条追加，最新在底部，用 `## 时间 · 地点` 分节。
- `state.json` — 机读，始终覆盖为最新一条（`repo/branch/updated_at/machine/summary/files/next_steps`）。
- `machines.json` — 各机器/地点昵称，用于标注条目是哪台机做的。
- `.dsh/skills/dsh-journal-sync/SKILL.md` — **本 skill 自身**（随仓库同步）。
- `setup_link.cmd` — 每台机一次性设置：把 `~\.dsh\skills\dsh-journal-sync` 联接( junction )到仓库内 skill。

## 触发原则

- **自动（常驻）**：本次会话/任务在 DSH 里有实质产出（改了文件、做了分析、完成了事）时，**收尾自动**执行「记录进度」并 push，无需用户开口。
- **主动**：用户说"看看另一边做了什么 / 上次做到哪 / 记录今天进度 / 同步进度 / 追逆 / 继续上次 / 做了什么"时，执行对应步骤。
- **前置**：确认 `dsh-worklog` 是 git 仓库（`git -C <repo> rev-parse --show-toplevel`）。否则暂停并向用户说明。

## 开工（任一机器，会话开始自动执行）

```powershell
$r = "C:\Users\User\Documents\deep seek harness\dsh-worklog"
git -C $r fetch origin main 2>$null
git -C $r pull --rebase --autostash origin main 2>$null   # 拉另一端写的最新日志（skill 文件一并更新）
# 读 JOURNAL.md 末尾几条 + state.json
```

然后向用户汇报：**上次是哪台机、几点、做了什么、涉及哪些文件、下一步是什么**，并把它作为本次工作的上下文使用。

## 收尾（会话结束自动执行）

先在 `dsh-worklog` 里用 read/write 改两个文件：

1. 读 `JOURNAL.md`（不存在则创建），**末尾**追加：
   ```
   ## <YYYY-MM-DD HH:MM> · <地点/机名>
   - 做了什么：...
   - 涉及文件：...（路径，尽量完整；非 git 散文件也写）
   - 下一步：...
   ```
2. 整体覆盖 `state.json`：
   ```json
   {
     "repo": "naiping87/dsh-worklog",
     "branch": "main",
     "updated_at": "<yyyy-MM-dd HH:mm>",
     "machine": "<地点/机名>",
     "summary": "...",
     "files": ["..."],
     "next_steps": ["..."]
   }
   ```

然后提交推送：

```powershell
git -C $r add JOURNAL.md state.json           # 只加这两个！绝不 `git add .` / `-A`
git -C $r commit -m "journal: $(Get-Date -Format '%Y-%m-%d %H:%M') <一句话>"
git -C $r pull --rebase --autostash origin main
git -C $r push origin main
```

## 安全规则（必须遵守）

- 只改/只 `git add` `JOURNAL.md` 与 `state.json`。**绝不** `git add .` / `-A` / `commit -am`，绝不顺带提交用户其它文件。
- 绝不把密码/ token/ key/ 恢复码写入这两个文件（会被推到 GitHub）。
- **非 fast-forward / 认证失败 / 冲突**：停下向用户报告（按 `network-tls-fix` 先诊断网络层；认证问题提示用户配置 GitHub 凭证），**不要 `--force`、不要重试、不要伪造提交**。
- `machines.json` 只在配置机器昵称时改，正常工作不碰。

## 每台电脑设置（一次性）

### 新山这台（已完成，2026-08-22）
- 仓库：`C:\Users\User\Documents\deep seek harness\dsh-worklog`，`origin` + `push -u origin main` 成功。
- skill 联接：`~\.dsh\skills\dsh-journal-sync` → 仓库 `.dsh/skills/dsh-journal-sync`（junction，已建）。
- 凭证：系统级 Git Credential Manager（`credential.helper=manager`）。

### 另一台电脑（如 Pontian）

1. 确认同一 GitHub 账号已在该机 GCM 登录：
   ```powershell
   git ls-remote https://github.com/naiping87/dsh-worklog.git   # 有输出即通
   ```
2. clone 到相同路径：
   ```powershell
   git clone https://github.com/naiping87/dsh-worklog.git "C:\Users\User\Documents\deep seek harness\dsh-worklog"
   ```
3. 建 skill 联接（使 DSH 自动发现仓库内 skill）：
   ```powershell
   cmd /c ""C:\Users\User\Documents\deep seek harness\dsh-worklog\setup_link.cmd""
   ```
   （或手动：`mklink /J "%USERPROFILE%\.dsh\skills\dsh-journal-sync" "<仓库>\.dsh\skills\dsh-journal-sync"`）
4. 在那台的 `machines.json` 补上该机地点名（如 `"Pontian": {"alias": "笨珍", "enabled": true}`），改后 commit + push 云端一回。

> 之后所有更新（含 SKILL.md 本身）都随 `git pull` 自动到达，无需再拷贝任何文件。

## 环境注意（本机）

- git 已配 `http.sslBackend=openssl`，push 走 OpenSSL。
- 若报 `schannel SEC_E_NO_CREDENTIALS` / `HTTP 000` / `could not read Username` → 先按 `network-tls-fix` 诊断；确认是认证问题则提示用户 `gh auth login` 或配 PAT。
- DSH 的 skill 发现：`~\.dsh\skills`（用户级，恒扫描）优先级低于项目级 `<cwd所在git仓库>\.dsh\skills`，本 skill 两处最终指向同一文件，无冲突。

## 变更

- 2026-08-22 初版：中心统一日志方案（替换早前"每项目内嵌 PROGRESS.md"版）
- 2026-08-22 v2：skill 本体随仓库 `.dsh/skills` 同步，本机 junction 联接，全自动免拷贝
