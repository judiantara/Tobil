#!/usr/bin/env bash

set -euo pipefail

FLAKE_ROOT=$HOME/wyrmling
export FLAKE_REPO=$FLAKE_ROOT#$TARGET_MACHINE
export AGE_IDENTITY_KEY=$FLAKE_ROOT/persist/wyrmling.age.key
export PERSIST_FILES=$FLAKE_ROOT/persist/$TARGET_MACHINE/$TARGET_MACHINE.tar.age

echo "Using FLAKE_REPO: ''${FLAKE_REPO:?}"
echo "Using AGE_IDENTITY_KEY: ''${AGE_IDENTITY_KEY:?}"
echo "Using PERSIST_FILES: ''${PERSIST_FILES:?}"
echo

echo "Generate luks key..."
yk-luks-gen
echo

echo "Partitioning disk..."
disko --mode zap_create_mount --flake $FLAKE_REPO
echo

echo "Install persisted files..."
mkdir -p /mnt/{boot,nix/persist,etc/{nixos,ssh},var/{lib,log},srv}
rage -d -i $AGE_IDENTITY_KEY $PERSIST_FILES | tar -xvC /mnt/nix/persist
echo

echo "Install luks salt..."
cp /tmp/salt.conf /mnt/boot/
echo

echo "Removing unused channel..."
nix-channel --remove nixos
echo

echo "Install NixOS..."
nixos-install --channel unstable --no-channel-copy --no-root-password --no-write-lock-file --flake $FLAKE_REPO --root /mnt --cores 0
