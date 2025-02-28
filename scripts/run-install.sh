!/usr/bin/env bash

set -euo pipefail

if [ -z "$FLAKE_REPO" ]; then
  echo "Cannot find FLAKE_REPO env var"
  exit 1
fi

if [ -z "$AGE_IDENTITY_KEY" ]; then
  echo "Cannot find AGE_IDENTITY_KEY env var"
  exit 1
fi

if [ -z "$PERSIST_FILES" ]; then
  echo "Cannot find PERSIST_FILES env var"
  exit 1
fi

echo "Generate luks key..."
yk-luks-gen

if ! [ -z "$DRY_RUN" ]; then
  echo "Partitioning disk..."
  disko --mode zap_create_mount --flake $FLAKE_REPO
fi

echo "Install persisted files..."
mkdir -p /mnt/{boot,nix/persist,etc/{nixos,ssh},var/{lib,log},srv}
age -d -i $AGE_IDENTITY_KEY $PERSIST_FILES | tar -xv -C /mnt/nix/persist

echo "Setting up salt..."
cp /tmp/salt.conf /mnt/boot/

if ! [ -z "$DRY_RUN" ]; then
  echo "Install NixOS..."
  nix-channel --remove nixos
  nixos-install --channel unstable --no-channel-copy --no-root-password --no-write-lock-file --flake $FLAKE_REPO --root /mnt --cores 0
fi
