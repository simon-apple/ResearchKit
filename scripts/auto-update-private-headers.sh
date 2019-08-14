#!/bin/bash

# update_headers.sh
#
# Created by Lewis Bosson on 12/1/09.
# Copyright 2019 Apple Inc. All rights reserved.

scriptPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

$scriptPath/update-private-headers.sh "$(xcode-select -p)/../../Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS13.0.Internal.sdk" $scriptPath/private-headers.txt  $scriptPath/../ResearchKit/PrivateHeaders
