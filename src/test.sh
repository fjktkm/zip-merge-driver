#!/bin/bash

# リポジトリの準備
REPO_DIR="example"
if [ -d "$REPO_DIR" ]; then
    rm -rf "$REPO_DIR"
fi
mkdir "$REPO_DIR"
cd "$REPO_DIR"
git init -b main

# カスタムマージドライバの設定
chmod +x /workspaces/zip-merge-driver/src/main.sh
git config merge.zipmerge.name "Custom merge driver for zip files"
git config merge.zipmerge.driver "/workspaces/zip-merge-driver/src/main.sh %O %A %B %P"
echo "*.zip merge=zipmerge" > .gitattributes
git add .gitattributes
git commit -m "Setup custom merge driver for zip files"

# ベースファイルの作成
echo "This is the base file." > testfile.txt
zip content.zip testfile.txt
rm testfile.txt
git add content.zip
git commit -m "Add base zip file content.zip"

# ブランチの作成と変更の適用
git checkout -b branch_local
echo "This is the base file.\nThis modification is from the local branch." > testfile.txt
zip content.zip testfile.txt
rm testfile.txt
git add content.zip
git commit -m "Local changes in content.zip"
git checkout main

echo "This modification is from the remote branch.\nThis is the base file." > testfile.txt
zip content.zip testfile.txt
rm testfile.txt
git add content.zip
git commit -m "Remote changes in content.zip"

# マージの実行
git merge branch_local --no-edit

# 結果の確認
echo "Merge result:"
git status
unzip -o content.zip -d merged
cat merged/testfile.txt

# 後処理
cd ..
echo "Test completed. You can review the merge result in $REPO_DIR."
