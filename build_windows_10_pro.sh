#!/bin/bash
packer build --force \
  --only=$1-iso \
  windows_10_pro.json
