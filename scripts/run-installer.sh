#!/usr/bin/env bash

set -euo pipefail

echo "Using FLAKE_REPO: ''${FLAKE_REPO:?}"
echo "Using AGE_IDENTITY_KEY: ''${AGE_IDENTITY_KEY:?}"
echo "Using PERSIST_FILES: ''${PERSIST_FILES:?}"
echo

if [[ "${DRY_RUN+DEFINED}" ]]; then
  echo "Running in dry-run mode..."
  echo
fi

echo "Generate luks key..."
yk-luks-gen
echo

if ! [[ "${DRY_RUN+DEFINED}" ]]; then
  echo "Partitioning disk..."
  disko --mode zap_create_mount --flake $FLAKE_REPO
  echo
fi

echo "Install persisted files..."
mkdir -p /mnt/{boot,nix/persist,etc/{nixos,ssh},var/{lib,log},srv}
rage -d -i $AGE_IDENTITY_KEY $PERSIST_FILES | tar -xvC /mnt/nix/persist
echo

echo "Install luks salt..."
cp /tmp/salt.conf /mnt/boot/
echo

if ! [[ "${DRY_RUN+DEFINED}" ]]; then
  echo "Removing unused channel..."
  nix-channel --remove nixos
  echo

  echo "Install NixOS..."
  nixos-install --channel unstable --no-channel-copy --no-root-password --no-write-lock-file --flake $FLAKE_REPO --root /mnt --cores 0
fi
