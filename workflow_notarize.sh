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
  -exportOptionsPlist 'Lingua/ExportOptions_DeveloperID.plist'

# Zip
ditto -c -k --keepParent export/Lingua.app export/Lingua.zip

# Notarize
xcrun notarytool submit export/Lingua.zip -k private_keys/AuthKey_4K335P848P.p8 -d 4K335P848P -i 69a6de71-72d5-47e3-e053-5b8c7c11a4d1 --wait

# Staple
xcrun stapler staple export/Lingua.app

# Verify
spctl --assess --verbose --type execute export/Lingua.app
