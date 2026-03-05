# WordPress script — Makefile for macOS and Windows (2026)
# Windows: use from Git Bash or with GNU Make (Chocolatey/Scoop). Requires Docker Desktop.

SHELL := /bin/sh
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# OS detection: Windows_NT when running on Windows (cmd, PowerShell, Git Bash)
# MINGW* / MSYS* from uname when using Git Bash on Windows
UNAME_S := $(shell uname -s 2>/dev/null || echo Unknown)
IS_WIN := $(or $(findstring Windows_NT,$(OS)),$(findstring MINGW,$(UNAME_S)),$(findstring MSYS,$(UNAME_S)))

WORDPRESS_DIR := docker-wordpress
COMPOSE_SRC := yaml/docker-compose.yaml
COMPOSE_DEST := $(WORDPRESS_DIR)/docker-compose.yaml
RESET_SCRIPT_SRC := script/reset-wp-password.php
RESET_SCRIPT_DEST := $(WORDPRESS_DIR)/reset-wp-password.php

.PHONY: help init run stop clean install list-users reset-pw

# Default target
help:
	@echo "WordPress Docker launcher — macOS / Windows"
	@echo ""
	@echo "Targets:"
	@echo "  make init    Create docker-wordpress/ and copy docker-compose.yaml (run once)"
	@echo "  make run     Start WordPress stack and open browser"
	@echo "  make stop    Stop WordPress stack"
	@echo "  make clean   Remove docker-wordpress/ directory"
	@echo "  make install (macOS/Linux only) chmod +x script/wordpress"
	@echo "  make list-users        List WordPress users (containers must be running)"
	@echo "  make reset-pw USER=id  Reset admin password: make reset-pw USER=admin PASS=newpass"
	@echo ""
	@echo "Initialization: run 'make init' first, then 'make run' or 'make stop'."

# Create directory and copy compose file — same on macOS and Windows (Git Bash)
init:
	@mkdir -p "$(WORDPRESS_DIR)"
	@cp "$(COMPOSE_SRC)" "$(COMPOSE_DEST)"
	@cp "$(RESET_SCRIPT_SRC)" "$(RESET_SCRIPT_DEST)"
	@echo "Initialized $(WORDPRESS_DIR)/ with docker-compose.yaml"

# Run WordPress: use PowerShell on Windows, bash script elsewhere
run: init
ifdef IS_WIN
	@powershell -NoProfile -ExecutionPolicy Bypass -File "$(MAKEFILE_DIR)script/wordpress.ps1" -Run
else
	@bash "$(MAKEFILE_DIR)script/wordpress" -r
endif

# Stop WordPress
stop:
ifdef IS_WIN
	@powershell -NoProfile -ExecutionPolicy Bypass -File "$(MAKEFILE_DIR)script/wordpress.ps1" -Stop
else
	@bash "$(MAKEFILE_DIR)script/wordpress" -s
endif

# Remove initialized directory (does not remove Docker volumes)
clean:
	@rm -rf "$(WORDPRESS_DIR)"
	@echo "Removed $(WORDPRESS_DIR)/"

# macOS/Linux: make script executable (no-op on Windows)
install:
ifdef IS_WIN
	@echo "On Windows use: powershell -File script/wordpress.ps1 -Run"
else
	@chmod +x "$(MAKEFILE_DIR)script/wordpress"
	@echo "script/wordpress is executable"
endif

# List WordPress admin users (run with stack up: make run first)
list-users:
	@cd "$(WORDPRESS_DIR)" && docker compose exec wordpress php /var/www/html/reset-wp-password.php 2>/dev/null || echo "Run 'make run' first, then try again."

# Reset WordPress admin password (USER=login or id, PASS=new password)
# Example: make reset-pw USER=admin PASS=mynewpassword
reset-pw:
ifndef USER
	$(error Use: make reset-pw USER=admin PASS=yournewpassword)
endif
ifndef PASS
	$(error Use: make reset-pw USER=admin PASS=yournewpassword)
endif
	@cd "$(WORDPRESS_DIR)" && docker compose exec wordpress php /var/www/html/reset-wp-password.php "$(USER)" "$(PASS)"
	@echo "Log in at http://localhost:8080/wp-admin"
