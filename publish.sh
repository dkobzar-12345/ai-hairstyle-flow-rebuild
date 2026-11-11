#!/bin/bash
# Publishes this folder as a PUBLIC GitHub repo with Pages. Run from inside the folder.
# Creates the repo on first run; on later runs commits and pushes the update.
set -e
REPO="ai-hairstyle-flow-rebuild"
NAME="Hairstyle Try On"
OWNER=$(gh api user --jq .login)
echo "This will publish $OWNER/$REPO as a PUBLIC repo on GitHub Pages."
read -p "Continue? (y/n) " ok; [ "$ok" = "y" ] || exit 1
[ -d .git ] || git init -q
git branch -M main
git add -A
git diff --cached --quiet || git commit -qm "Growth Audit - $NAME"
if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  git remote get-url origin >/dev/null 2>&1 || git remote add origin "https://github.com/$OWNER/$REPO.git"
  git push -q -u origin main
else
  gh repo create "$REPO" --public --source=. --push \
    --description "Growth Audit - $NAME. Five ranked ideas plus a clickable prototype of their onboarding and paywall, rebuilt in their own design."
fi
gh api "repos/$OWNER/$REPO/pages" >/dev/null 2>&1 || gh api -X POST "repos/$OWNER/$REPO/pages" -f "source[branch]=main" -f "source[path]=/" >/dev/null
gh repo edit "$OWNER/$REPO" --homepage "https://$OWNER.github.io/$REPO/" \
  --description "Growth Audit - $NAME. Five ranked ideas plus a clickable prototype of their onboarding and paywall, rebuilt in their own design."
echo "Done: https://$OWNER.github.io/$REPO/  (Pages takes 1-2 minutes)"
