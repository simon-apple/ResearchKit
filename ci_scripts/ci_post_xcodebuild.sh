#!/bin/bash

# set -Eeuo pipefail
# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
# This provides standard safeguards for bash scripts

# Previously we were running into issues running the curl command to upload our app into AppShack.
# After some investigatin we found that our script was failing because of the output received after the upload is finished
# We solved this by adding a common redirection by using '> /dev/null 2>&'
# https://www.brianstorti.com/understanding-shell-script-idiom-redirect/
# test

set -Eeuo pipefail


generate_poseidon_post_data() {
  cat <<EOF
{
    "buildNumber":"${CI_BUILD_NUMBER}",
    "hash":"${CI_COMMIT}",
    "buildType":"${BUILD_TYPE}",
    "app":"${APP_NAME}",
    "buildID":"${CI_BUILD_ID}",
    "bundleID":"${BUNDLE_ID}",
}
EOF
}

poseidonUpdate() {
    POSEIDON_BUILD_COMPLETE_URL="${POSEIDON_URL}/api:skywagon/buildComplete"
    echo "Updating Poseidon"
    curl -v \
    -H 'Content-Type: application/json' \
    -X POST --data "$(generate_poseidon_post_data)" ${POSEIDON_BUILD_COMPLETE_URL} > /dev/null 2>&1
}

appshack_upload() {

    pushd ${CI_ARCHIVE_PATH}
    mkdir -p Payload
    rm -rf Payload/*
    cp -R Products/Applications/ Payload
    
    IPA_NAME=${CI_XCODE_SCHEME}-${CI_WORKFLOW}-${CI_BUILD_NUMBER}.ipa
    zip -r "${IPA_NAME}" Payload
    echo "$(ls -l "${IPA_NAME}")"
    
    curl -vs \
    --form 'ipaFile=@"'"${IPA_NAME}"'"' \
    --form 'platform=iOS' \
    --user ${OD_USER}:${OD_PASS} \
    -X POST 'https://appshack.swe.apple.com/services/apps/'${CI_BUNDLE_ID}'/builds' \
    -w '%{size_request} %{size_upload}'

    echo "Curl command done"

}

if [[ ${CI_XCODEBUILD_EXIT_CODE} != "0" ]]; then
    echo "xcodebuild was unsuccesful"
    exit 0
fi

if [ ${CI_XCODEBUILD_ACTION} == "archive" ] && [ ${CI_XCODE_SCHEME} == "ORKCatalog" ]; then
    echo "START: Uploading ORKCatalog to appshack"
    appshack_upload
    echo "DONE: Uploading ORKCatalog to appshack"
    poseidonUpdate
    echo "DONE: Upading Poseidon"
fi
