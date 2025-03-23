#!/bin/bash

essentials=(
  neovim
  git
)

for package in "${essentials[@]}"; do
  sudo apt install -y "$package"
done
