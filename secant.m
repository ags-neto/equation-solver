function [x1, tab] = secant(f, x0, x1, tol, max, time)

% catch errors
if (x0 > x1)
    errordlg('x1 must be bigger than x0','Error')
    error('x1 must be bigger than x0')
end

if f(x0)*f(x1) > 0
    errordlg('The interval does not contain a root','Error')
    error('The interval does not contain a root')
end

% default arguments
if nargin < 4
    tol = 1e-4;
    max = 20;
    time = 1;
end

tab = (max);

xx = linspace(x0-1, x1+1, 1000);

figure
axis([x0-1 x1+1 -1 inf])
set(gca,'DataAspectRatio',[1 1 1])
plot(xx, f(xx), 'LineWidth', 1.5)
title('Secant Method')
xlabel("𝑥")
ylabel("f(𝑥)")
grid on
hold on
shg

% initial markings
plot(x0, f(x0), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4)
text(x0, f(x0), "  f(𝑥_0)")
plot(x1, f(x1), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4)
text(x1, f(x1), "  f(𝑥_1)")

for i = 1:max

    % calculate x2
    x2 = (x0*f(x1) - x1*f(x0)) / (f(x1) - f(x0));
    
    % add element to the table
    tab(i) = x2;

    % animations
    line_x0 = plot([x0 x2], [f(x0) 0],'m', 'LineWidth', 1.5, 'LineStyle', '-.');
    line_x1 = plot([x1 x2], [f(x1) 0],'m', 'LineWidth', 1.5, 'LineStyle', '-.');
    dot_x2 = plot(x2, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4);
    pause(time)

    dotted_line = plot([x2 x2],[0 f(x2)],"r", "LineWidth", 1.5, "LineStyle", ":");
    plot(x2, f(x2), 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 4)
    text(x2, f(x2), ["  f(𝑥_{" num2str(i + 1) "})"])
    pause(time)

    % condition
    if abs(x2-x1)<tol
        break
    end

    x0 = x1;
    x1 = x2;

    delete(line_x0)
    delete(line_x1)
    delete(dotted_line)
    delete(dot_x2)
end
end
