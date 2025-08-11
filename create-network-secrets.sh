#!/usr/bin/env bash
set -euo pipefail

# ===== Config (override by env) =====
NETWORK_NAME="${NETWORK_NAME:-net1}"
SUBNET="${SUBNET:-10.10.1.0/24}"

JWT_SECRET_FILE="jwt_secret.txt"
JWT_ISSUER_FILE="jwt_issuer.txt"
JWT_AUDIENCE_FILE="jwt_audience.txt"
CONN_STR_FILE="connection_string.txt"

# You can override values via env before running, e.g.:
#   JWT_ISSUER="https://issuer.example.com" JWT_AUDIENCE="my-app" bash setup-secrets.sh
JWT_SECRET_VAL="${JWT_SECRET:-}"
JWT_ISSUER_VAL="${JWT_ISSUER:-}"
JWT_AUDIENCE_VAL="${JWT_AUDIENCE:-}"
CONNECTION_STRING_VAL="${CONNECTION_STRING:-}"

# ===== Helpers =====
need_cmd() { command -v "$1" >/dev/null 2>&1 || { echo "Required command '$1' not found."; exit 1; }; }

rand_hex() { openssl rand -hex "${1:-32}"; }
rand_token() { openssl rand -base64 "${1:-32}" | tr -dc 'A-Za-z0-9._-'; }

write_file_secure() {
  local path="$1" val="$2"
  umask 177
  printf '%s' "$val" > "$path"
}

create_or_replace_secret() {
  local name="$1" file="$2"
  if docker secret inspect "$name" >/dev/null 2>&1; then
    echo "Secret '$name' exists → removing to replace..."
    docker secret rm "$name" >/dev/null
  fi
  docker secret create "$name" "$file" >/dev/null
  echo "Secret '$name' created."
}

ensure_swarm_active() {
  local state
  state="$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null || true)"
  if [[ "$state" != "active" ]]; then
    echo "ERROR: Docker Swarm is not active on this node."
    echo "Run:  docker swarm init  (یا با --advertise-addr <IP> در صورت چند اینترفیس)"
    exit 1
  fi
}

create_overlay_network() {
  local name="$1" subnet="$2"
  if docker network ls --format '{{.Name}}' | grep -Fxq "$name"; then
    echo "Network '$name' already exists. Skipping creation."
    return 0
  fi
  docker network create \
    --driver overlay \
    --attachable \
    --subnet "$subnet" \
    "$name" >/dev/null
  echo "Overlay network '$name' created with subnet '$subnet'."
}

# ===== Preflight =====
need_cmd docker
need_cmd openssl
ensure_swarm_active

# ===== Generate values (if not provided) =====
if [[ -z "$JWT_SECRET_VAL" ]]; then
  JWT_SECRET_VAL="$(rand_hex 64)"  # strong hex secret
fi
if [[ -z "$JWT_ISSUER_VAL" ]]; then
  JWT_ISSUER_VAL="issuer-$(rand_token 16)"
fi
if [[ -z "$JWT_AUDIENCE_VAL" ]]; then
  JWT_AUDIENCE_VAL="audience-$(rand_token 16)"
fi
if [[ -z "$CONNECTION_STRING_VAL" ]]; then
  # sensible default; override via env CONNECTION_STRING if you have a real DSN
  PASS="$(rand_token 16)"
  CONNECTION_STRING_VAL="postgresql://postgres:${PASS}@postgres:5432/sol"
fi

# ===== Write files securely =====
write_file_secure "$JWT_SECRET_FILE"      "$JWT_SECRET_VAL"
write_file_secure "$JWT_ISSUER_FILE"      "$JWT_ISSUER_VAL"
write_file_secure "$JWT_AUDIENCE_FILE"    "$JWT_AUDIENCE_VAL"
write_file_secure "$CONN_STR_FILE"        "$CONNECTION_STRING_VAL"

echo "Secret files written:"
echo "  $JWT_SECRET_FILE"
echo "  $JWT_ISSUER_FILE"
echo "  $JWT_AUDIENCE_FILE"
echo "  $CONN_STR_FILE"

# ===== Create (or replace) Docker secrets =====
create_or_replace_secret "jwt_secret"        "$JWT_SECRET_FILE"
create_or_replace_secret "jwt_issuer"        "$JWT_ISSUER_FILE"
create_or_replace_secret "jwt_audience"      "$JWT_AUDIENCE_FILE"
create_or_replace_secret "connection_string" "$CONN_STR_FILE"

# ===== Create overlay network =====
create_overlay_network "$NETWORK_NAME" "$SUBNET"

echo "All done ✅"
