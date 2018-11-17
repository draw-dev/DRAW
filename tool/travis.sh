#!/bin/bash

# Fast fail the script on failures.
set -e

# Install dart_coveralls; gather and send coverage data.
if [ "$COVERALLS_TOKEN" ] && [ "$TRAVIS_DART_VERSION" = "stable" ]; then
  pub global activate dart_coveralls
  #git clone https://github.com/bkonyi/dart-coveralls.git
  #cd dart-coveralls
  #pub get
  #cd ..
  echo "Running coverage..."
  #dart dart-coveralls/bin/dart_coveralls.dart report \
  dart_coveralls report \
    --retry 2 \
    --exclude-test-files \
    --throw-on-error \
    --throw-on-connectivity-error \
    test/test_all.dart
  echo "Coverage complete."
  rm -rf dart-coveralls
else
  if [ -z ${COVERALLS_TOKEN+x} ]; then echo "COVERALLS_TOKEN is unset"; fi
  if [ -z ${TRAVIS_DART_VERSION+x} ]; then
    echo "TRAVIS_DART_VERSION is unset";
  else
    echo "TRAVIS_DART_VERSION is $TRAVIS_DART_VERSION";
  fi

  echo "Skipping coverage for this configuration."
fi
