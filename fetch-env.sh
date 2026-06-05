#!/bin/bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./fetch-env.sh [package[:tag]]

Downloads the encrypted env OCI artifact, decrypts .sops.env with the local
SOPS age key, and atomically writes .env in the project root.

Defaults:
  package: ghcr.io/dupmachine/docker-apps--$(hostname -s | lowercase)
  tag:     ${DOCKER_APPS_ENV_TAG:-latest}
  output:  ${DOCKER_APPS_ENV_OUTPUT:-.env}

Environment:
  DOCKER_APPS_ENV_PACKAGE  Override the default package without passing an arg.
  DOCKER_APPS_ENV_TAG      Tag used when package has no tag. Defaults to latest.
  DOCKER_APPS_ENV_OUTPUT   Output dotenv path. Defaults to .env.
  SOPS_AGE_KEY_FILE        Optional explicit SOPS age private key path.

Requirements:
  oras
  sops
USAGE
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "Missing required command: $command_name" >&2
    exit 1
  fi
}

normalize_ref() {
  local ref="$1"
  local tag="${DOCKER_APPS_ENV_TAG:-latest}"
  local last_segment="${ref##*/}"

  if [[ "$last_segment" == *:* ]]; then
    printf '%s\n' "$ref"
  else
    printf '%s:%s\n' "$ref" "$tag"
  fi
}

default_package() {
  local host_name

  host_name="$(hostname -s | tr '[:upper:]' '[:lower:]')"
  printf 'ghcr.io/dupmachine/docker-apps--%s\n' "$host_name"
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 1 ]]; then
  usage >&2
  exit 1
fi

require_command oras
require_command sops

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
package="${1:-${DOCKER_APPS_ENV_PACKAGE:-$(default_package)}}"
ref="$(normalize_ref "$package")"
output="${DOCKER_APPS_ENV_OUTPUT:-$script_dir/.env}"
output_dir="$(dirname "$output")"
output_base="$(basename "$output")"
tmp_dir="$(mktemp -d)"
mkdir -p "$output_dir"
tmp_output="$(mktemp "$output_dir/.${output_base}.tmp.XXXXXX")"

cleanup() {
  rm -rf "$tmp_dir"
  rm -f "$tmp_output"
}
trap cleanup EXIT

echo "Pulling encrypted env: $ref"
oras pull --output "$tmp_dir" "$ref"

encrypted_env="$tmp_dir/.sops.env"
if [[ ! -f "$encrypted_env" ]]; then
  echo "Downloaded artifact does not contain .sops.env" >&2
  exit 1
fi

echo "Decrypting env to: $output"
sops decrypt "$encrypted_env" > "$tmp_output"
chmod 600 "$tmp_output"
mv "$tmp_output" "$output"
trap - EXIT
rm -rf "$tmp_dir"

echo "Updated: $output"
