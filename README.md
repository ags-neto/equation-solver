# equation-solver

> MATLAB/Octave coursework mini-project that solves one equation in one variable by bisection, Newton-Raphson or secant, animating the iterates, behind a dialog interface instead of a command-line prompt.

## What it is

Three independent solvers for a single equation in one variable. Each one is a
plain function file that takes the equation as a function handle and returns the
last iterate plus the table of every iterate:

| file | signature |
|---|---|
| `bisection.m` | `[c, tab] = bisection(f, x0, x1, tol, max, time)` |
| `secant.m` | `[x1, tab] = secant(f, x0, x1, tol, max, time)` |
| `newtonr.m` | `[x1, tab] = newtonr(f, x0, tol, max, time)` |

Defaults are `tol = 1e-4`, `max = 20` iterations and `time = 1` second between
frames. The default block is guarded by `nargin < 4` in `bisection`/`secant` and
`nargin < 3` in `newtonr`, so calling a solver with some but not all of the
optional arguments leaves the remaining ones undefined: pass all of them or
none. Each solver opens a figure, plots `f`, marks the iterates on the x-axis
and pauses `time` seconds between frames, so the method is animated.

`bisection.m` requires `x0 < x1` and `f(x0)*f(x1) <= 0` and stops when
`f(c) == 0` or when `(x1-x0)/2 < tol`. `secant.m` applies the same two input
checks even though the secant method does not need a sign change, and stops when
`abs(x2-x1) < tol`, returning the previous iterate rather than the newest one.
`newtonr.m` applies no input validation: in MATLAB the derivative comes from the
Symbolic Math Toolbox (`sym`, `diff`, `matlabFunction`) and where
`matlabFunction` is not available, as in Octave, it falls back to a central
difference with `h = 1e-6`. The fallback agrees with the analytic derivative to
2.3e-16 or better on the test functions. None of the three reports
non-convergence: after `max` iterations each returns its last iterate anyway.

`projetodlg.m` is the entry point. `listdlg` picks the method, `inputdlg`
collects the equation (pre-filled with `exp(x-3/2)-1`) and the parameters of the
chosen method, the solver runs inside a `try`/`catch` that reopens the parameter
dialog and prints the error message, and a `uitable` with the iterate history and
a `msgbox` with the result close the flow. It is built from MathWorks dialog
functions and does not run under Octave without a graphical toolkit. The GUI
title is `Miniproject MCEE 21/21`. `README.txt` records the intent (make as
little use of the command window as possible, with the long-term idea of a real
`.exe`) and names the authors: Ines Ferreira and Andre Neto.

### Known limitations

- `tab = (max)` at the top of the three solvers is not a preallocation: it
  assigns the scalar `max` to `tab`. `tab` still ends up with one row per
  iteration because it grows by indexing, so the returned values are correct and
  the line is only misleading.
- `newtonr.m` with `f'(x0) == 0` announces `x1 is local min/max` through
  `errordlg` and returns before assigning `x1`. A caller that asks for the
  output then fails with `element number 1 undefined in return list`.
- `secant.m` rejects an interval without a sign change, which the secant method
  itself does not require.
- Neither `bisection.m` nor `secant.m` can tell the caller that it stopped
  because it ran out of iterations instead of reaching `tol`.

## Requirements

- MATLAB, or Octave. Tested with **Octave 9.4.0** on Debian 13 (aarch64); no
  Octave package is needed, `newtonr.m` runs without `symbolic`.
- In MATLAB, `newtonr.m` uses the Symbolic Math Toolbox when it is installed.
- Without a display, Octave needs a graphics toolkit for the plots the solvers
  draw: `gnuplot-nox` and `fonts-freefont-otf`. Without the fonts Octave stops
  at `ft_text_renderer: invalid bounding box, cannot render`.
- `projetodlg.m` needs MATLAB, or an Octave built with the `qt` toolkit, and a
  display.
- No third-party MATLAB code is included.

## Install / Build

Nothing to build; the `.m` files run from the repository directory.

```bash
sudo apt-get install octave                            # Octave itself
sudo apt-get install gnuplot-nox fonts-freefont-otf    # only without a display
```

## Usage

Command line, no window needed:

```console
$ make demo
equation x^3-1 = 0, tol 1e-10, max 200 iterations
bisection -> 1.0000000000   (tab rows: 1)
secant    -> 1.0000000000   (tab rows: 13)
newtonr   -> 1.0000000000   (tab rows: 7)
```

