#!/bin/bash
set -e

# This script runs the Nerves patch to ensure clutch_nerves_system_br is correctly recognized.
# It assumes that mix deps.get has already been run in the CI workflow.

echo "Running Nerves Patch Script (MIX_TARGET=host)..."

MIX_ENV="${MIX_ENV:-prod}"
echo "MIX_ENV is $MIX_ENV"

# Compile the project in the host context, which makes NervesSystemRpi5.PatchLogic and meck available.
# This is crucial before attempting to run the patch logic.
echo "Compiling project for host to ensure PatchLogic and meck are available (MIX_TARGET=host)..."
(unset SKIP_NERVES_PACKAGE; export MIX_TARGET=host; mix compile)

# Ensure SKIP_NERVES_PACKAGE is not true for this specific command.
# Explicitly set MIX_TARGET=host for this patching step.
echo "Executing Nerves patch logic: NervesSystemRpi5.PatchLogic.apply() (MIX_TARGET=host)"
(unset SKIP_NERVES_PACKAGE; export MIX_TARGET=host; mix run --no-deps-check --no-compile -e "NervesSystemRpi5.PatchLogic.apply()")

echo "Nerves Patch Script (MIX_TARGET=host) completed." 