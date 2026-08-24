@echo off
REM ============================================================
REM  dsh-worklog 一次性设置脚本（每台电脑跑一次）
REM  作用：把 DSH 用户级 skill 目录 ~\.dsh\skills\dsh-journal-sync
REM        联接(junction)到本仓库 .dsh\skills\dsh-journal-sync
REM  之后 git pull 仓库即可自动更新 skill，无需手动拷贝。
REM ============================================================
setlocal
set "TARGET=%~dp0.dsh\skills\dsh-journal-sync"
set "LINK=%USERPROFILE%\.dsh\skills\dsh-journal-sync"

if not exist "%TARGET%\SKILL.md" (
  echo [ERROR] 仓库内未找到 SKILL.md：%TARGET%
  exit /b 1
)
if exist "%LINK%\SKILL.md" (
  echo [SKIP] 目标已存在：%LINK%
  echo        若它是旧的手拷副本，请先删除该目录再重跑本脚本。
  exit /b 0
)
if not exist "%USERPROFILE%\.dsh\skills" mkdir "%USERPROFILE%\.dsh\skills"
mklink /J "%LINK%" "%TARGET%"
if exist "%LINK%\SKILL.md" (
  echo [OK] 联接成功：%LINK% 指向  %TARGET%
) else (
  echo [FAIL] 联接失败，请手工检查路径或权限。
)
