function editCSEMDataMasks(varargin)
%
% Function to create a binary mask for selecting good/bad sections of CSEM
% data or model responses.  Has to be called from createEMDataFile GUI.
%
% Kerry Key
% Scripps Institution of Oceanography
% University of California, San Diego
%
%


%     if nargin == 1
%         initializeMasks(varargin);
%     else
        f = str2func(varargin{1});
        [varargout{1:nargout}] = feval(f,varargin{2:nargin});
%    end
 
%--------------------------------------------------------------------------    
    function initializeMasks(CSEM,lCreateSyntheticData)

% Check for single Rx:
    if CSEM.nRx ~= 1
        str = sprintf('Only single receiver data supported for now, sorry! \n Try another data file.');
        errordlg(str, 'Error', 'modal');        
        return        
    end
        
    ifreq = 1;  
    
      % Set up the figure:
    SS = get(0,'Monitor');
    SS = SS(1,:); % in case 2nd display...
    dx = SS(3);
    dy = SS(4);
    
    hf = figure;
    dxf = dx*.7;
    dyf = dy*.7;
    
    set(hf,'units','pixels','position',[dx*.15 dy*.15  dxf dyf]);
    
    set(hf,'userdata',CSEM);
    
    makeMask(ifreq,lCreateSyntheticData)

