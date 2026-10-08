% equation-solver - test suite.
%
%   make test
%   octave-cli --no-gui tests/run_tests.m
%
% Every method is called with a tolerance of 1e-10 and 200 iterations and the
% result is compared with the root known analytically.  The assertion tolerance
% used here is 1e-6, four orders of magnitude tighter than the 1e-4 default of
% the solvers.
%
% The solvers draw the function while they iterate.  There is no window here, so
% the figure is created invisible with the gnuplot toolkit; what gnuplot renders
% goes to stdout and the Makefile redirects it to tests/.last-run.log.  The
% report below is written to stderr so that it stays readable.
%
% Exit status is 0 when every check passes and 1 otherwise.

if (isempty(which('bisection')))
  here = fileparts(mfilename('fullpath'));
  if (isempty(here))
    here = fullfile(pwd, 'tests');
  end
  addpath(fullfile(here, '..'));
end

warning('off', 'all');
set(0, 'defaultfigurevisible', 'off');
graphics_toolkit('gnuplot');

TOL  = 1e-6;    % assertion tolerance
MTOL = 1e-10;   % tolerance handed to the solvers
MAXI = 200;     % iteration cap handed to the solvers
T    = 0;       % seconds between animation frames

methods = {'bisection', 'bisection', 'bisection', ...
           'secant',    'secant',    'secant', ...
           'newtonr',   'newtonr',   'newtonr'};
files = {'bisection.m', 'bisection.m', 'bisection.m', ...
         'secant.m',    'secant.m',    'secant.m', ...
         'newtonr.m',   'newtonr.m',   'newtonr.m'};
labels = {'x^3-1 = 0 on [0,2]', ...
          'cos(x)-x = 0 on [0,1]', ...
          'x^2-2 = 0 on [0,2]', ...
          'x^3-1 = 0 on [0,2]', ...
          'cos(x)-x = 0 on [0,1]', ...
          'x^2-2 = 0 on [0,2]', ...
          'x^3-1 = 0 from x0=2', ...
          'cos(x)-x = 0 from x0=0.5', ...
          'x^2-2 = 0 from x0=1'};
roots = [1, 0.7390851332151607, sqrt(2), ...
         1, 0.7390851332151607, sqrt(2), ...
         1, 0.7390851332151607, sqrt(2)];
calls = {@() bisection(@(x) x.^3-1, 0, 2, MTOL, MAXI, T), ...
         @() bisection(@(x) cos(x)-x, 0, 1, MTOL, MAXI, T), ...
         @() bisection(@(x) x.^2-2, 0, 2, MTOL, MAXI, T), ...
         @() secant(@(x) x.^3-1, 0, 2, MTOL, MAXI, T), ...
         @() secant(@(x) cos(x)-x, 0, 1, MTOL, MAXI, T), ...
         @() secant(@(x) x.^2-2, 0, 2, MTOL, MAXI, T), ...
         @() newtonr(@(x) x.^3-1, 2, MTOL, MAXI, T), ...
         @() newtonr(@(x) cos(x)-x, 0.5, MTOL, MAXI, T), ...
         @() newtonr(@(x) x.^2-2, 1, MTOL, MAXI, T)};

fprintf(stderr, 'equation-solver test suite - Octave %s\n', version());
fprintf(stderr, 'solvers called with tol=%g, max=%d, time=%g; assertion tolerance %g\n\n', ...
        MTOL, MAXI, T, TOL);
fprintf(stderr, '%-10s %-13s %-27s %-12s %s\n', 'method', 'file', 'case', '|x-root|', 'result');

checks = 0;
failures = 0;

