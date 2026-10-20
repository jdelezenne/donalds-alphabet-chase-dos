PYTHON ?= python3
.PHONY: all setup build check check-source check-exact recomp run
all: build
setup:
	./setup.sh
build:
	./build.sh all --check-hashes
check: check-source
check-source:
	$(PYTHON) tools/check_source.py
check-exact recomp:
	./recomp.sh
run:
	./run.sh
