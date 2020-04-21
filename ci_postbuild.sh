#!/bin/bash

catalog_appshack_upload () {
    pushd /Volumes/workspace/developmentexport

    if [ "${CI_BRANCH}" == "master" ]; then
        BUNDLE_ID="com.example.researchkit-samplecode.ORKCatalog"
        IPA_NAME="ORKCatalog.ipa"
    elif [ "${CI_BRANCH}" == "stable" ]; then
        BUNDLE_ID="com.example.researchkit-samplecode.ORKCatalog-qa"
        IPA_NAME="ORKCatalog QA.ipa"
    elif [ "${CI_BRANCH}" == "release/public" ]; then
        BUNDLE_ID="com.example.researchkit-samplecode.ORKCatalog-public"
        IPA_NAME="ORKCatalog Public.ipa"
    elif [ "${CI_BRANCH}" == "release/internal" ]; then
        BUNDLE_ID="com.example.researchkit-samplecode.ORKCatalog-internal"
    else
        echo "Only master, stable, or public-release will upload to appshack"
        exit 0
    fi

    mkdir -p Payload
    rm -rf Payload/*
    cp -R "${IPA_NAME}" Payload/
    zip -r "${IPA_NAME}" Payload
    curl -v \
    --user ${ODUSER}:${ODPASS} \
    --form 'ipaFile=@"'"${IPA_NAME}"'"' \
    -X POST 'https://appshack.swe.apple.com/services/apps/'"$BUNDLE_ID"'/builds'

}

sample_appshack_upload () {
    pushd /Volumes/workspace/developmentexport

    if [ "${CI_BRANCH}" == "master" ]; then
        BUNDLE_ID="com.example.apple-ResearchKit.Sample"
        IPA_NAME="ORKSample.ipa"
    elif [ "${CI_BRANCH}" == "stable" ]; then
        BUNDLE_ID="com.example.apple-ResearchKit.Sample-qa"
        IPA_NAME="ORKSample QA.ipa"
    elif [ "${CI_BRANCH}" == "release/public" ]; then
        BUNDLE_ID="com.example.apple-ResearchKit.Sample-public"
        IPA_NAME="ORKSample Public.ipa"
    elif [ "${CI_BRANCH}" == "release/internal" ]; then
        BUNDLE_ID="com.example.apple-ResearchKit.Sample-internal"
        IPA_NAME="ORKSample Internal.ipa"
    else
        echo "Only master, stable, or public-release will upload to appshack"
        exit 0
    fi

    mkdir -p Payload
    rm -rf Payload/*
    cp -R "${IPA_NAME}" Payload/
    zip -r "${IPA_NAME}" Payload
    curl -v \
    --user ${ODUSER}:${ODPASS} \
    --form 'ipaFile=@"'"${IPA_NAME}"'"' \
    -X POST 'https://appshack.swe.apple.com/services/apps/'"$BUNDLE_ID"'/builds'
}

if [ "${IS_BUILD}" == "1" ]; then
    exit 0
fi

if [ "${PIPELINE}" == "ORKCatalog" ]; then
	catalog_appshack_upload
elif [ "${PIPELINE}" == "ORKSample" ]; then
    sample_appshack_upload
fi
