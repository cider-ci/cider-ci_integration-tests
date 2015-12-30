#!/usr/bin/env bash
set -eux
cd "$SERVICE_DIRECTORY"
DIGEST=`git ls-tree HEAD -- project.clj src resources | openssl dgst -sha1 | cut -d ' ' -f 2`
LEIN_CACHE_DIR="/tmp/lein_target_cache_${DIGEST}"
if [ -d "${LEIN_CACHE_DIR}" ];then
  echo "lein chache dir ${LEIN_CACHE_DIR} exists, just copying"
else
  lein compile
  mv target "${LEIN_CACHE_DIR}"
fi
cp -a "${LEIN_CACHE_DIR}" target
