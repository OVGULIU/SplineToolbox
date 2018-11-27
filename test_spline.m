function test_spline()
clc;
close all;

x = linspace(0,100,10);
y = linspace(0,100,10);

% Ask user about the spline options
answer = questdlg('Please select the spline option:', ...
	'Spline Type', ...
	'BSpline','Bezier Curve','BSpline');
% Handle response
switch answer
    case 'BSpline'
        sg= BsplineGUI(x,y,2);
    case 'Bezier Curve'
        sg= BezierGUI(x,y);
end

