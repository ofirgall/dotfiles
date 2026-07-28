SHELL := /bin/bash

SUBMODULES := $(shell git config --file .gitmodules --get-regexp path 2>/dev/null | awk '{print $$2}')

.PHONY: help init update status add remove foreach

help:
	@echo "Targets:"
	@echo "  make init              Clone/initialize all submodules"
	@echo "  make update            Pull each submodule to its remote default branch (aborts if any is dirty)"
	@echo "  make status            Show short status of each submodule"
	@echo "  make add REPO=<url>    Add a submodule (path defaults to repo name)"
	@echo "  make add REPO=<url> PATH=<dir>"
	@echo "  make remove NAME=<path>  Remove a submodule by its path"
	@echo "  make foreach CMD='...' Run a shell command in each submodule"

init:
	git submodule update --init --recursive
	git config core.hooksPath .githooks

status:
	@git submodule status

update:
	@set -euo pipefail; \
	if [ -z "$(SUBMODULES)" ]; then echo "No submodules configured."; exit 0; fi; \
	dirty=""; \
	for m in $(SUBMODULES); do \
		if [ ! -e "$$m/.git" ]; then continue; fi; \
		if ! git -C "$$m" diff --quiet || ! git -C "$$m" diff --cached --quiet || [ -n "$$(git -C "$$m" ls-files --others --exclude-standard)" ]; then \
			dirty="$$dirty $$m"; \
		fi; \
	done; \
	if [ -n "$$dirty" ]; then \
		echo "Refusing to update — dirty submodules:$$dirty"; \
		exit 1; \
	fi; \
	for m in $(SUBMODULES); do \
		echo "==> $$m"; \
		git -C "$$m" fetch --quiet origin; \
		default=$$(git -C "$$m" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||'); \
		if [ -z "$$default" ]; then \
			git -C "$$m" remote set-head origin -a >/dev/null; \
			default=$$(git -C "$$m" symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||'); \
		fi; \
		git -C "$$m" checkout --quiet "$$default"; \
		git -C "$$m" reset --hard --quiet "origin/$$default"; \
		echo "    $$default @ $$(git -C "$$m" rev-parse --short HEAD)"; \
	done

add:
	@if [ -z "$(REPO)" ]; then echo "Usage: make add REPO=<url> [PATH=<dir>]"; exit 2; fi; \
	path="$(PATH_)"; \
	if [ -z "$$path" ]; then path=$$(basename "$(REPO)" .git); fi; \
	git submodule add "$(REPO)" "$$path"; \
	echo "Added submodule at $$path. Commit .gitmodules to persist."

remove:
	@if [ -z "$(NAME)" ]; then echo "Usage: make remove NAME=<path>"; exit 2; fi; \
	git submodule deinit -f "$(NAME)"; \
	git rm -f "$(NAME)"; \
	rm -rf ".git/modules/$(NAME)"; \
	echo "Removed submodule $(NAME). Commit the change to persist."

foreach:
	@if [ -z "$(CMD)" ]; then echo "Usage: make foreach CMD='git status -s'"; exit 2; fi; \
	git submodule foreach --recursive "$(CMD)"
