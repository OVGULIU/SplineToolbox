classdef bspline
    % quadratic/cubic uniform bspline class
    %   input control points have to be >= 3 points
    
    properties
        xctrl  % control points x coord
        yctrl  % control points y coord
        nCtrlPt  % number of control points
        nSeg  % number of segements
        kvec  % knot vector
        type
        order    % order of the B-spline
        nknot    % number of knots
        
    end
    
    methods
        % constructor : input control points
        function self= bspline(xc,yc,order)
            self.nCtrlPt= length(xc);
            self.xctrl= xc;
            self.yctrl= yc; 
            self.order= order;
            self.nknot= self.nCtrlPt + self.order + 1;  % number of knots
            self.nSeg= self.nknot- self.order- 1- self.order;  % number seg
            self.kvec= [zeros(1,self.order) linspace(0,1,self.nSeg+1)...
                        ones(1,self.order)];
        end
        % evaluate x,y according vector parameter t:[2,3]    
        function Sout= ppval(self,nt)
            n= self.order;
            m= self.nknot;
            % input : nt: number of t parameters
            tvec= linspace(self.kvec(n+1),self.kvec(m-n),nt);
            Sout= zeros(nt,2);
            for i=1:nt
                Sout(i,:)= self.ppval1(tvec(i));
            end            
        end
    end
    
    methods (Access= private)
        % evaluate x,y according scalar parameter t:[0,1]  
        function S = ppval1(self,t)
            % assign variables
            S= zeros(1,2);
            n= self.order;
            m= self.nknot;
            
            % rule out special clamped case
            if t == self.kvec(1)
                bin= zeros(m-n-1,1);
                bin(1) = 1.0;
            elseif t == self.kvec(end)
                bin= zeros(m-n-1,1);
                bin(end) = 1.0;
            else  % t is within t1 and tm
                % initialize bi0
                bin= zeros(m-1,1);
                for j=1:m-1
                    if (t>= self.kvec(j)) && (t<self.kvec(j+1))
                        bin(j)= 1;
                    else
                        bin(j)= 0;
                    end
                end
                % start loopint
                for k=1:n  % order loop
                    bin1= zeros(m-k-1,1);
                    for i=1:m-k-1  % control pt loop
                        ti= self.kvec(i);
                        tin= self.kvec(i+k);
                        ti1= self.kvec(i+1);
                        tin1= self.kvec(i+k+1);
                        if (tin-ti)==0
                            term1= 0;
                        else
                            term1= (t-ti)/(tin-ti);
                        end
                        if (tin1-ti1)==0
                            term2= 0;
                        else
                            term2= (tin1-t)/(tin1-ti1);
                        end
                        bin1(i)= (term1)*bin(i) +...
                            (term2)*bin(i+1);
                    end
                    bin= bin1;
                end
            end
            % evaluate output point
            for i=1:m-n-1  % control pt loop
                pnow= [self.xctrl(i), self.yctrl(i)];
                S= S+ pnow*bin(i);
            end
        end
    end
end

