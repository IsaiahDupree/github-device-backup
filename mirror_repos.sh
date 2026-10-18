#!/bin/zsh -l
# Mirror all GitHub repos (bare, all branches/tags) to the Passport drive. Resumable.
BK="/Volumes/My Passport/DEVICE-BACKUP-2026-07-31/repos"
LOG="$BK/../mirror.log"
mkdir -p "$BK"
echo "=== mirror start $(date) ===" >> "$LOG"
gh repo list --limit 1000 --json nameWithOwner -q '.[].nameWithOwner' > "$BK/../repo-list.txt" 2>>"$LOG"
total=$(wc -l < "$BK/../repo-list.txt" | tr -d ' ')
i=0
while IFS= read -r repo; do
  i=$((i+1))
  name=$(echo "$repo" | tr '/' '__')
  dest="$BK/${name}.git"
  if [ -d "$dest" ]; then
    (cd "$dest" && git remote update --prune >/dev/null 2>&1) && echo "[$i/$total] updated $repo" >> "$LOG" || echo "[$i/$total] UPDATE-FAIL $repo" >> "$LOG"
  else
    if git clone --mirror "https://github.com/$repo.git" "$dest" >/dev/null 2>&1; then
      echo "[$i/$total] cloned $repo" >> "$LOG"
    else
      echo "[$i/$total] CLONE-FAIL $repo" >> "$LOG"
    fi
  fi
done < "$BK/../repo-list.txt"
echo "=== mirror done $(date): $i repos ===" >> "$LOG"