%--------------------------------------------------------------------------    
    function  makeMask(ifreq,lCreateSyntheticData)
    
    % update the figure window with data for ifreq:
    
    % Get CSEM structure:
    CSEM = get(gcf,'userdata');
    
    if ifreq < 1  
        ifreq  = CSEM.nFreq;
    elseif  ifreq > CSEM.nFreq
        ifreq = 1;
    end
    
    % Clear the figure:
    clf;
    set(gcf,'name', sprintf('Frequency: %f Hz',CSEM.Freq(ifreq)))

    % Get x axis in/out tow ranges:
    
    xr = CSEM.xRx;
    yr = CSEM.yRx;    
    xt = CSEM.xTx;
    yt = CSEM.yTx;

    r = [sqrt( (xt-xr).^2 + (yt-yr).^2)/1d3]';
    rsign = sign(diff(r));
    x =  (r.*rsign([1 1:end]))';
    xlab = ' Horizontal Range (km), in-tow(-), out-tow(+)';                       
      
    
    % Get y axis data:
    if lCreateSyntheticData
        ex = squeeze((CSEM.ex_resp(1,:,ifreq)));
        ey = squeeze((CSEM.ey_resp(1,:,ifreq)));
        ez = squeeze((CSEM.ez_resp(1,:,ifreq)));  
        bx = squeeze((CSEM.bx_resp(1,:,ifreq)));
        by = squeeze((CSEM.by_resp(1,:,ifreq)));
        bz = squeeze((CSEM.bz_resp(1,:,ifreq)));   
    else
        ex = squeeze((CSEM.ex_data(1,:,ifreq)));
        ey = squeeze((CSEM.ey_data(1,:,ifreq)));
        ez = squeeze((CSEM.ez_data(1,:,ifreq)));  
        bx = squeeze((CSEM.bx_data(1,:,ifreq)));
        by = squeeze((CSEM.by_data(1,:,ifreq)));
        bz = squeeze((CSEM.bz_data(1,:,ifreq)));   
    end
    exsd =  CSEM.ex_sd(1,:,ifreq);
    eysd =  CSEM.ey_sd(1,:,ifreq);
    ezsd =  CSEM.ez_sd(1,:,ifreq);
    bxsd =  CSEM.bx_sd(1,:,ifreq);
    bysd =  CSEM.by_sd(1,:,ifreq);
    bzsd =  CSEM.bz_sd(1,:,ifreq);
    
    
    
    E = transpose([ex; ey; ez]);
    B = transpose([bx; by; bz]);
    Esd = transpose([exsd; eysd; ezsd]);
    Bsd = transpose([bxsd; bysd; bzsd]);
    
    maskE = squeeze(CSEM.Mask.E(1,:,ifreq));
    maskB = squeeze(CSEM.Mask.B(1,:,ifreq));
    
    % Get selected times:
    inE = isfinite(maskE);
    inB = isfinite(maskB);
    
    % Get deselected times:
    outE = ~isfinite(maskE);
    outB = ~isfinite(maskB); 
    
    % Plot them:
    
    col = get(gca,'colororder');
  
   
   for i = 1:length(col(:,1))
       colors{i} = col(i,:);
   end
   
    warning off;  % for legend entires that are empty...
     
    
    subplot(2,2,1);

    [yd ystdU ystdL ] = getLogErrorBar(E,Esd);
    
    h1 = myerrorbar(x(inE),yd(inE,1), ystdL(inE,1), ystdU(inE,1),'marker','.','color',colors{1}); 
    h = myerrorbar(x(outE),yd(outE,1), ystdL(outE,1), ystdU(outE,1),'marker','.','color',[.6 .6 .6]);     

    h2 = myerrorbar(x(inE),yd(inE,2), ystdL(inE,2), ystdU(inE,2),'marker','.','color',colors{2});      
    h = myerrorbar(x(outE),yd(outE,2), ystdL(outE,2), ystdU(outE,2),'marker','.','color',[.6 .6 .6]); 

    h3 = myerrorbar(x(inE),yd(inE,3), ystdL(inE,3), ystdU(inE,3),'marker','.','color',colors{3}); 
    h = myerrorbar(x(outE),yd(outE,3), ystdL(outE,3), ystdU(outE,3),'marker','.','color',[.6 .6 .6]);  
 
    hold on;
    set(gca,'fontsize',12);
    
    hl = [];
    legstr = {};
    if h1(1) > 0
        hl(end+1) = h1(1);
        legstr{end+1} = 'Ex';
    end
    if h2(1) > 0
        hl(end+1) = h2(1);
        legstr{end+1} = 'Ey';
    end
    if h3(1) > 0
        hl(end+1) = h3(1);
        legstr{end+1} = 'Ez';
    end
    
    
    legend(hl,legstr) 
    ylabel('V/m/Am')
    set(gca,'tag','E');
  
    subplot(2,2,2);
    
    [yd ystdU ystdL ] = getLogErrorBar(B,Bsd);

    h1 = myerrorbar(x(inB),yd(inB,1), ystdL(inB,1), ystdU(inB,1),'marker','.','color',colors{4});
    h  = myerrorbar(x(outB),yd(outB,1), ystdL(outB,1), ystdU(outB,1),'marker','.','color',[.6 .6 .6]); 
    
    h2 = myerrorbar(x(inB),yd(inB,2), ystdL(inB,2), ystdU(inB,2),'marker','.','color',colors{5});      
    h  = myerrorbar(x(outB),yd(outB,2), ystdL(outB,2), ystdU(outB,2),'marker','.','color',[.6 .6 .6]);  
    
    h3 = myerrorbar(x(inB),yd(inB,3), ystdL(inB,3), ystdU(inB,3),'marker','.','color',colors{6}); 
    h  = myerrorbar(x(outB),yd(outB,3), ystdL(outB,3), ystdU(outB,3),'marker','.','color',[.6 .6 .6]);     

    hl = [];
    legstr = {};
    if h1(1) > 0
        hl(end+1) = h1(1);
        legstr{end+1} = 'Bx';
    end
    if h2(1) > 0
        hl(end+1) = h2(1);
        legstr{end+1} = 'By';
    end
    if h3(1) > 0
        hl(end+1) = h3(1);
        legstr{end+1} = 'Bz';
    end 
        

    set(gca,'fontsize',12);
    legend(hl,legstr) 
    ylabel('T/Am')
    set(gca,'tag','B');
  
    subplot(2,2,3);
  
    yd = 180/pi*angle(E);
    ystd = (180/pi*Esd./abs(E) );

    h1 = myerrorbar(x(inE),yd(inE,1), ystd(inE,1), ystd(inE,1),'marker','.','color',colors{1}); 
    h = myerrorbar(x(outE),yd(outE,1), ystd(outE,1), ystd(outE,1),'marker','.','color',[.6 .6 .6]);   

    h2 = myerrorbar(x(inE),yd(inE,2), ystd(inE,2), ystd(inE,2),'marker','.','color',colors{2});     
    h = myerrorbar(x(outE),yd(outE,2), ystd(outE,2), ystd(outE,2),'marker','.','color',[.6 .6 .6]);  

    h3 = myerrorbar(x(inE),yd(inE,3), ystd(inE,3), ystd(inE,3),'marker','.','color',colors{3}); 
    h = myerrorbar(x(outE),yd(outE,3), ystd(outE,3), ystd(outE,3),'marker','.','color',[.6 .6 .6]);   

    hl = [];
    legstr = {};
    if h1(1) > 0
        hl(end+1) = h1(1);
        legstr{end+1} = 'Ex';
    end
    if h2(1) > 0
        hl(end+1) = h2(1);
        legstr{end+1} = 'Ey';
    end
    if h3(1) > 0
        hl(end+1) = h3(1);
        legstr{end+1} = 'Ez';
    end
    
        
    set(gca,'ydir','rev')
    set(gca,'fontsize',12);
    legend(hl,legstr) 
    xlabel(xlab);
    ylabel('Degrees')
    set(gca,'tag','E');
   set(gca,'ylim',[-180 180]);
  
    subplot(2,2,4);
    
    yd = 180/pi*angle(B);
    ystd = (180/pi*Bsd./abs(B) );

    h1 = myerrorbar(x(inB),yd(inB,1), ystd(inB,1), ystd(inB,1),'marker','.','color',colors{4}); 
    h = myerrorbar(x(outB),yd(outB,1), ystd(outB,1), ystd(outB,1),'marker','.','color',[.6 .6 .6]);   

    h2 = myerrorbar(x(inB),yd(inB,2), ystd(inB,2), ystd(inB,2),'marker','.','color',colors{5});     
    h = myerrorbar(x(outB),yd(outB,2), ystd(outB,2), ystd(outB,2),'marker','.','color',[.6 .6 .6]);  

    h3 = myerrorbar(x(inB),yd(inB,3), ystd(inB,3), ystd(inB,3),'marker','.','color',colors{6}); 
    h = myerrorbar(x(outB),yd(outB,3), ystd(outB,3), ystd(outB,3),'marker','.','color',[.6 .6 .6]);   

    hl = [];
    legstr = {};
    if h1(1) > 0
        hl(end+1) = h1(1);
        legstr{end+1} = 'Bx';
    end
    if h2(1) > 0
        hl(end+1) = h2(1);
        legstr{end+1} = 'By';
    end
    if h3(1) > 0
        hl(end+1) = h3(1);
        legstr{end+1} = 'Bz';
    end 
            
    set(gca,'ydir','rev')
    set(gca,'fontsize',12);
    legend(hl,legstr) 
    xlabel(xlab);   
    ylabel('Degrees')
    set(gca,'tag','B');
    set(gca,'ylim',[-180 180]);
    warning on;
    
    set(gcf,'units','normalized');
    
    % Now add the buttons:
    p1 = [.13  .95 .07 .03 ];
    p2 = [.23  .95 .07 .03 ];
    p3 = [.33  .95 .07 .03 ];
    p4 = [.43  .95 .07 .03 ];
    p5 = [.53  .95 .07 .03 ];
    p6 = [.63  .95 .07 .03 ];    
    p7 = [.73  .95 .07 .03 ];
    p8 = [.83  .95 .07 .03 ];  
    
    cbstr = sprintf('editCSEMDataMasks(''select'', %i,''add'',%i)',ifreq,lCreateSyntheticData);
    h1 = uicontrol('Style', 'pushbutton','units','normalized', 'String', 'Select +',...
    'Position',p3 , 'Callback',cbstr); 
    
    cbstr = sprintf('editCSEMDataMasks(''select'', %i,''remove'',%i)',ifreq,lCreateSyntheticData);
    h = uicontrol('Style', 'pushbutton','units','normalized', 'String', 'Deselect -',...
    'Position', p4, 'Callback', cbstr);   

    cbstr = sprintf('editCSEMDataMasks(''allSelect'', %i,''add'',%i)',ifreq,lCreateSyntheticData);
    h = uicontrol('Style', 'pushbutton','units','normalized', 'String', 'Select All',...
    'Position', p1, 'Callback', cbstr);   

    cbstr = sprintf('editCSEMDataMasks(''allSelect'', %i,''remove'',%i)',ifreq,lCreateSyntheticData);
    h = uicontrol('Style', 'pushbutton','units','normalized', 'String', 'Deselect All',...
   'Position', p2, 'Callback', cbstr);     
    
    cbstr = sprintf('editCSEMDataMasks(''makeMask'', %i,%i)',ifreq+1,lCreateSyntheticData);
    h = uicontrol('Style', 'pushbutton','units','normalized', 'String', 'Next Freq.--->',...
    'Position', p6, 'Callback', cbstr);  

    cbstr = sprintf('editCSEMDataMasks(''makeMask'', %i,%i)',ifreq-1,lCreateSyntheticData);
    h = uicontrol('Style', 'pushbutton','units','normalized', 'String', '<---Previous Freq.',...
    'Position', p5, 'Callback', cbstr);  

     cbstr = sprintf('editCSEMDataMasks(''saveMask'',''dummy'')');
     h = uicontrol('Style', 'pushbutton','units','normalized', 'String', 'Quit and Save',...
    'Position', p7, 'Callback', cbstr);  
    

