#!/usr/bin/env bash
set -euo pipefail

# قابل تغییر با env، مثلا:
# UID_IN_CONTAINER=1001 GID_IN_CONTAINER=1001 bash prep-sol-dirs.sh
UID_IN_CONTAINER="${UID_IN_CONTAINER:-1000}"
GID_IN_CONTAINER="${GID_IN_CONTAINER:-1000}"
BASE="/srv/sol"

echo ">> Creating directories..."
sudo install -d -m 0775 "${BASE}/uploads" "${BASE}/results" "${BASE}/nginx/logs" "${BASE}/nginx/cache" "${BASE}/nginx/configs" "${BASE}/nginx/certs" 

echo ">> Setting ownership to ${UID_IN_CONTAINER}:${GID_IN_CONTAINER} ..."
sudo chown -R "${UID_IN_CONTAINER}:${GID_IN_CONTAINER}" "${BASE}/uploads" "${BASE}/results" "${BASE}/nginx/logs" "${BASE}/nginx/cache" "${BASE}/nginx/configs" "${BASE}/nginx/certs"

# در سیستم‌های با SELinux (مثل Fedora/RHEL/CentOS) برای bind mount لازم می‌شود
if command -v getenforce >/dev/null 2>&1 && [ "$(getenforce)" = "Enforcing" ]; then
  echo ">> SELinux enforcing detected; applying context..."
  sudo chcon -Rt svirt_sandbox_file_t "${BASE}"
fi

echo "✅ Done. Paths:"
echo "   ${BASE}/uploads"
echo "   ${BASE}/results"
echo "   ${BASE}/nginx/logs" 
echo "   ${BASE}/nginx/cache" 
echo "   ${BASE}/nginx/configs"
echo "   ${BASE}/nginx/certs"
