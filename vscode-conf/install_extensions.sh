#!/bin/bash

for i in $(cat extensions); do code --install-extension $i --force; done
