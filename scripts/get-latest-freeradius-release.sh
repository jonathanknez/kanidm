#!/bin/bash

# downloads the latest os-specific version from github

set -e

CURLRESULT="$(curl -sf \
  -H "Accept: application/vnd.github+json" \
    "https://api.github.com/repos/freeradius/freeradius-server/releases/latest")"

DOWNLOAD_URL="$(echo "${CURLRESULT}" |  jq -r ".assets[] | \
select(.name| endswith(\"tar.gz\")) | \
.browser_download_url")"

if [ -z "${DOWNLOAD_URL}" ];then
    echo "Couldn't get download url from this:"
    echo "${CURLRESULT}"
    exit 1
fi
echo "Downloading from ${DOWNLOAD_URL}"

curl -f -o freeradius.tar.gz -L "${DOWNLOAD_URL}"

if [ ! -f freeradius.tar.gz ]; then
    echo "Couldn't find freeradius.tar.gz"
    exit 1
fi

echo "Extracting freeradius.tar.gz"

tar zxf freeradius.tar.gz

echo "Done!"