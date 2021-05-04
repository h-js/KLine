#!/bin/sh

./Scripts/swiftlint/swiftlint autocorrect --config $SRCROOT/.swiftlint.yml
./Scripts/swiftlint/swiftlint --strict --config $SRCROOT/.swiftlint.yml
