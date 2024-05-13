#!/bin/bash

pushd app

npm install

cp .env.example .env

popd

pushd api

npm install

cp local.settings.json.example local.settings.json

popd

pushd logic_app

cp local.settings.json.example local.settings.json

popd