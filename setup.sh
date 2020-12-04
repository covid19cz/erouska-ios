#!/bin/sh

bundle install
mint bootstrap
mint run swiftgen
mint run xcodegen
bundle exec pod install
