#!/bin/bash

cd "$(dirname "$0")"
for i in $(cat extensions); do code --install-extension $i --force; done
