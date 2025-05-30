#!/bin/bash
set -e

echo "Running patch-nerves.sh to enable clutch_nerves_system_br compatibility"

# Create the symlink if it doesn't exist
mkdir -p deps
if [ ! -e deps/nerves_system_br ]; then
  if [ -d deps/clutch_nerves_system_br ]; then
    echo "Creating symlink from deps/nerves_system_br to deps/clutch_nerves_system_br"
    ln -sf $(realpath deps/clutch_nerves_system_br) deps/nerves_system_br
  else
    # This is OK if we're early in the build process - we'll try the symlink again later
    echo "Warning: deps/clutch_nerves_system_br does not exist yet - skipping symlink creation"
  fi
else
  echo "deps/nerves_system_br already exists"
fi

# Look for and patch br.ex
BR_FILE=$(find deps -name br.ex 2>/dev/null | grep -E "nerves/lib/nerves/system/br.ex" || echo "")

if [ -n "$BR_FILE" ]; then
  echo "Found $BR_FILE - creating backup"
  cp "$BR_FILE" "${BR_FILE}.bak"
  
  # Check if the file already contains our patch
  if grep -q "Nerves.Env.package(:nerves_system_br) || Nerves.Env.package(:clutch_nerves_system_br)" "$BR_FILE"; then
    echo "File $BR_FILE is already patched"
  else
    # Patch the file using sed
    echo "Patching $BR_FILE to look for clutch_nerves_system_br"
    # Replace "Nerves.Env.package(:nerves_system_br)" with more flexible code
    sed -i 's/Nerves.Env.package(:nerves_system_br)/Nerves.Env.package(:nerves_system_br) || Nerves.Env.package(:clutch_nerves_system_br)/g' "$BR_FILE"
    echo "Patch applied successfully"
  fi
else
  echo "Warning: Could not find br.ex file - skipping patch (this may be OK if dependencies aren't fetched yet)"
  # This is not an error case if we're early in the build process
fi

echo "Nerves patch script completed" 