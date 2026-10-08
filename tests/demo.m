% Command-line demo used by `make demo`: the three methods on x^3-1 = 0.
% The numbers go to stderr; the plot the solvers draw goes to stdout and the
% Makefile captures it in tests/.last-run.log.

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

f = @(x) x.^3 - 1;

fprintf(stderr, 'equation x^3-1 = 0, tol 1e-10, max 200 iterations\n');
for step = 1:3
  if (step == 1)
    [x, t] = bisection(f, 0, 2, 1e-10, 200, 0);
    name = 'bisection';
  elseif (step == 2)
    [x, t] = secant(f, 0, 2, 1e-10, 200, 0);
    name = 'secant   ';
  else
    [x, t] = newtonr(f, 2, 1e-10, 200, 0);
    name = 'newtonr  ';
  end
  fprintf(stderr, '%s -> %.10f   (tab rows: %d)\n', name, x, numel(t));
end
