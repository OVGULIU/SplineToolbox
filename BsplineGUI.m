classdef BsplineGUI < handle
    % GUI to test spline function
    properties
        xdata
        ydata
        cs
        order   % bspline order
        h_fig
        h_ax
        h_edNPt
        h_btSave
        h_btLoad
        h_pmOrder
        
        h_cm
        
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
            self.h_fig= figure('position',[500 100 800 800]);
            
            % context menu
            self.h_cm(1)= uicontextmenu;
            self.h_cm(2)= uimenu(self.h_cm(1), 'label','add a point',...
                'callback',@self.pointEdit);
            self.h_cm(3)= uimenu(self.h_cm(1), 'label','delete point',...
                'callback',@self.pointEdit);
            
            %maxfig(self.h_fig,1);
            self.h_ax= axes('units','normalized','position',[0.12 0.2 0.8 0.75]);
                
            
            % export settings
            uicontrol('parent',self.h_fig,'style','text',...
                'units','normalized','position',[0.6 0.11 0.3 0.03],...
                'string','Number of Points to be Exported','fontsize',12);
            self.h_edNPt= uicontrol('parent',self.h_fig,'style','edit',...
                'units','normalized','position',[0.675 0.07 0.15 0.03],...
                'string','50','fontsize',12);
            self.h_btSave= uicontrol('parent',self.h_fig,'units','normalized',...
                'position',[0.6 0.02 0.3 0.04],'style','pushbutton',...
                'string','Save Curve','fontsize',12,...
                'callback',@self.savePoints);            
            self.h_btLoad= uicontrol('parent',self.h_fig,'units','normalized',...
                'position',[0.3 0.02 0.3 0.04],'style','pushbutton',...
                'string','Load Curve','fontsize',12,...
                'callback',@self.loadPoints);
            
            % bpline settings
            uicontrol('parent',self.h_fig,'style','text',...
                'units','normalized','position',[0.1 0.08 0.15 0.05],...
                'string','BSpline Order','fontsize',12);
            self.h_pmOrder= uicontrol('parent',self.h_fig,'style','popupmenu',...
                'units','normalized','position',[0.1 0.05 0.15 0.05],...
                'string',{'1','2','3','4','5','6','7','8'},...
                'value',self.order,...
                'callback',@self.changeOrder);
            
           
            
            %% plot now
            self.plotnow();
            %% setup callback
            set(self.h_fig,'WindowButtonMotionFcn',@self.mouseMove);
            set(self.h_fig,'WindowButtonDownFcn',@self.mouseDown);
            
        end
        
        %% callback change bspline order
        function changeOrder(self,src,ev)
            order= get(self.h_pmOrder,'value');
            self.order= order;
            self.cs = bspline(self.xdata, self.ydata, self.order);
            self.plotnow();
        end
        
        %% callback editing points
        function pointEdit(self, src,ev)
            
            switch src.Label
                case 'add a point'
                    ipt= self.ind_hpt;
                    C= get(self.h_ax,'CurrentPoint');
                    xnow= C(1,1);
                    ynow= C(1,2);
                    
                    self.xdata=[self.xdata(1:ipt) xnow self.xdata(ipt+1:end)];
                    self.ydata=[self.ydata(1:ipt) ynow self.ydata(ipt+1:end)];
                    
                case 'delete point'
                    ipt= self.ind_hpt;
                    self.xdata(ipt)= [];
                    self.ydata(ipt)= [];
            end
            
            self.cs = bspline(self.xdata, self.ydata, self.order);
            self.plotnow();
        end
        
        %% callback load points
        function loadPoints(self,src,ev)
           % get filename
            [filename, pathname] = uigetfile('*.mat', 'mat file');
            if isequal(filename,0) || isequal(pathname,0)
                disp('User pressed cancel')
            else
                s= load(fullfile(pathname,filename),'data','ctrlPt');
            end
            
            self.xdata= s.ctrlPt(1,:);
            self.ydata= s.ctrlPt(2,:);
            self.cs = bspline(self.xdata,self.ydata, self.order);
            self.plotnow();
                        
        end        
        %% callback save Points
        function savePoints(self,src,ev)
            npt= str2num(get(self.h_edNPt,'string'));
            data= self.cs.ppval(npt);
            ctrlPt= [self.xdata; self.ydata];
            
            % get filename
            [filename, pathname] = uiputfile('*.mat', 'mat file');
            if isequal(filename,0) || isequal(pathname,0)
                disp('User pressed cancel')
            else
                save(fullfile(pathname,filename),'data','ctrlPt');
            end
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
            axis equal;
            xlabel('X'); ylabel('Y');
                        
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
                    % set context menu
                    set(self.h_plt_hpt,'uicontextmenu',self.h_cm(1));
                    break;
                end 
            end
        end
        function mouseDown(self,hobj,evt)
            if ishandle(self.h_plt_hpt)  % if picked
                stype= get(self.h_fig,'selectionType');
                if strcmp(stype,'normal') % left click
                   set(self.h_fig,'WindowButtonMotionFcn',@self.mouseDrag);
                   set(self.h_fig,'WindowButtonUpFcn',@self.mouseUp);
                end                    
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

