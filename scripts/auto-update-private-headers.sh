#!/bin/bash

# update_headers.sh
#
# Created by Lewis Bosson on 12/1/09.
# Copyright 2019 Apple Inc. All rights reserved.

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$scriptPath/update-private-headers.py -s "$(xcode-select -p)/../../Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.1.Internal.sdk" -t $scriptPath/../ResearchKit/PrivateHeaders/ -m "ORK_INTERNAL_SDK_AVAILABLE"

