#!/bin/bash

if [ "${IS_BUILD}" == "1" ]; then
    exit 0
fi

pushd /tmp/ci/developmentexport

# if [ "${PIPELINE}" == "ORKCatalog" ]; then
# 	if [ "${CI_BRANCH}" == "master" ]; then
# 		BUNDLE_ID="com.example.researchkit-samplecode.ORKCatalog"
# 		IPA_NAME="ORKCatalog.ipa"
# 	elif [ "${CI_BRANCH}" == "stable" ]; then
# 		BUNDLE_ID="com.example.researchkit-samplecode.ORKCatalog-qa"
# 		IPA_NAME="ORKCatalog QA.ipa"
# 	elif [ "${CI_BRANCH}" == "release/public" ]; then
# 		BUNDLE_ID="com.example.researchkit-samplecode.ORKCatalog-public"
# 		IPA_NAME="ORKCatalog Public.ipa"
#   elif [ "${CI_BRANCH}" == "release/internal" ]; then
#     BUNDLE_ID="com.example.researchkit-samplecode.ORKCatalog-internal"
# 	else
# 		echo "Only master, stable, or public-release will upload to appshack"
# 		exit 0
# 	fi
# elif [ "${PIPELINE}" == "ORKSample" ]; then
# 	if [ "${CI_BRANCH}" == "master" ]; then
# 		BUNDLE_ID="com.example.carekit-samplecode.ORKSample"
# 		IPA_NAME="ORKSample.ipa"
# 	elif [ "${CI_BRANCH}" == "stable" ]; then
# 		BUNDLE_ID=""
# 		IPA_NAME="ORKSample QA.ipa"
# 	elif [ "${CI_BRANCH}" == "public-release" ]; then
# 		BUNDLE_ID=""
# 		IPA_NAME="ORKSample Public.ipa"
# 	else
# 		echo "Only master, stable, or public-release will upload to appshack"
# 		exit 0
# 	fi
# fi

BUNDLE_ID="com.example.researchkit-samplecode.ORKCatalog"
IPA_NAME="ORKCatalog.ipa"

mkdir -p Payload
rm -rf Payload/*
cp -R "${IPA_NAME}" Payload/
zip -r "${IPA_NAME}" Payload
curl -v \
--user ${ODUSER}:${ODPASS} \
--form 'ipaFile=@"'"${IPA_NAME}"'"' \
-X POST 'https://appshack.swe.apple.com/services/apps/'"$BUNDLE_ID"'/builds'
