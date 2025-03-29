#!/bin/bash

essentials=(
  git
  gh
)

for package in "${essentials[@]}"; do
  sudo apt install -y "$package"
done
