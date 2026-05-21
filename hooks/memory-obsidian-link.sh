#!/bin/bash
# Auto-create Obsidian symlink for Claude memory directory at session start.
# Runs async so it never blocks the session.
PROJECT_DIR="$(pwd)"
PROJECT_NAME="$(basename "$PROJECT_DIR")"
PROJECT_HASH="$(echo "$PROJECT_DIR" | tr '/' '-')"
MEMORY_DIR="$HOME/.claude/projects/$PROJECT_HASH/memory"
OBSIDIAN_DIR="$HOME/Documents/obsidian-vault/03_Logs/claude"
OBSIDIAN_LINK="$OBSIDIAN_DIR/$PROJECT_NAME"

mkdir -p "$MEMORY_DIR" "$OBSIDIAN_DIR"
[ ! -e "$OBSIDIAN_LINK" ] && ln -sf "$MEMORY_DIR" "$OBSIDIAN_LINK"
