#!/bin/bash

set -euo pipefail

# ====================================================================
# AI ORBIT — Flutter Web Vercel Deployment Script
# Adapted from React deployment pipeline for Flutter Web + 3D Universe
# ====================================================================

# Default to "spectrum" or override via environment / first argument
VERCEL_PROD_PROJECT="${1:-spectrum}"
VERCEL_SCOPE="spectrums-projects-56be2013"

SOURCE_DIR="$(pwd)"
DEPLOY_DIR="$(mktemp -d "${TMPDIR:-/tmp}/vercel-deploy-XXXXXX")"

to_windows_path() {
  if command -v cygpath >/dev/null 2>&1; then
    cygpath -w "$1"
  else
    printf '%s\n' "$1"
  fi
}

SOURCE_COPY_PATH="$(to_windows_path "$SOURCE_DIR")"
DEPLOY_COPY_PATH="$(to_windows_path "$DEPLOY_DIR")"

VERCEL_SCOPE_ARGS=()
if [ -n "$VERCEL_SCOPE" ]; then
  VERCEL_SCOPE_ARGS=(--scope "$VERCEL_SCOPE")
fi

deploy_to_project() {
  local project="$1"
  local label="$2"

  echo "🔗 Linking temporary directory to $label Vercel project: $project"
  vercel link --yes --project "$project" "${VERCEL_SCOPE_ARGS[@]}"

  echo "🚀 Deploying $label from temporary directory..."
  vercel deploy --prod "${VERCEL_SCOPE_ARGS[@]}"
}

# --- Step 1: Build Flutter Web Locally ---
echo "⚡ [Flutter] Fetching dependencies..."
flutter pub get

echo "📦 [Flutter] Compiling Web Release bundle..."
flutter build web --release --no-tree-shake-icons

echo "🌌 [Flutter] Syncing 3D universe assets..."
if [ -f "web/universe.html" ]; then
  cp web/universe.html build/web/universe.html
  echo "✅ universe.html copied to build/web/."
fi

# --- Step 2: Create Clean Deployment Directory ---
echo "📂 Creating temporary deployment copy..."
echo "Source: $SOURCE_DIR"
echo "Temp:   $DEPLOY_DIR"

set +e
# Copy project excluding dev junk and heavy native mobile folders
# Note: build/web is PRESERVED so Vercel can deploy the prebuilt Flutter bundle directly!
MSYS_NO_PATHCONV=1 robocopy "$SOURCE_COPY_PATH" "$DEPLOY_COPY_PATH" /MIR \
  /XD .git .dart_tool .idea .vscode android ios linux macos windows test \
  /XF .env .env.* .env *.env. .local npm-debug.log* yarn-debug.log* \
  /NFL /NDL /NJH /NJS /NP
ROBOCOPY_EXIT=$?
set -e

if [ "$ROBOCOPY_EXIT" -ge 8 ]; then
  echo "❌ Robocopy failed with exit code $ROBOCOPY_EXIT."
  exit "$ROBOCOPY_EXIT"
fi

# --- Step 3: Deploy to Vercel ---
cd "$DEPLOY_DIR"

deploy_to_project "$VERCEL_PROD_PROJECT" "production"

# --- Step 4: Sync Git Repository ---
cd "$SOURCE_DIR"
CURRENT_BRANCH="$(git branch --show-current 2>/dev/null || echo "fea/ai")"
echo "🔄 Syncing Git branch: $CURRENT_BRANCH..."

git add .
git commit -m "fix: latest deployment updates" || echo "No changes to commit."
git pull origin "$CURRENT_BRANCH" --rebase || true
git push origin "$CURRENT_BRANCH"

echo "🎉 Deployment to Vercel project '$VERCEL_PROD_PROJECT' completed successfully!"
