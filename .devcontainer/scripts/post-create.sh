#!/bin/bash

pushd app

npm install

popd

pushd api

npm install

cp local.settings.json.example local.settings.json

popd