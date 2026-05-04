SHELL := /bin/sh
.DEFAULT_GOAL := help

HOME_DIR ?= $(HOME)
JOBS ?= $(shell nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
SUCKLESS_PREFIX ?= /usr/local

LOCAL_SRC := local
HOME_SRC := home

ST_DIR := external/st
DWM_DIR := external/dwm

ST_LOCAL := $(LOCAL_SRC)/st
DWM_LOCAL := $(LOCAL_SRC)/dwm

ST_SCROLLPATCH_URL := https://st.suckless.org/patches/scrollback-reflow-standalone/st-scrollback-reflow-standalone-0.9.3.diff
ST_SCROLLPATCH_FILE := $(ST_LOCAL)/patches/01-scroll.diff

QMK_HOME ?= $(HOME_DIR)/qmk_firmware
QMK_KEYBOARD ?= crkbd/r2g
QMK_KEYMAP ?= paul
QMK_LOCAL_KEYMAP := $(LOCAL_SRC)/qmk_crkbd_r2g
QMK_KEYMAP_DIR := $(QMK_HOME)/keyboards/$(QMK_KEYBOARD)/keymaps/$(QMK_KEYMAP)
QMK_FLASH_LEFT_BL ?= avrdude-split-left
QMK_FLASH_RIGHT_BL ?= avrdude-split-right

.PHONY: help dry-run home unstow-home restow-home st-scroll-patch st dwm submodules-clean \
	qmk-sync qmk-flash-both


help:
	@printf "%s\n" \
	  "make dry-run            preview stow into $$HOME" \
	  "make home               stow home/ into $$HOME" \
	  "make unstow-home        remove stow links for home/" \
	  "make restow-home        restow home/ into $$HOME" \
	  "make st                 install st with upstream scrollback patch" \
	  "make dwm                install dwm with local config and patches" \
	  "make qmk-sync           copy local QMK keymap into ~/qmk_firmware" \
	  "make qmk-flash-both     flash both halves; retries the second automatically" \
	  "make submodules-clean   reset and clean all git submodules" 


dry-run:
	stow -nvR -d . -t "$(HOME_DIR)" "$(HOME_SRC)"

home:
	stow -vR -d . -t "$(HOME_DIR)" "$(HOME_SRC)"
	@chmod 700 "$(HOME_DIR)/.ssh" 2>/dev/null || true
	@if [ -f "$(HOME_DIR)/.ssh/config" ]; then chmod 600 "$(HOME_DIR)/.ssh/config"; fi
	@if [ -f "$(HOME_DIR)/.ssh/config.example" ]; then chmod 600 "$(HOME_DIR)/.ssh/config.example"; fi

unstow-home:
	stow -vD -d . -t "$(HOME_DIR)" "$(HOME_SRC)"

restow-home:
	stow -vR -d . -t "$(HOME_DIR)" "$(HOME_SRC)"
	@chmod 700 "$(HOME_DIR)/.ssh" 2>/dev/null || true
	@if [ -f "$(HOME_DIR)/.ssh/config" ]; then chmod 600 "$(HOME_DIR)/.ssh/config"; fi
	@if [ -f "$(HOME_DIR)/.ssh/config.example" ]; then chmod 600 "$(HOME_DIR)/.ssh/config.example"; fi

submodules-clean:
	git submodule update --init --recursive
	git submodule foreach --recursive 'git reset --hard && git clean -fd'
	rm -f "$(ST_SCROLLPATCH_FILE)"

st-scroll-patch:
	rm -f "$(ST_SCROLLPATCH_FILE)"
	mkdir -p "$(ST_LOCAL)/patches"
	curl -LfsS "$(ST_SCROLLPATCH_URL)" -o "$(ST_SCROLLPATCH_FILE)"

st: st-scroll-patch
	@if ! git -C "$(ST_DIR)" rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
		echo "Missing or uninitialized git repo at $(ST_DIR)."; \
		exit 1; \
	fi
	git -C "$(ST_DIR)" reset --hard
	git -C "$(ST_DIR)" clean -fd
	git -C "$(ST_DIR)" apply --3way "$(abspath $(ST_SCROLLPATCH_FILE))"
	cp "$(ST_LOCAL)/config.h" "$(ST_DIR)/config.h"
	$(MAKE) -C "$(ST_DIR)" clean
	$(MAKE) -C "$(ST_DIR)" -j"$(JOBS)"
	sudo $(MAKE) -C "$(ST_DIR)" PREFIX="$(SUCKLESS_PREFIX)" install

dwm:
	@if ! git -C "$(DWM_DIR)" rev-parse --is-inside-work-tree >/dev/null 2>&1; then \
		echo "Missing or uninitialized git repo at $(DWM_DIR)."; \
		exit 1; \
	fi
	git -C "$(DWM_DIR)" reset --hard
	git -C "$(DWM_DIR)" clean -fd
	cp "$(DWM_LOCAL)/config.h" "$(DWM_DIR)/config.h"
	@if [ -d "$(DWM_LOCAL)/patches" ]; then \
		find "$(abspath $(DWM_LOCAL)/patches)" -maxdepth 1 -type f \( -name '[0-9][0-9]-*.patch' -o -name '[0-9][0-9]-*.diff' \) | sort | while read -r p; do \
			echo "Applying $$p"; \
			git -C "$(DWM_DIR)" apply --3way "$$p"; \
		done; \
	fi
	$(MAKE) -C "$(DWM_DIR)" clean
	$(MAKE) -C "$(DWM_DIR)" -j"$(JOBS)"
	sudo $(MAKE) -C "$(DWM_DIR)" PREFIX="$(SUCKLESS_PREFIX)" install


qmk-sync: 
	@command -v qmk >/dev/null 2>&1 || { echo "qmk CLI not found in PATH."; exit 1; }
	@[ -d "$(QMK_HOME)" ] || { echo "QMK repo not found at $(QMK_HOME)."; exit 1; }
	@[ -d "$(QMK_HOME)/keyboards/$(QMK_KEYBOARD)" ] || { echo "Keyboard folder missing: $(QMK_HOME)/keyboards/$(QMK_KEYBOARD)"; exit 1; }
	@[ -d "$(QMK_LOCAL_KEYMAP)" ] || { echo "Local keymap folder missing: $(QMK_LOCAL_KEYMAP)"; exit 1; }
	mkdir -p "$(QMK_KEYMAP_DIR)"
	@find "$(QMK_KEYMAP_DIR)" -mindepth 1 -maxdepth 1 -exec rm -rf {} + 2>/dev/null || true
	cp -a "$(QMK_LOCAL_KEYMAP)/." "$(QMK_KEYMAP_DIR)/"
	@echo "Synced $(QMK_LOCAL_KEYMAP) -> $(QMK_KEYMAP_DIR)"

qmk-flash-both: qmk-sync
	cd "$(QMK_HOME)" && qmk flash -kb "$(QMK_KEYBOARD)" -km "$(QMK_KEYMAP)" -bl "$(QMK_FLASH_LEFT_BL)"
	@echo "Flashed left half. Switch to right have now."
	sleep 15
	cd "$(QMK_HOME)" && qmk flash -kb "$(QMK_KEYBOARD)" -km "$(QMK_KEYMAP)" -bl "$(QMK_FLASH_RIGHT_BL)"
