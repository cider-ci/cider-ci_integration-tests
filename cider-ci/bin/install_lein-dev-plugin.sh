#!/usr/bin/env bash

set -eux
cd lein-dev-plugin
TREE_ID=$(git log -n 1 HEAD --pretty=%T)
CACHE_STAMP_FILE="/tmp/lein-dev-plugin_installed_${TREE_ID}"
if [ ! -f  $CACHE_STAMP_FILE ]; then
  lein install
  touch $CACHE_STAMP_FILE
fi

