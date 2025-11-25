@echo off
REM -------------------------------------------------------------
REM push_notes.bat — 一鍵 add + commit + push（適用 Windows）
REM 用法：
REM   直接雙擊，或在命令列執行：
REM     push_notes.bat "你的提交訊息"
REM   若未提供訊息，會使用日期時間作為預設訊息。
REM -------------------------------------------------------------

setlocal ENABLEDELAYEDEXPANSION

REM 以批次檔所在資料夾為 repo 根目錄
set REPO_DIR=%~dp0
cd /d "%REPO_DIR%"

REM 檢查 Git 是否可用
where git >nul 2>&1
if errorlevel 1 (
  echo [Error] 未找到 git 指令，請先安裝 Git 或將其加入 PATH。
  goto :end
)

REM 擷取目前分支名稱
for /f "usebackq tokens=*" %%b in (`git rev-parse --abbrev-ref HEAD 2^>nul`) do set BRANCH=%%b
if "!BRANCH!"=="" (
  echo [Error] 這裡看起來不是一個 Git repo，或尚未建立分支/提交。
  echo        請先執行：git init ^&^& git add -A ^&^& git commit -m "initial commit"
  goto :end
)

REM 設定提交訊息：若未提供參數，使用日期時間
set COMMIT_MSG=%*
if "%COMMIT_MSG%"=="" (
  set COMMIT_MSG=docs: update notes %date% %time%
)

REM 顯示目前狀態
call git status

REM 加入所有變更
call git add -A

REM 建立提交（若沒有變更，略過）
call git commit -m "%COMMIT_MSG%"
if errorlevel 1 (
  echo [Info] 沒有可提交的變更，略過 commit。
)

REM 檢查是否已設定遠端 origin
call git remote show origin >nul 2>&1
if errorlevel 1 (
  echo [Error] 未設定遠端 origin。
  echo        請先執行：git remote add origin https://github.com/<你的帳號>/<repo>.git
  goto :end
)

REM 推送到遠端，若未設定 upstream 則自動加上 -u
call git rev-parse --abbrev-ref --symbolic-full-name @{u} >nul 2>&1
if errorlevel 1 (
  echo [Info] 未設定上游追蹤，使用 -u 推送。
  call git push -u origin !BRANCH!
) else (
  call git push
)

if errorlevel 1 (
  echo [Error] 推送失敗。你可以嘗試：
  echo        git push -u origin HEAD
  goto :end
)

echo [Done] 已推送到遠端：origin/!BRANCH!

:end
endlocal
exit /b 0
