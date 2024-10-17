#!/bin/bash

GITHUB_TOKEN="$1"
REPO_SOURCE_PATH="C:/0/vc/dev/Projects/Inder/Source/FileManager"
REPO_TARGET_PATH="C:/0/vc/dev/Projects/Inder/ZielOrdner"
REPO_TARGET_URL="https://${GITHUB_TOKEN}@github.com/tomsandt/TestRepo.git"

if [ ! -d "$REPO_SOURCE_PATH" ]; then # -d --> is file?
    echo "Error: Source-Repository ($REPO_SOURCE_PATH) does not exist."
    exit 1 # 1 --> error code
fi

if [ ! -d "$REPO_TARGET_PATH" ]; then
    echo "Error: Target-Repository ($REPO_TARGET_PATH) does not exist."
    exit 1
fi
cd "$REPO_SOURCE_PATH" || exit

git fetch --all

CHANGES_FOUND=false

for BRANCH in $(git branch -r | grep -v '\->' | grep -o 'origin/.*' | sed 's/origin\///'); do
    echo "Processing branch: $BRANCH"

    LOCAL_HASH=$(git rev-parse HEAD)
    REMOTE_HASH=$(git rev-parse "origin/$BRANCH")

    if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
        echo "Changes found in branch $BRANCH..."
        git checkout -B "$BRANCH" "origin/$BRANCH"
        CHANGES_FOUND=true
    fi
done

if [ "$CHANGES_FOUND" = true ]; then
    echo "Pushing all changes..."
    rm -rf "$REPO_TARGET_PATH"
    cp -r "$REPO_SOURCE_PATH" "$REPO_TARGET_PATH" # -r --> recursive (everything selected)

    cd "$REPO_TARGET_PATH" || exit

    git remote set-url origin "$REPO_TARGET_URL"
    git push -f origin --all
fi
