PYTHON ?= python3

.PHONY: all check check-source check-exact
all:
	tools/relink.sh all --check-hashes

# Public, Turbo-C-free checks against the real sources and NASM objects.
check: check-source

check-source:
	$(PYTHON) tools/check_source.py

# A fresh source-only copy, pinned compiler/headers, both complete file hashes.
# No original executable or asset is accepted as an input.
check-exact:
	$(PYTHON) tools/verify_clean_build.py
