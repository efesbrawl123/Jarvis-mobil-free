#!/usr/bin/env bash
set -euo pipefail

# Unpack the ZIP files uploaded to the GitHub repository root.
# Supports archives that contain either a top-level folder (server/, web/, ...)
# or the folder contents directly.
unpack_project_dir() {
  local archive="$1"
  local target="$2"
  local temp
  temp="$(mktemp -d)"
  if [ ! -f "$archive" ]; then
    echo "Missing $archive in repository root."
    exit 1
  fi
  unzip -oq "$archive" -d "$temp"

  if [ -d "$temp/$target" ]; then
    mkdir -p "$target"
    cp -R "$temp/$target/." "$target/"
  else
    mkdir -p "$target"
    cp -R "$temp/." "$target/"
  fi
  rm -rf "$temp"
}

unpack_project_dir server.zip server
unpack_project_dir web.zip web
unpack_project_dir mobile.zip mobile
unpack_project_dir scripts.zip scripts
unpack_project_dir docs.zip docs

if [ ! -f server/package.json ]; then
  echo "After extraction, server/package.json is still missing."
  echo "Check that server.zip contains the server project files."
  exit 1
fi

if [ ! -f web/package.json ]; then
  echo "After extraction, web/package.json is still missing."
  echo "Check that web.zip contains the web project files."
  exit 1
fi

npm --prefix server install --include=dev
npm --prefix web install --include=dev
npm --prefix web run build
