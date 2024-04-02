#!/bin/bash

# 引数の定義
BASE=$1
LOCAL=$2
REMOTE=$3
MERGED=$4

# 一時ディレクトリの作成
WORKDIR=$(mktemp -d)
echo "Working in $WORKDIR"

# 一時リポジトリの作成
REPO_DIR="$WORKDIR/repo"
mkdir "$REPO_DIR"
cd "$REPO_DIR"
git init -b main > /dev/null

# BASE zipの内容をコミット
unzip -q "$BASE" -d "$REPO_DIR"
git add . > /dev/null
git commit -m "Base" > /dev/null

# LOCALの変更を新しいブランチにコミット
git checkout -b local > /dev/null
rm -rf "$REPO_DIR"/*  # Clean current directory
unzip -q "$LOCAL" -d "$REPO_DIR"
git add . > /dev/null
git commit -m "Local" > /dev/null

# REMOTEの変更をmainブランチにコミット
git checkout main > /dev/null
rm -rf "$REPO_DIR"/*  # Clean current directory
unzip -q "$REMOTE" -d "$REPO_DIR"
git add . > /dev/null
git commit -m "Remote" > /dev/null

# マージ実行
git merge local --no-ff -m "Merged" > /dev/null 2>&1

# 競合のチェック
if [ "$(git ls-files -u | wc -l)" -gt 0 ]; then
    echo "Conflict detected. Please resolve conflicts in $REPO_DIR."
    exit 1
else
    # 成功した場合、最終的なzipを作成
    git archive -o "$MERGED" HEAD
fi

# 作業ディレクトリの削除
rm -rf "$WORKDIR"
