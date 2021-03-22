#!/bin/sh

bundle install
mint bootstrap
mint run swiftgen
mint run xcodegen
