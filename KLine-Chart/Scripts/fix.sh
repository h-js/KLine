#!/bin/sh

./Scripts/swiftformat/swiftformat . --swiftversion 5
./Scripts/swiftlint/swiftlint autocorrect
./Scripts/swiftlint/swiftlint --strict