Or drive a solver directly. The figure is made invisible and stdout, which
carries the plot, is discarded; the result is written to stderr:

```console
$ octave-cli --no-gui --eval "warning('off','all'); set(0,'defaultfigurevisible','off');
    graphics_toolkit('gnuplot'); [c,tab]=bisection(@(x) cos(x)-x,0,1,1e-10,200,0);
    fprintf(stderr,'root=%.10f  tab rows=%d\n',c,numel(tab))" >/dev/null
root=0.7390851332  tab rows=34
```

The dialog interface is started from MATLAB (or from Octave with a display):

```matlab
projetodlg
```

## Tests

`make test` runs `tests/run_tests.m`, which calls every method at `tol = 1e-10`
and compares the result with a root known analytically, using an assertion
tolerance of `1e-6` — four orders of magnitude tighter than the solver default.
It also checks that four malformed inputs raise their documented error. It exits
with 0 when everything passes and 1 when any check fails.

```console
$ make test
equation-solver test suite - Octave 9.4.0
solvers called with tol=1e-10, max=200, time=0; assertion tolerance 1e-06

method     file          case                        |x-root|     result
bisection  bisection.m   x^3-1 = 0 on [0,2]          0.000e+00    pass
bisection  bisection.m   cos(x)-x = 0 on [0,1]       3.052e-11    pass
bisection  bisection.m   x^2-2 = 0 on [0,2]          4.706e-11    pass
secant     secant.m      x^3-1 = 0 on [0,2]          2.133e-11    pass
secant     secant.m      cos(x)-x = 0 on [0,1]       1.594e-13    pass
secant     secant.m      x^2-2 = 0 on [0,2]          2.220e-16    pass
newtonr    newtonr.m     x^3-1 = 0 from x0=2         0.000e+00    pass
newtonr    newtonr.m     cos(x)-x = 0 from x0=0.5    0.000e+00    pass
newtonr    newtonr.m     x^2-2 = 0 from x0=1         0.000e+00    pass

rejected inputs (each one must raise its documented error)
method     file          case                        result
bisection  bisection.m   x^2+1 = 0 on [-2,2]: no root pass
secant     secant.m      x^2+1 = 0 on [-2,2]: no root pass
bisection  bisection.m   x0=2, x1=0: x0 > x1         pass
secant     secant.m      x0=2, x1=0: x0 > x1         pass

known issues, not fixed here (see README, Known limitations)
  * tab = (max) at the top of the three solvers is not a preallocation: it
    assigns the scalar max to tab. tab still holds one row per iteration because
    it grows by indexing, so the values are correct and the line is only
    misleading.  Here: bisection over [0,1] with max=200 kept 34 rows.
  * newtonr with f'(x0) == 0 announces "x1 is local min/max" through errordlg
    and returns before assigning x1.  A caller that asks for the output gets:
    element number 1 undefined in return list

OK: 13 checks, 0 failures
```

The plots the solvers draw go to stdout and are captured in
`tests/.last-run.log`; only the report above is printed. `make run` starts
`projetodlg.m` and needs a display — without one it stops with
`error: listdlg is not available in this version of Octave`.

## Structure

```
bisection.m         71  bisection method, animated plot, iterate table
newtonr.m           63  Newton-Raphson: symbolic derivative, numeric fallback
secant.m            74  secant method, animated plot, iterate table
projetodlg.m        84  dialog interface and entry point
README.txt          15  original side notes: intent, language choice, authors
LICENSE             21  MIT, added 2026-10-08, copyright year 2022
Makefile            38  targets: help, test, demo, run, clean
tests/run_tests.m  166  the suite `make test` runs
tests/demo.m        32  the numbers `make demo` prints
.gitignore           7  MATLAB autosave/workspace files, captured plot output
```

The four `.m` files kept from the original upload use CRLF line endings; the
files added here use LF.

## License

MIT — see [`LICENSE`](LICENSE). The file was added on 2026-10-08 and carries the
year of the first commit, 2022. This is coursework written by two people, so the
copyright line names both: **Inês Ferreira and André Neto**. `README.txt` records
them as the authors and maintainers — "Ines Ferreira - inesjorge300@gmail.com" and
"Andre Neto - netoandre.neto@gmail.com" — and `LICENSE` carried only André Neto;
the co-author has not been separately asked about this licence pass.