for k = 1:numel(calls)
  checks = checks + 1;
  status = 'pass';
  detail = '';
  errs = '-';
  try
    x = calls{k}();
    if (isempty(x) || !isscalar(x) || !isfinite(x))
      status = 'FAIL';
      detail = 'result is not a finite scalar';
    else
      err = abs(x - roots(k));
      errs = sprintf('%.3e', err);
      if (err > TOL)
        status = 'FAIL';
        detail = sprintf('got %.15g, error above the assertion tolerance', x);
      end
    end
  catch e
    status = 'FAIL';
    detail = sprintf('unexpected error: %s', e.message);
  end
  if (strcmp(status, 'FAIL'))
    failures = failures + 1;
    errs = '-';
  end
  fprintf(stderr, '%-10s %-13s %-27s %-12s %s\n', methods{k}, files{k}, labels{k}, errs, status);
  if (!isempty(detail))
    fprintf(stderr, '%-10s %-13s %s\n', '', '', detail);
  end
end

fprintf(stderr, '\nrejected inputs (each one must raise its documented error)\n');
fprintf(stderr, '%-10s %-13s %-27s %s\n', 'method', 'file', 'case', 'result');

rejlabels = {'x^2+1 = 0 on [-2,2]: no root', ...
             'x^2+1 = 0 on [-2,2]: no root', ...
             'x0=2, x1=0: x0 > x1', ...
             'x0=2, x1=0: x0 > x1'};
rejfiles = {'bisection.m', 'secant.m', 'bisection.m', 'secant.m'};
rejcalls = {@() bisection(@(x) x.^2+1, -2, 2, MTOL, MAXI, T), ...
            @() secant(@(x) x.^2+1, -2, 2, MTOL, MAXI, T), ...
            @() bisection(@(x) x.^3-1, 2, 0, MTOL, MAXI, T), ...
            @() secant(@(x) x.^3-1, 2, 0, MTOL, MAXI, T)};
rejwanted = {'The interval does not contain a root', ...
             'The interval does not contain a root', ...
             'x1 must be bigger than x0', ...
             'x1 must be bigger than x0'};

for k = 1:numel(rejcalls)
  checks = checks + 1;
  status = 'pass';
  detail = '';
  try
    x = rejcalls{k}();
    status = 'FAIL';
    detail = 'no error raised';
  catch e
    if (!strcmp(e.message, rejwanted{k}))
      status = 'FAIL';
      detail = sprintf('wrong error: %s', e.message);
    end
  end
  if (strcmp(status, 'FAIL'))
    failures = failures + 1;
  end
  fprintf(stderr, '%-10s %-13s %-27s %s\n', ...
          strrep(rejfiles{k}, '.m', ''), rejfiles{k}, rejlabels{k}, status);
  if (!isempty(detail))
    fprintf(stderr, '%-10s %-13s %s\n', '', '', detail);
  end
end

fprintf(stderr, '\nknown issues, not fixed here (see README, Known limitations)\n');
[bc, bt] = bisection(@(x) cos(x)-x, 0, 1, MTOL, MAXI, T);
nrows = numel(bt);
fprintf(stderr, '  * tab = (max) at the top of the three solvers is not a preallocation: it\n');
fprintf(stderr, '    assigns the scalar max to tab. tab still holds one row per iteration because\n');
fprintf(stderr, '    it grows by indexing, so the values are correct and the line is only\n');
fprintf(stderr, '    misleading.  Here: bisection over [0,1] with max=200 kept %d rows.\n', nrows);
fprintf(stderr, '  * newtonr with f''(x0) == 0 announces "x1 is local min/max" through errordlg\n');
fprintf(stderr, '    and returns before assigning x1.  A caller that asks for the output gets:\n');
try
  [r, t] = newtonr(@(x) x.^2-1, 0, MTOL, MAXI, T);
  fprintf(stderr, '    (no error; it returned %g)\n', r);
catch e
  fprintf(stderr, '    %s\n', e.message);
end

if (failures > 0)
  fprintf(stderr, '\nFAILED: %d of %d checks\n', failures, checks);
  exit(1);
else
  fprintf(stderr, '\nOK: %d checks, 0 failures\n', checks);
  exit(0);
end
