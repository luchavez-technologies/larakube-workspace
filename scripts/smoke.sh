#!/usr/bin/env bash
# Starts a workspace image the way LaraKube CLI runs it and checks that the editor answers
# and the runtime's toolchain is there.
#   scripts/smoke.sh <image> <runtime>
set -euo pipefail

image="${1:?image}"
runtime="${2:?runtime}"
name="ws-smoke-$$"
port="${SMOKE_PORT:-18090}"
key_dir="$(mktemp -d)"
trap 'docker rm -f "$name" >/dev/null 2>&1 || true; rm -rf "$key_dir"' EXIT

echo fake > "$key_dir/deploy-key"
chmod 644 "$key_dir/deploy-key"

docker run -d --name "$name" -p "$port:8080" -v "$key_dir:/etc/workspace:ro" \
  -e PASSWORD=smoke -e HOME=/home/coder -e WORKSPACE_REPO= -e WORKSPACE_BRANCH=main \
  -e GIT_AUTHOR_NAME=Smoke -e GIT_AUTHOR_EMAIL=smoke@example.com \
  "$image" /bin/bash -c 'mkdir -p ~/.ssh ~/project && exec code-server --bind-addr 0.0.0.0:8080 --auth password ~/project' >/dev/null

for _ in $(seq 1 60); do
  if [ "$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$port/healthz")" = "200" ]; then
    healthy=1
    break
  fi
  sleep 2
done

if [ "${healthy:-0}" != "1" ]; then
  echo "editor did not answer /healthz" >&2
  docker logs "$name" >&2
  exit 1
fi

check() {
  docker exec "$name" bash -lc "$1" >/dev/null || { echo "missing: $1" >&2; exit 1; }
}

check 'test "$(id -u)" = 1000'
check 'git --version'
check 'code-server --version'

case "$runtime" in
  php) check 'php -v && composer --version && node -v && php -m | grep -q pdo_pgsql' ;;
  node) check 'node -v && npm -v' ;;
  python) check 'python3 --version && pip --version' ;;
  java) check 'java -version' ;;
  dotnet) check 'dotnet --version' ;;
  go) check 'go version' ;;
  rust) check 'cargo --version' ;;
  *) echo "unknown runtime $runtime" >&2; exit 1 ;;
esac

echo "ok: $image"
