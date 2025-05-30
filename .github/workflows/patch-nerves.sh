#!/bin/bash
set -e

# This script runs the Nerves patch to ensure clutch_nerves_system_br is correctly recognized.
# It assumes that mix deps.get, and relevant compilations for the patch module and meck
# have already been run/installed in the CI workflow.

echo "Running Nerves Patch Script (mix run -e, MIX_TARGET=host attempt)..."

MIX_ENV="${MIX_ENV:-prod}"
echo "MIX_ENV is $MIX_ENV"

# Ensure SKIP_NERVES_PACKAGE is not true for this specific command.
# Explicitly set MIX_TARGET=host for this patching step.
echo "Executing Nerves patch logic: NervesSystemRpi5.PatchLogic.apply() (MIX_TARGET=host)"
(unset SKIP_NERVES_PACKAGE; export MIX_TARGET=host; mix run --no-deps-check --no-compile -e "NervesSystemRpi5.PatchLogic.apply()")

echo "Nerves Patch Script (mix run -e, MIX_TARGET=host attempt) completed." 