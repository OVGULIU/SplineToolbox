# BSpline Toolbox
BSpline Toolbox in MATLAB

This project provides MATLAB functions to generate BSpline and bezier curve.

## Dependency
This project is in MATLAB code so MATLAB is required.

## Usage
The BSpline and bezier curve is implemented in class. Take BSpline as example,
to construct the bspline object, you need x,y vectors and the order of the bspline:

```
x = linspace(0,100,10);
y = linspace(0,100,10);
order= 4;
bsp= bspline(x,y,order);

>>
     xctrl: [0 11.1111 22.2222 33.3333 44.4444 55.5556 66.6667 77.7778 88.8889 100]
      yctrl: [0 11.1111 22.2222 33.3333 44.4444 55.5556 66.6667 77.7778 88.8889 100]
    nCtrlPt: 10
       nSeg: 6
       kvec: [0 0 0 0 0 0.1667 0.3333 0.5000 0.6667 0.8333 1 1 1 1 1]
       type: []
      order: 4
      nknot: 15
```

To interpolate 100 points on the curve:

```
% number of points
n= 100;
xy_out= bsp.ppval(n);
```

To plot the curve:

```
plot(xy_out)
```
!(bspline)[./images/bspline.png]
 
A test GUI is also provided, run **test_spline.m** to start the GUI
!(bspline_gui)[./images/bspline_gui.png]

