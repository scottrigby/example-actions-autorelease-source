#!/bin/bash
set -euo pipefail

VERSION="$1"

jq --arg version "$VERSION" '.version = $version | .build = (now | strftime("%Y-%m-%d"))' version.json > version.json.tmp
mv version.json.tmp version.json

echo "Version updated to $VERSION"