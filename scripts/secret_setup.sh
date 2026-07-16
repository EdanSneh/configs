#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_SECRETS="$HOME/.zshrc.local"

echo "=== Secret Setup ==="
echo ""

# Ensure ~/.zshrc.local exists
if [ ! -f "$LOCAL_SECRETS" ]; then
  cp "$REPO_DIR/zshrc.local.template" "$LOCAL_SECRETS"
  echo "Created ~/.zshrc.local from template."
  echo ""
fi

# Helper: check if a var has a real (non-placeholder) value in ~/.zshrc.local
has_real_value() {
  local var="$1" placeholder="$2"
  local line
  line=$(grep "^export ${var}=" "$LOCAL_SECRETS" 2>/dev/null || true)
  [ -n "$line" ] || return 1
  local value
  value=$(echo "$line" | sed 's/^export [^=]*="\(.*\)"$/\1/')
  [ "$value" != "$placeholder" ] && [ -n "$value" ]
}

# Helper: replace or append a var in ~/.zshrc.local
set_var() {
  local var="$1" value="$2"
  local tmp
  tmp=$(mktemp)
  if grep "^export ${var}=" "$LOCAL_SECRETS" >/dev/null 2>&1; then
    sed "s|^export ${var}=.*|export ${var}=\"${value}\"|" "$LOCAL_SECRETS" > "$tmp"
  else
    cp "$LOCAL_SECRETS" "$tmp"
    echo "export ${var}=\"${value}\"" >> "$tmp"
  fi
  mv "$tmp" "$LOCAL_SECRETS"
}

# --- GITLAB_TOKEN ---
setup_gitlab() {
  if has_real_value "GITLAB_TOKEN" "glpat-your-token-here"; then
    echo "[GITLAB_TOKEN] already set in ~/.zshrc.local, skipping."
    return
  fi

  echo "GITLAB_TOKEN — used for uv package indexing"
  echo "  Generate at: https://gitlab.com/-/user_settings/personal_access_tokens"
  echo "  Required scope: read_api"
  printf "  Paste token (Enter to skip): "
  read -rs token
  echo ""

  if [ -z "$token" ]; then
    echo "  [GITLAB_TOKEN] skipped — add it to ~/.zshrc.local later."
  else
    set_var "GITLAB_TOKEN" "$token"
    echo "  [GITLAB_TOKEN] saved to ~/.zshrc.local."
  fi
  echo ""
}

# --- GITHUB_TOKEN ---
setup_github() {
  local had_real=false
  if has_real_value "GITHUB_TOKEN" "ghp-your-token-here"; then
    had_real=true
    echo "[GITHUB_TOKEN] already set in ~/.zshrc.local."
  else
    echo "GITHUB_TOKEN — used for git push over HTTPS"
    echo "  Generate at: https://github.com/settings/tokens"
    echo "  Required scope: repo"
    printf "  Paste token (Enter to skip): "
    read -rs token
    echo ""

    if [ -z "$token" ]; then
      echo "  [GITHUB_TOKEN] skipped — add it to ~/.zshrc.local later."
      echo ""
      return
    fi

    set_var "GITHUB_TOKEN" "$token"
    echo "  [GITHUB_TOKEN] saved to ~/.zshrc.local."
  fi

  # Configure git credential store whenever we have a real GITHUB_TOKEN
  local gh_token
  gh_token=$(grep '^export GITHUB_TOKEN=' "$LOCAL_SECRETS" 2>/dev/null | sed 's/^export GITHUB_TOKEN="\(.*\)"$/\1/' || true)
  if [ -n "$gh_token" ] && [ "$gh_token" != "ghp-your-token-here" ]; then
    git config --global credential.helper store

    # Remove any gh auth git-credential helpers that can interfere
    git config --global --unset-all credential.https://github.com.helper 2>/dev/null || true
    git config --global --unset-all credential.https://gist.github.com.helper 2>/dev/null || true

    printf 'https://x-access-token:%s@github.com\n' "$gh_token" > "$HOME/.git-credentials"
    chmod 600 "$HOME/.git-credentials"
    echo "  Git credential store configured (~/.git-credentials)."
  fi
  echo ""
}

setup_gitlab
setup_github

echo "=== Secret setup complete ==="
