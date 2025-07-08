#! /bin/bash

# 1. Enter each folder, run `sui move build --doc`
# 2. Create a new folder `docs` in each path
# 3. Copy the `build/docs/<package>/*` into docs
# 4. Grep replace `../dependencies/*` to `./dependencies/*` in each .md file
# 5. Grep replace `../<package>/*` to `./` in each .md file
# 6. Remove old symlink in ../.doc-deps/<package>
# 7. Create a new symlink in ../.doc-deps/<package> to this docs folder

set -euo pipefail

# Create dependencies folder if not exists
mkdir -p .doc-deps

# Iterate through all subdirectories (i.e., all Move packages)
for dir in */ ; do
  [ -d "$dir" ] || continue
  cd "$dir"

  echo "Building documentation in $dir"

  # Step 1: Remove docs folder if exists
  rm -rf docs;

  # Step 2: Build docs
  sui move build --doc;

  # Step 3: Create docs folder if not exists
  mkdir -p docs;

  # Step 4: Copy generated docs to ./docs
  pkg_name=$(basename "$(pwd)")
  upkg_name=$(basename "$(pwd)" | sed 's/-/_/g')
  if [ -d "build/$pkg_name/docs/$upkg_name" ]; then
    cp -r build/$pkg_name/docs/$upkg_name/* docs/
  else
    echo "No docs found in build/docs/$upkg_name"
  fi

  # Step 5: Replace ../dependencies/* with ./dependencies/* in Markdown files
  find docs -name '*.md' -exec sed -i '' -e 's|\.\./dependencies/|\.\./\.\./\.doc-deps/|g' {} +

  # Step 6: Replace ../$upkg_name/* with ./* in Markdown files
  find docs -name '*.md' -exec sed -i '' -e "s|\.\.\/$upkg_name/|./|g" {} +

  # Step 7: Remove old symlink
  rm -rf $(pwd)/../.doc-deps/$pkg_name;

  # Step 8: Create symlink to this docs folder in ../dependencies
  echo "Creating symlink to $pkg_name/docs in .doc-deps/$pkg_name"
  ln -sf ../$pkg_name/docs ../.doc-deps/$pkg_name

  cd ..
done

echo "All done."
