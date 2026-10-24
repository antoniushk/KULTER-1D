%--------------------------------------------------------------------------
%    function plotRxTxMap()
%
% Helper function to plot maps/depth sections of the transmitters and 
% receivers stored in structure CSEM in the plotCSEM figure menu.
%
% *** Only can be called from the plotCSEM.m figure menu ***
% 
% Kerry Key
% Scripps Institution of Oceanography
% University of California, San Diego
% 
    function varargout = plotRxTxMap()


% First we get the data from the menu figure:
    hmenufig = findobj('tag','csemmenufig');  
    CSEM = get(hmenufig,'userdata');

    if isempty(CSEM)
        return
    end

      
    hfig = figure;
    
    cc ={'b' 'r' 'g' 'k' 'm' 'c' 'y'};
    
  % Line Azimuth:
  xx = CSEM(1).xTx';
  yy = CSEM(1).yTx';
  
  

  
  lineAzimuth = 180/pi*atan2(yy(end)-yy(1), xx(end)-xx(1));
  
  % Plot the Receivers and Transmitters:
    
    for i=1:length(CSEM)
        y = CSEM(i).yRx/1d3;
        x = CSEM(i).xRx/1d3;
        z = CSEM(i).zRx/1d3;

        xt = CSEM(i).xTx/1d3; 
        yt = CSEM(i).yTx/1d3;
        zt = CSEM(i).zTx/1d3;
        dr = (sqrt ( diff(xt).^2 + diff(yt).^2 + diff(zt).^2));

        len = [dr(1) dr]*.6; % kuldge length for plotting antenna azimuth:

        x0 = xt + len./2.*cosd(CSEM(i).AzimuthTx).*cosd(CSEM(i).DipTx);
        x1 = xt - len./2.*cosd(CSEM(i).AzimuthTx).*cosd(CSEM(i).DipTx);
        y0 = yt + len./2.*sind(CSEM(i).AzimuthTx).*cosd(CSEM(i).DipTx);
        y1 = yt - len./2.*sind(CSEM(i).AzimuthTx).*cosd(CSEM(i).DipTx);  
        z0 = zt + len./2.*sind(CSEM(i).DipTx);
        z1 = zt - len./2.*sind(CSEM(i).DipTx);        


        
        fprintf('Line Azimuth: %f\n',lineAzimuth)
        subplot(2,2,4);
        plot3(y,x,z, 'linestyle','none', ...
            'marker','d','markerfacecolor','w','markeredgecolor',cc{i},...
            'markersize',8);
        hold on;

        plot3([y0; y1],[x0; x1],[z0; z1],'linestyle','-','color',cc{i});
        
        
        subplot(2,2,2);
        hRx(i) = plot(x,z, 'linestyle','none', ...
            'marker','d','markerfacecolor','w','markeredgecolor',cc{i},...
            'markersize',8);
        hold on;
        set(gca,'ydir','rev');
        hh =plot([x0; x1],[z0; z1],'linestyle','-','color',cc{i});
        hTx(i) = hh(1);
        
        subplot(2,2,3);
        plot(y,z, 'linestyle','none', ...
            'marker','d','markerfacecolor','w','markeredgecolor',cc{i},...
            'markersize',8);
        set(gca,'ydir','rev');
        hold on;
        plot([y0; y1],[z0; z1],'linestyle','-','color',cc{i});
        
        subplot(2,2,1)
        plot(y,x, 'linestyle','none', ...
            'marker','d','markerfacecolor','w','markeredgecolor',cc{i},...
            'markersize',8);      
        hold on;
        plot([y0; y1],[x0; x1],'linestyle','-','color',cc{i});    
        
    end
     
   
    % move to right handed system with z positive down:
   % axis ij;
  
   
    subplot(2,2,4);
    set(gca,'fontsize',14) 
    xlabel('y (km)');
    ylabel('x (km)');
    zlabel('z (km)');
    set(gca,'zdir','reverse');
    grid on;
    box on;
    axis equal
    
    subplot(2,2,2);
    set(gca,'fontsize',14) 
    xlabel('x (km)');
    ylabel('z (km)');
    grid on;
    box on;
    axis equal 
     
    subplot(2,2,3);
    set(gca,'fontsize',14) 
    xlabel('y (km)');
    ylabel('z (km)');
    set(gca,'zdir','reverse');
    grid on;
    box on;
    axis equal
       
    subplot(2,2,1);
    set(gca,'fontsize',14) 
    xlabel('y (km)');
    ylabel('x (km)');
    grid on;
    box on;
    axis equal
       
    
 
   

   % axis vis3d
    %axis equal
    % Add a legend:
    hh = [];
    legstr ={};
    for i = 1:length(CSEM)
       hh = [hh; hRx(i); hTx(i)];
       [p n e] = fileparts(CSEM(i).filename);
       legstr{end+1} = sprintf('%s: Rx''s',n);
       legstr{end+1} = sprintf('%s: Tx''s',n);
    end
    legend(hh,legstr,'interpreter','none');

   
  


     