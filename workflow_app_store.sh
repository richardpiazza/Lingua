#! /bin/bash

# Build & Archive
xcodebuild \
  -scheme Lingua \
  -target Lingua \
  -sdk 'macosx26.5' \
  -destination 'generic/platform=macOS' \
  -derivedDataPath 'derivedData' \
  -archivePath 'Lingua.xcarchive' \
  archive \
  2>&1 \
  | xcbeautify

# Export Archive
xcodebuild \
  -exportArchive \
  -archivePath 'Lingua.xcarchive' \
  -exportPath 'export' \
  -exportOptionsPlist 'Lingua/ExportOptions_macOS.plist'

# Validate Pkg
xcrun \
  altool \
  --validate-app \
  -f export/Lingua.pkg \
  -t macos \
  --apiKey 4K335P848P \
  --apiIssuer 69a6de71-72d5-47e3-e053-5b8c7c11a4d1

# Upload
xcrun \
  altool \
  --upload-app \
  -f export/Lingua.pkg \
  -t macos \
  --apiKey 4K335P848P \
  --apiIssuer 69a6de71-72d5-47e3-e053-5b8c7c11a4d1
