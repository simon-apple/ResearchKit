#!/bin/bash

if [ "${IS_BUILD}" == "1" ]; then
    exit 0
fi

if [ "${PIPELINE}" == "ORKCatalog" ]; then
	source appshackUpload_ORKCatalog.sh
elif [ "${PIPELINE}" == "ORKSample" ]; then
	source appshackUpload_ORKSample.sh
fi
