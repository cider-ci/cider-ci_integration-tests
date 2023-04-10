#!/usr/bin/env bash
set -euo pipefail
cd server
DIGEST=$(cd .. &&  git log -n 1 HEAD --pretty=%T)
LEIN_UBERJAR_FILE="/tmp/cider-ci_${DIGEST}.jar"
if [ -f "${LEIN_UBERJAR_FILE}" ];then
  echo " ${LEIN_UBERJAR_FILE} exists"
else
  ./bin/uberjar
  mv "target/cider-ci.jar" "${LEIN_UBERJAR_FILE}"
fi
mkdir -p target
ln -s "$LEIN_UBERJAR_FILE" "target/cider-ci.jar"
