#! /bin/bash

# 1. Enter each folder, run `sui move build --doc`
# 2. Create a new folder `docs` in each path
# 3. Put the `build/docs/<package>/*` into docs
# 4. Grep replace `../dependencies/*` to `./dependencies/*` in each .md file
# 5. Add a simlink to this folder in ../dependencies folder
# 6. Add a simlink in docs/dependencies to ../dependencies

set -euo pipefail

# Create dependencies folder if not exists
mkdir -p .doc-deps

# Iterate through all subdirectories (i.e., all Move packages)
for dir in */ ; do
  [ -d "$dir" ] || continue
  cd "$dir"

  echo "Building documentation in $dir"

  # Step 0: Remove docs folder if exists
  rm -rf docs;

  # Step 1: Build docs
  sui move build --doc;

  # Step 2: Create docs folder if not exists
  mkdir -p docs;

  # Step 3: Copy generated docs to ./docs
  pkg_name=$(basename "$(pwd)")
  upkg_name=$(basename "$(pwd)" | sed 's/-/_/g')
  if [ -d "build/$pkg_name/docs/$upkg_name" ]; then
    cp -r build/$pkg_name/docs/$upkg_name/* docs/
  else
    echo "No docs found in build/docs/$upkg_name"
  fi

  # Step 4.1: Replace ../dependencies/* with ./dependencies/* in Markdown files
  find docs -name '*.md' -exec sed -i '' -e 's|\.\./dependencies/|\.\./\.\./\.doc-deps/|g' {} +

  # Step 4.2: Replace ../$upkg_name/* with ./* in Markdown files
  find docs -name '*.md' -exec sed -i '' -e "s|\.\.\/$upkg_name/|./|g" {} +

  rm -rf $(pwd)/../.doc-deps/$pkg_name;

  # Step 5: Create symlink to this docs folder in ../dependencies
  ln -sf "$(pwd)/docs" "$(pwd)/../.doc-deps/$pkg_name"

  cd ..
done

echo "All done."
