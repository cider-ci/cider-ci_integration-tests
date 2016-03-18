#!/usr/bin/env bash
set -eux
cd "$SERVICE_NAME"
SELF_DIGEST=$(git log -n 1 HEAD --pretty=%T)
UTILS_DIGEST=$(cd ../clj-utils &&  git log -n 1 HEAD --pretty=%T)
LEIN_DEV_PLUGIN_DIGEST=$(cd ../lein-dev-plugin &&  git log -n 1 HEAD --pretty=%T)
CONFIG_DIGEST=$(cd .. && git ls-tree HEAD -- config | openssl dgst -sha1 | cut -d ' ' -f 2)
DIGEST="${SELF_DIGEST}_${UTILS_DIGEST}_${LEIN_DEV_PLUGIN_DIGEST}_${CONFIG_DIGEST}"
LEIN_UBERJAR_FILE="/tmp/${SERVICE_NAME}_${DIGEST}.jar"
if [ -f "${LEIN_UBERJAR_FILE}" ];then
  echo " ${LEIN_UBERJAR_FILE} exists"
else
  lein uberjar
  mv "target/${SERVICE_NAME}.jar" "${LEIN_UBERJAR_FILE}"
fi
mkdir -p target
ln -s "$LEIN_UBERJAR_FILE" "target/${SERVICE_NAME}.jar"
