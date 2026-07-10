#!/usr/bin/env sh
set -eu

sudo apt update
sudo apt install shellcheck -y

shellcheck --version
