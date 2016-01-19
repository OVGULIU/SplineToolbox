function [data,speed]= PathSpeedEstimation(omega, varargin)
% function [data,speed]= PathSpeedEstimation(omega, filename)
%
% omega: vehicle angular speed, usually use max steering rate as approx.
% filename: path mat file name

if nargin==2
    filename= varargin{1};
    pathname= cd();
else
    [filename, pathname] = uigetfile( ...
        '*.mat', 'Path Files (*.mat)', ...
        'Pick a path file',...
        'multiselect','on');
end

if ~iscell(filename)
    filenames{1}= filename;
end

for i=1:length(filenames)
    fnow= filenames{i};
    s= load(fullfile(pathname,fnow));
    
    if isfield(s,'ctrlPt')
        ctrlPt= s.ctrlPt;
    else
        ctrlPt= [];
    end
    data= s.data;
    rReal= raduisEstimate(s.data);
    
    % remove NAN (identical path points)
    inan= isnan(rReal);
    data(inan,:)=[];
    rReal(inan)=[];
    
    % get moving min
    rVec= movingMin(rReal,9);
    
    % estimate speed
    speed= rVec.*omega;
    
    % save file now
    save(fullfile(pathname,fnow),'data','ctrlPt','rReal','rVec','speed');
end

%% moving minimal 
function rvec= movingMin(rReal,npt)
nside= ceil(npt/2);
m= length(rReal);
rvec= zeros(m,1);
for i=1:m
   if i<= nside
       rvec(i)= min(rReal(1:npt));
   elseif i>(m-nside)
       rvec(i)= min(rReal(m-npt+1:m));
   else       
       rvec(i)= min(rReal(i-nside:i+nside));
   end
end

%% raduis estimation
function rvec= raduisEstimate(data) 
npt= size(data,1);
rvec= zeros(npt,1);
for i=1:npt
    if i==1
        pt1= data(i,:);
        pt2= data(i+1,:);
        pt3= data(i+2,:);
    elseif i==npt
        pt1= data(i-2,:);
        pt2= data(i-1,:);
        pt3= data(i,:);
    else    
        pt1= data(i-1,:);
        pt2= data(i,:);
        pt3= data(i+1,:);    
    end
    rvec(i)= radiusOutFrom3pt(pt1,pt2,pt3);
end

%% radius of outer circle from 3pt
function r= radiusOutFrom3pt(pt1,pt2,pt3)

th= 0.03;
rmat= [cosd(th) sind(th);-sind(th) cosd(th)];
if (pt1(1)==pt2(1)) || (pt2(1)==pt3(1))
    % rotate a small amount
    pt1= rmat*pt1(:);
    pt2= rmat*pt2(:);
    pt3= rmat*pt3(:);
end
% assign variables
x1= pt1(1);
x2= pt2(1);
x3= pt3(1);
y1= pt1(2);
y2= pt2(2);
y3= pt3(2);

% get slope 
m1= (y2-y1)/(x2-x1);
m2= (y3-y2)/(x3-x2);

if m1==m2
    r= inf;
    return 
end
% get x
x= (m1*m2*(y3-y1)+m1*(x2+x3)-m2*(x1+x2)) / (2*(m1-m2));
y= -(x-(x1+x2)/2)/m1 + (y1+y2)/2;
% get r
r= sqrt((x1-x)^2+(y1-y)^2);


%% radius of inner circle from 3 pts
function r= radiusInFrom3pt(pt1,pt2,pt3)
th= 0.03;
rmat= [cosd(th) sind(th);-sind(th) cosd(th)];
if (pt1(1)==pt2(1)) || (pt2(1)==pt3(1))
    % rotate a small amount
    pt1= rmat*pt1(:);
    pt2= rmat*pt2(:);
    pt3= rmat*pt3(:);
end
% assign variables
x1= pt1(1);
x2= pt2(1);
x3= pt3(1);
y1= pt1(2);
y2= pt2(2);
y3= pt3(2);

% get slope 
m1= (y2-y1)/(x2-x1);
m2= (y3-y2)/(x3-x2);

if m1==m2
    r= inf;
    return 
end

% get vectors
v1= [x1-x2; y1-y2];
v2= [x3-x2; y3-y2];
l1= norm(v1);
l2= norm(v2);
u1= v1./l1;
u2= v2./l2;

% get theta
theta= acos(u1'*u2);

% get r
r= max(l1,l2)*tan(0.5*theta);





    



