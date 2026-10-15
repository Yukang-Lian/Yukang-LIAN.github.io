#!/bin/sh
# Build the site and publish it to the main branch, which GitHub Pages serves.
# main always holds a single commit with the current site, so the repo never
# grows with old builds. The source, with its full history, lives on quarto.
#
# Usage: ./deploy.sh ["extra commit message line" ...]
set -e
cd "$(dirname "$0")"

if [ -n "$(git status --porcelain)" ]; then
  echo "Commit your changes first: the deploy is labelled with the source commit." >&2
  exit 1
fi

src=$(git rev-parse --short HEAD)
remote=$(git remote get-url origin)

rm -rf _site
quarto render
# Draft posts still leave tiny placeholder pages behind; don't publish them.
find _site -name '*.html' -size -200c -delete

cd _site
touch .nojekyll
git init -q -b main
git add -A
msg="Deploy quarto@$src"
for line in "$@"; do msg="$msg

$line"; done
git commit -q -m "$msg"
git push -q -f "$remote" main
rm -rf .git
echo "Deployed quarto@$src"
