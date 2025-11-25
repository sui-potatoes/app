#! /bin/bash

rm -r build/Commander.app
rm -r build/dmg-staging

mkdir -p build/Commander.app/Contents/MacOS
mkdir -p build/Commander.app/Resources

# Build

cargo build --release --target aarch64-apple-darwin
cp target/aarch64-apple-darwin/release/commander build/Commander.app/Contents/MacOS/Commander
chmod +x build/Commander.app/Contents/MacOS/Commander

# Metadata

cat scripts/Info.plist > build/Commander.app/Contents/Info.plist
cp scripts/Commander.icns build/Commander.app/Contents/Resources/Commander.icns

# Temporary folder

mkdir -p build/dmg-staging
cp -R build/Commander.app build/dmg-staging/
ln -s /Applications build/dmg-staging/Applications

# Generate dmg

hdiutil create -volname "Commander" \
  -srcfolder build/dmg-staging \
  -ov -format UDZO build/Commander.dmg

#

codesign --deep --force --verify --sign "Developer ID Application: Potatoes" Commander.app
