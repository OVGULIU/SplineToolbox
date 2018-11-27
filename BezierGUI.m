classdef BezierGUI < handle
    % GUI to test bezier function
    properties
        xdata
        ydata
        cs
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
        dragMode;
        timerS
        
    end
    
    methods
        function self= BezierGUI(x,y)
            self.xdata= x;
            self.ydata= y;
            self.cs = bezier(x, y);
            
            %% setup GUI
            self.setupUI();
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
            
                       
           
            
            %% plot now
            self.plotnow();
            %% setup callback
            set(self.h_fig,'WindowButtonMotionFcn',@self.mouseMove);
            set(self.h_fig,'WindowButtonDownFcn',@self.mouseDown);
            set(self.h_fig,'WindowButtonUpFcn',@self.mouseUp);            
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
            
            self.cs = bezier(self.xdata, self.ydata);
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
            self.cs = bezier(self.xdata,self.ydata);
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
            if self.dragMode
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
            else
                % delete highlighted line first
                %if ishandle(self.h_plt_hpt), delete(self.h_plt_hpt); end
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
                        if ishandle(self.h_plt_hpt)
                            % updata highlighted point plot
                            set(self.h_plt_hpt,'xdata',xnow);
                            set(self.h_plt_hpt,'ydata',ynow);
                        else
                            self.h_plt_hpt= plot(self.h_ax,xnow,ynow,'ro',...
                                'markersize',12);
                        end
                        self.ind_hpt= i;
                        % set context menu
                        set(self.h_plt_hpt,'uicontextmenu',self.h_cm(1));
                        break;
                    end 
                end
            end
        end
        function mouseDown(self,hobj,evt)
            if ishandle(self.h_plt_hpt)  % if picked
                self.dragMode= true;                             
            end            
        end
        
        function mouseUp(self,hobj,evt)
            if self.dragMode
                % reset bezier model
                self.cs = bezier(self.xdata, self.ydata);
                % plot now
                self.plotnow();
                self.dragMode= false;
            end            
        end
            
    end
    
end

