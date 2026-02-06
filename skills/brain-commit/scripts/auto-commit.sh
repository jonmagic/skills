#!/bin/bash
# Auto-commit Brain changes using Claude for semantic commits
# Runs hourly via cron as a safety net

BRAIN_DIR="$HOME/Brain"
LOG_FILE="$HOME/.local/log/brain-auto-commit.log"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")"

cd "$BRAIN_DIR" || exit 1

# Only run if there are uncommitted changes
if [ -n "$(git status --porcelain)" ]; then
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Changes detected, running /bc" >> "$LOG_FILE"
  /opt/homebrew/bin/claude -p "Run /bc to commit any uncommitted changes" >> "$LOG_FILE" 2>&1
  echo "$(date '+%Y-%m-%d %H:%M:%S') - Done" >> "$LOG_FILE"
else
  echo "$(date '+%Y-%m-%d %H:%M:%S') - No changes" >> "$LOG_FILE"
fi
