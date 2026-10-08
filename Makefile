# equation-solver - run the solvers and the test suite.
#
#   make test    run tests/run_tests.m under Octave (exit 0 = pass, 1 = fail)
#   make demo    solve x^3-1 = 0 with the three methods, prints the numbers
#   make run     start the dialog interface projetodlg (needs a display)
#   make clean   delete the captured plot output
#
# The solvers plot the function while they iterate, so Octave needs a graphics
# toolkit.  On a machine with no display, install gnuplot-nox and
# fonts-freefont-otf; the scripts then create the figure invisible and the
# Makefile captures what gnuplot renders in tests/.last-run.log.

SHELL  := /bin/bash
OCTAVE ?= octave-cli
LOG    := tests/.last-run.log

.PHONY: help test demo run clean

help:
	@echo "make test    run the Octave test suite (tests/run_tests.m)"
	@echo "make demo    solve x^3-1 = 0 with the three methods, no window needed"
	@echo "make run     start the dialog interface projetodlg (needs a display)"
	@echo "make clean   delete tests/.last-run.log"

test:
	@$(OCTAVE) --no-gui tests/run_tests.m 1>$(LOG); \
	rc=$$?; \
	if [ $$rc -ne 0 ]; then echo "(plot output kept in $(LOG))" >&2; fi; \
	exit $$rc

demo:
	@$(OCTAVE) --no-gui tests/demo.m 1>$(LOG)

run:
	@$(OCTAVE) --no-gui projetodlg.m

clean:
	rm -f $(LOG)
