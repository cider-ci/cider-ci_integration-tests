#!/usr/bin/env bash
set -eux

cd "$CIDER_CI_WORKING_DIR/user-interface"

DIGEST=`git ls-tree HEAD -- package.json vendor.js.coffee | openssl dgst -sha1 | cut -d ' ' -f 2`

BUNDLE_JS_PATH="$CIDER_CI_WORKING_DIR/user-interface/vendor/assets/javascripts/bundle.js"
CACHE_FILE="/tmp/bundle_${DIGEST}.js"

if [ -f "${CACHE_FILE}" ]; then
  echo "bundle cache ${CACHE_FILE} exists; just linking"
else
  npm run build
  mv  "$BUNDLE_JS_PATH" "$CACHE_FILE"
fi

ln -s "$CACHE_FILE" "$BUNDLE_JS_PATH"