%--------------------------------------------------------------------------    
    function  allSelect(ifreq,mode,lCreateSyntheticData)
        
    % Get CSEM structure:
    CSEM = get(gcf,'userdata');
    
    k = waitforbuttonpress;
    tag = get(gca,'tag');
    
    switch tag
        case 'E'
            switch mode
                case 'add'                
                    CSEM.Mask.E(1,:,ifreq) = 1;
                case 'remove'
                    CSEM.Mask.E(1,:,ifreq) = nan;
            end
        case 'B'
            switch mode
                case 'add'
                    CSEM.Mask.B(1,:,ifreq) = 1;
                case 'remove'
                    CSEM.Mask.B(1,:,ifreq) = nan;
            end
    end
    
   set(gcf,'userdata',CSEM);
   
   % Replot:
    makeMask(ifreq,lCreateSyntheticData)
%--------------------------------------------------------------------------    
    function  select(ifreq,mode,lCreateSyntheticData)
        

    k = waitforbuttonpress;
    point1 = get(gca,'CurrentPoint');    % button down detected
    p1 = point1(1,1:2); 
    
    % draw a vertical line there:
    alims = axis;
    hline1 = line([p1(1) p1(1)],alims(3:4));
    set(hline1,'color','r')
    
   % finalRect = rbbox;                   % return figure units
    k = waitforbuttonpress;
    point2 = get(gca,'CurrentPoint');    % button up detected
                % extract x and y
    p2 = point2(1,1:2);
    
    hline2 = line([p2(1) p2(1)],alims(3:4));
    set(hline2,'color','r')
    drawnow;
    
    xmin = min([p1(1) p2(1)]);
    xmax = max([p1(1) p2(1)]);
    
    
    % What do we do now, we need to know which data is good and which is
    % bad...
 
    % Get CSEM structure:
    CSEM = get(gcf,'userdata');
   
    % Get ranges:
        
    xr = CSEM.xRx;
    yr = CSEM.yRx;    
    xt = CSEM.xTx;
    yt = CSEM.yTx;

    r = [sqrt( (xt-xr).^2 + (yt-yr).^2)/1d3]';
    rsign = sign(diff(r));
    x =  r.*rsign([ 1 1:end]);
    
    iadd = x >= xmin & x <=xmax;
    
    % Update the masks for either E or B;
    
    tag = get(gca,'tag');
    
    switch tag
        case 'E'
            switch mode
                case 'add'                
                    CSEM.Mask.E(1,iadd,ifreq) = 1;
                case 'remove'
                    CSEM.Mask.E(1,iadd,ifreq) = nan;
            end
        case 'B'
            switch mode
                case 'add'
                    CSEM.Mask.B(1,iadd,ifreq) = 1;
                case 'remove'
                    CSEM.Mask.B(1,iadd,ifreq) = nan;
            end
    end
    
   % Update userdata:
   set(gcf,'userdata',CSEM);
   delete(hline1);
   delete(hline2);
   
   % Replot:
    makeMask(ifreq,lCreateSyntheticData)
    
%  

%--------------------------------------------------------------------------    
    function  saveMask(varargin)   
% saves the maskes to <filename>.masks        

   % Get CSEM structure:
    CSEM = get(gcf,'userdata');
    
    close(gcf);
    

    Mask = CSEM.Mask;
    
    [p n e v] = fileparts(CSEM.filename);
     
    maskFile = fullfile(p,strcat(n,'.masks'));
    
    save(maskFile,'Mask')
    
    return
    