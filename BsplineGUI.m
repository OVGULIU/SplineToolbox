classdef BsplineGUI < handle
    % GUI to test spline function
    properties
        xdata
        ydata
        cs
        order   % bspline order
        h_fig
        h_ax
        h_plt_line
        h_plt_ctrlpt
        h_plt_hpt % highlighted point
        ind_hpt   % highelighted point index
        timerS
        
    end
    
    methods
        function self= BsplineGUI(x,y,order)
            self.xdata= x;
            self.ydata= y;
            self.order= order;
            self.cs = bspline(x, y, order);
            
            %% setup GUI
            self.setupUI();
            %self.timerS= timer();
            %set(self.timerS,'TimerFcn',@guiupdate,...
            %    'InstantPeriod',1);            
            %self.timerS.start();
        end
        function setupUI(self)
            self.h_fig= figure();
            %maxfig(self.h_fig,1);
            self.h_ax= axes();
            %% plot now
            self.plotnow();
            %% setup callback
            set(self.h_fig,'WindowButtonMotionFcn',@self.mouseMove);
            set(self.h_fig,'WindowButtonDownFcn',@self.mouseDown);
            
        end
        function plotnow(self)
            if ishandle(self.h_plt_ctrlpt), delete(self.h_plt_ctrlpt); end
            if ishandle(self.h_plt_line), delete(self.h_plt_line); end
            npt= 101;
            bout= self.cs.ppval(npt);
            
            self.h_plt_ctrlpt= plot(self.h_ax, self.xdata,self.ydata,'bo-');
            hold all;
            self.h_plt_line= plot(self.h_ax,bout(:,1),bout(:,2),'r-');
            hold all;
            xmin= min(self.xdata);
            xmax= max(self.xdata);
            dx= xmax - xmin;
            ymin= min(self.ydata);
            ymax= max(self.ydata);
            dy= ymax - ymin;
            axis([xmin-0.1*dx xmax+0.1*dx,...
                  ymin-0.1*dy ymax+0.1*dy]);
        end
        function mouseMove(self,hobj,evt)
            % delete highlighted line first
            if ishandle(self.h_plt_hpt), delete(self.h_plt_hpt); end
            % update current point
            C= get(self.h_ax,'CurrentPoint');
            title(self.h_ax,sprintf('(X,Y)=(%8.4f,%8.4f)',...
                C(1,1),C(1,2)));
            % detect whether to snap a point
            xlim= get(self.h_ax,'xlim');
            ylim= get(self.h_ax,'ylim');
            tol= norm([(xlim(end)-xlim(1)) (ylim(end)-ylim(1))])/20;
            for i=1:length(self.xdata)
                xnow= self.xdata(i);
                ynow= self.ydata(i);
                dist= norm(C(1,1:2)-[xnow,ynow]);
                if dist < tol
                    self.h_plt_hpt= plot(self.h_ax,xnow,ynow,'ro',...
                        'markersize',12);
                    self.ind_hpt= i;
                    break;
                end 
            end
        end
        function mouseDown(self,hobj,evt)
            if ishandle(self.h_plt_hpt)
                set(self.h_fig,'WindowButtonMotionFcn',@self.mouseDrag);
                set(self.h_fig,'WindowButtonUpFcn',@self.mouseUp);                
            end
        end
        function mouseDrag(self,hobj,evt)
            % update current point title
            C= get(self.h_ax,'CurrentPoint');
            title(self.h_ax,sprintf('(X,Y)=(%8.4f,%8.4f)',...
                C(1,1),C(1,2)));
            % updata highlighted point plot
            set(self.h_plt_hpt,'xdata',C(1,1));
            set(self.h_plt_hpt,'ydata',C(1,2));
            % update control points data and plot
            self.xdata(self.ind_hpt)= C(1,1);
            self.ydata(self.ind_hpt)= C(1,2);
            set(self.h_plt_ctrlpt,'xdata', self.xdata);
            set(self.h_plt_ctrlpt,'ydata', self.ydata);            
        end
        function mouseUp(self,hobj,evt)
            % reset spline model
            self.cs = bspline(self.xdata, self.ydata, self.order);
           
            % plot now
            self.plotnow;
            % reset WindowButton functions
            set(self.h_fig,'WindowButtonMotionFcn',@self.mouseMove);
            set(self.h_fig,'WindowButtonUpFcn',[]);            
        end
            
    end
    
end

