#!/usr/bin/env bash
set -eux
cd server
export LEIN_SNAPSHOTS_IN_RELEASE=yes
# SELF_DIGEST=$(git log -n 1 HEAD --pretty=%T)
# UTILS_DIGEST=$(cd ../clj-utils &&  git log -n 1 HEAD --pretty=%T)
# LEIN_DEV_PLUGIN_DIGEST=$(cd ../lein-dev-plugin &&  git log -n 1 HEAD --pretty=%T)
# CONFIG_DIGEST=$(cd .. && git ls-tree HEAD -- config | openssl dgst -sha1 | cut -d ' ' -f 2)
# DIGEST="${SELF_DIGEST}_${UTILS_DIGEST}_${LEIN_DEV_PLUGIN_DIGEST}_${CONFIG_DIGEST}"
DIGEST=$(cd .. &&  git log -n 1 HEAD --pretty=%T)
LEIN_UBERJAR_FILE="/tmp/cider-ci_${DIGEST}.jar"
if [ -f "${LEIN_UBERJAR_FILE}" ];then
  echo " ${LEIN_UBERJAR_FILE} exists"
else
  lein uberjar
  mv "target/cider-ci.jar" "${LEIN_UBERJAR_FILE}"
fi
mkdir -p target
ln -s "$LEIN_UBERJAR_FILE" "target/cider-ci.jar"
