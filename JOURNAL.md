# DSH 跨机工作日志

> 每个会话/任务结束后自动追加一条。**最新在底部**。
> 由 skill `dsh-journal-sync` 自动维护，勿手改格式。

## 2026-08-22 01:30-01:48 · terence（补记）
- 做了什么：本机 DeepSeek 视觉排查。① 贴图 image.png（1400×751，2MB，RGBA PNG）问「看的到图吗」，模型 deepseek-v4-flash-vision-exp，连续 4+ 次 400 INVALID_REQUEST `.messages[1].image[0]: unsupported image`（错误来自 DeepSeek API 服务端）；② 排查客户端准入（dsh-attachment / dsh-client-ui-conversation 白名单）与 dsh-llm-deepseek 序列化（imageDataUrl / id 含 vision 才声明 inputModalities）；③ 字节级验证 JPEG（bla6293roadtax2026.jpeg，205,728B，FFD8/FFD9 合法）与 PNG（签名/IHDR 1400×751 RGBA-8bit/30×IDAT/IEND 完整）均合法；④ 用 node 脚本手工解码 zstd 会话档案（8 个会话）还原失败现场；⑤ 确认官方 Vision 文档支持 JPEG/PNG/GIF/WebP（按内容检测）、模型 2026-08-21 上线（news260821）。**结论未定论**：文件与模型选择均正常、请求已到 API 才被拒，疑似服务端问题或 RGBA PNG 变体不被其解码器接受。
- 涉及文件：deepseek-vision-guide.md、vision-read-result.md、read-image-ocr.ps1、.dsh/tmp/{decode-session,inspect-sessions,listdir,png-parse}.js（均在本机工作区 C:\Users\ediso\OneDrive\Documents\harness）
- 下一步：验证 vision-exp 对 RGBA PNG 的原生支持 / 或走 ModLens+Gemini（08-19 已配）/ 或试社区 deepseek-vision-gateway

## 2026-08-22 18:30 · 初始化
- 做了什么：搭建 dsh-worklog 中心日志仓库；确立跨机工作同步方案（时间+主题+文件+下一步）。
- 涉及文件：README.md、JOURNAL.md、state.json、machines.json
- 下一步：在 GitHub 建空仓库 naiping87/dsh-worklog，登录凭证，把本地首次 push 上去。

## 2026-08-22 19:00 · 新山
- 做了什么：GitHub 建仓并首次 push（remote main=本地 HEAD）；验证 DSH 会自动发现项目根 `.dsh\skills`；把 skill 本体放进仓库 `.dsh/skills/dsh-journal-sync`，本地用 junction 联接到 `~\.dsh\skills`，实现 skill 随 git pull 自动同步；旧"每项目内嵌 PROGRESS.md"方案已弃用。
- 涉及文件：dsh-worklog/.dsh/skills/dsh-journal-sync/SKILL.md、setup_link.cmd、README.md、JOURNAL.md、state.json、machines.json
- 下一步：在 Pontian 那台电脑 clone 本仓库 + 跑 setup_link.cmd + 在 machines.json 配它机名。

## 2026-08-26 01:22 · terence
- 做了什么：terence 机接入 dsh-worklog 同步。克隆仓库到本机工作区（C:\Users\ediso\OneDrive\Documents\harness\dsh-worklog），按 skill 规范把 08-22 凌晨视觉排查补记入本日志、更新 state.json 并 push；同时整理出「全新 dsh 机器接入」指引。另：本机 pwsh 曾持续 0xC0000142（STATUS_DLL_INIT_FAILED）崩溃、数日后自行恢复，期间以文件工具+node 脚本绕过。
- 涉及文件：JOURNAL.md、state.json
- 下一步：第三台（全新 dsh）照 README/SKILL 接入：装 git 并登录 GitHub 凭证 → clone 统一路径 → 跑 setup_link.cmd → machines.json 补该机名；接入后按「开工 pull+读 / 收尾写+push」日常同步。
