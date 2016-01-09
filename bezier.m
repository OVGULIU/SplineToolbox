classdef bezier
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        xctrl  % control points x coord
        yctrl  % control points y coord
        nCtrlPt  % number of control points
    end
    
    methods
        % constructor : input control points
        function self= bezier(xc,yc)
            self.xctrl= xc;
            self.yctrl= yc;
            self.nCtrlPt= length(xc);
        end
        % evaluate x,y according vector parameter t:[0,1]    
        function Bout= ppval(self,tvec)
            nt= length(tvec);
            Bout= zeros(nt,2);
            for i=1:nt
                Bout(i,:)= self.ppval1(tvec(i));
            end            
        end
    end
    
    methods (Access= private)
        % evaluate x,y according scalar parameter t:[0,1]  
        function B0 = ppval1(self,t)
            % initialize B_p0
            B0= [0 0];
            n= self.nCtrlPt-1;
            for i=0:n
                coef= factorial(n)/factorial(i)/factorial(n-i);
                pnow= [self.xctrl(i+1) self.yctrl(i+1)];
                B0= B0 + coef*(1-t)^(n-i)*t^i*pnow; 
            end
        end
        
    end
    
end

