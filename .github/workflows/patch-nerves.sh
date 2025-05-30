#!/bin/bash
set -e

# This script runs the Nerves patch to ensure clutch_nerves_system_br is correctly recognized.
# It assumes that mix deps.get, mix deps.compile, nerves_bootstrap, and mix compile (for Elixir code)
# have already been run/installed in the CI workflow, making :meck and NervesSystemRpi5.NervesPatch available.

echo "Running Nerves Patch Script (execution only)..."

MIX_ENV="${MIX_ENV:-prod}"
echo "MIX_ENV is $MIX_ENV"

echo "Executing Nerves patch: NervesSystemRpi5.NervesPatch.run()"
mix run --no-deps-check --no-compile -e "NervesSystemRpi5.NervesPatch.run()"

echo "Nerves Patch Script completed." 