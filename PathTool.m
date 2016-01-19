function PathTool()
clc;
close all;

x = linspace(0,100,10);
y = linspace(0,100,10);

% sg= SplineGUI(x,y);
% sg= BezierGUI(x,y);
sg= BsplineGUI(x,y,2);

% cs = spline(x,[0 y 0]);
% xx = linspace(-4,4,101);
% plot(x,y,'o',xx,ppval(cs,xx),'-');