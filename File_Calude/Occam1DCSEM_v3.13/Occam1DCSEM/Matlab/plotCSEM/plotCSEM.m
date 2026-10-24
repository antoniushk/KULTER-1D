%---------------------------------------------------------    
% function plotCSEM(varargin)
%
% A Matlab utility for easy plotting of CSEM data stored in the 
% .csem format used by MARE2DCSEM and Dipole1D modeling codes, and
% the EMData_1.0 and EMResp_1.0 formats used by Occam1DCSEM (2008). 
%
% Currently the anomaly plots are only setup for model responses from MARE2D
% and Dipole1D, not for real survey data. 
%
% Usage:
%
% >> plotCSEM      - creates an interactive menu for selecting data and
%                    plotting options. The rest should be obvious.
%
%
% Copyright 2007-2009
% Kerry Key
% Scripps Institution of Oceanography
% University of California, San Diego
% kkey@ucsd.edu
%
%
% A product of the Seafloor Electromagnetic Methods Consortium
% http://marineemlab.ucsd.edu/semc.html
%
% License:
%
% 	 This file is part of plotCSEM.
%
%    plotCSEM is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    plotCSEM is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with plotCSEM.  If not, see <http://www.gnu.org/licenses/>.
%
%
% Versions:
%
% Version 3.0 December 2008.     Finally added in support for survey data
%                                and error bars. Cleaned up some of the code,
%                                buts its still sloppy in many places.
% Version 2.2 November, 2007.    Starting to add support for processed data
%                                files, but this is still a work in
%                                progress.
% Version 2.1, October 19, 2007. Added support for Dipole1D_1.0 format data file.  
% Version 2.0, October 2007.     Added interactive menu selection tool.
% Version 1.0, September 2007.
%
%
% To Do List:
% 
% 1. Allow for real data anomaly plots
% 2. Frequency section plots (range vs frequency with amplitude colormap).
% 3. Polarization ellipse parameters
% 4. Button for plotting X-Y Map section of fields with polarization ellipses.
% 5. Rx rotation support.
%
%
% To add support for your own data format:
%
% See function "CSEM =  readCSEM(file)" below 
% for the CSEM data structure required by plotCSEM.
%
%---------------------------------------------------------


    function varargout = plotCSEM(varargin)
    if nargin==0  
        feval(@openCSEMmenufig);
    elseif nargin>=1 
        f = str2func(varargin{1});
        [varargout{1:nargout}] = feval(f,varargin{2:nargin});
    end


%---------------------------------------------------------    
    function openCSEMmenufig
%---------------------------------------------------------      
     % First delete any previous instances of the CSEMmenu figure if they
    % exist:
    %delete(findobj('tag','csemmenufig'));
    
    % Open a new menu figure:
    openfig('plotCSEMmenu.fig','reuse')   
    
%---------------------------------------------------------      
    function createEMDataFile_callback(varargin)   
%--------------------------------------------------------- 
    hmenufig = findobj('tag','csemmenufig');
    CSEM =  get(hmenufig,'userdata');
    
    % Launch the GUI:
    createEMDataFile;
    
    % Then upload the CSEM structure:
    if isempty(CSEM)
        sFile = [];
        createEMDataFile('readAndLoadFile',gcf,sFile);
    else
        createEMDataFile('updateGUIfields',CSEM)  
    end

    
%---------------------------------------------------------    
    function addFiles(varargin)
%--------------------------------------------------------- 
% Adds file(s) to the CSEM menu listing

    hmenufig = findobj('tag','csemmenufig');
    CSEM =  get(hmenufig,'userdata');
  
  % Get the list of any existing files:  
    hfilelist = findobj('tag','csemmenufiles');
    
  % Select some new files for plotting:
    [filename, pathname] = uigetfile({'*.csem;*.mat;*.data;*.resp;*.emdata;*.txt'}, 'Select .csem,.data or .resp file(s)','multiselect','on');
  
    if isnumeric(filename) && filename ==0
        return
    end

    if iscell(filename)
        lf = length(filename);
    else
        lf = 1;
    end
    
  
    for i = 1:lf
        if ~iscell(filename)==1;
            fname = fullfile(pathname,filename);
        else 
            fname = fullfile(pathname,filename{i});
        end    
        % Read in the new file:
         temp =  readCSEM(fname); 
         if isempty(CSEM)
            CSEM = temp;
         else
            CSEM(end+1) = temp; 
         end
    end


    
  % Parse the data files for Frequencies to plot:
    for i = 1:length(CSEM)
        [ p n e] = fileparts(CSEM(i).filename);
         shortcurfiles{i} = strcat(n,e);
         % Check for Occam model responses:
         if strcmpi(e,'.resp')
              set(findobj(hmenufig,'tag','hplotresidual'),'value',1);
         end
        % Check for Frequency compatibility between files
        if i>1
            if any(CSEM(i).Freq~=CSEM(i-1).Freq)
               beep
               warndlg('Error: Frequencies in CSEM files do not match, Try again!','plotCSEM Error');
               return
            end
        end
     end

  % Add the new list of files to the menu figure:  
    set(hfilelist,'string',shortcurfiles,'value',1);     
     
  % Store CSEM structure in figure userdata field:   
    set(hmenufig,'userdata',CSEM);
    
  % Update the Frequency List:
    sFreqs = num2str(CSEM(1).Freq);
    hfreqlist = findobj('tag','hfreqlist');
    val = get(hfreqlist,'value');
    if val>length(CSEM(1).Freq)
        val =1;
    end
    set(hfreqlist,'string',sFreqs,'value',val);
    
 % Update the list of Tx's to plot:
    set(findobj('tag','hselectTx'),'userdata',1:CSEM(1).nTx); % default is to plot all of them

 % Update the list of Rx's to plot:
    set(findobj('tag','hselectRx'),'userdata',1:CSEM(1).nRx); % default is to plot all of them    
    
  % Update the Plot Type based on Rx and Tx in first CSEM file:
    if CSEM(1).nTx >= CSEM(1).nRx  % Receiver gather is the default if more than Tx's than Rx's
        set(findobj('tag','hplottype'),'value',2)
    else 
        set(findobj('tag','hplottype'),'value',1)
    end   
    
  % Update the plot components based on the receiver locations and transmitter AzimuthTx and DipTx  

    % Make an educated guess at the type of survey line.    
    linetype = getsitearraytype(CSEM(1));
    
   % Horizontal transmitter pointing mostly along y:
%     if all(abs(cosd(CSEM(1).AzimuthTx)) <= .7071) && all(abs(cosd(CSEM(1).DipTx)) >= .7071);
%         if strcmp(linetype,'yline')  % mostly inline Tx for line of y sites
%             defcomps = {'Ey'};
%         else  % Sites are along x or z?
%             defcomps = {'Ey'}; % broadside
%         end
%   %  elseif all(abs(CSEM(1).AzimuthTx)>45) && all(abs(CSEM(1).DipTx)<45);  
%    % Horizontal transmitter pointing mostly along x:     
%     elseif all(abs(cosd(CSEM(1).AzimuthTx)) > .7071) && all(abs(cosd(CSEM(1).DipTx)) >= .7071);    
%          if strcmp(linetype,'xline')  
%             defcomps = {'Ex'};
%         else 
%             defcomps = {'Ex'}; % broadside sites along y
%          end
%     else
%         defcomps = {'Ex' 'Ey', 'Ez', 'Bx' 'By' 'Bz'};
% %    end
%     
%     for i=1:length(defcomps)
%         switch defcomps{i}
%             case 'Ex'
%                 set(findobj('tag','hex'),'value',1)
%             case 'Ey'
%                 set(findobj('tag','hey'),'value',1)
%             case 'Ez'
%                 set(findobj('tag','hez'),'value',1)
%             case 'Bx'
%                 set(findobj('tag','hbx'),'value',1)
%             case 'By'
%                 set(findobj('tag','hby'),'value',1)
%             case 'Bz'
%                 set(findobj('tag','hbz'),'value',1)  
%         end
%     end
  
 
     str = get(findobj(gcf,'tag','hxaxis'),'str');
    
     if strcmp(linetype,'zline')
          val = strmatch( 'z',str);
         set(findobj('tag','hxaxis'),'value',val);
     else % just default to in/out tow range.
         val = strmatch( 'Horizontal Range (in-tow/out-tow)',str);
         set(findobj('tag','hxaxis'),'value',val); % 5 is horizontal range
     end

  

  
  
%---------------------------------------------------------    
    function removeFiles(varargin)
%--------------------------------------------------------- 
% Removes file(s) from the CSEM menu listing
  
  % Get CSEM structure in figure userdata field:
    hmenufig = findobj('tag','csemmenufig');  
    CSEM =  get(hmenufig,'userdata');
    
  % Get the list of any existing files:  
    hfilelist = findobj('tag','csemmenufiles');
    curfiles = get(hfilelist,'string');
    
    iremove = get(hfilelist,'value');
    
    if iremove == 0
        return
    end
    
  % Remove the empty values:
    iuse = 1:length(curfiles);
    curfiles = curfiles(iuse~=iremove);
    CSEM = CSEM(iuse~=iremove);
    
  % Add the new list of files to the menu figure:  
    set(hfilelist,'string',curfiles,'value',1);

  % Store CSEM structure in figure userdata field:   
    set(hmenufig,'userdata',CSEM);    
    
%---------------------------------------------------------    
    function moveFiles(varargin)
%--------------------------------------------------------- 
% Moves files up in the listing order
  
  % Get CSEM structure in figure userdata field:
    hmenufig = findobj('tag','csemmenufig');  
    CSEM =  get(hmenufig,'userdata');
    
  % Get the list of any existing files:  
    hfilelist = findobj('tag','csemmenufiles');
    curfiles = get(hfilelist,'string');
    
    iup = get(hfilelist,'value');
    
    if iup == 0 || iup == 1
        return
    end
    
  % Move the order values:
    iuse = 1:length(curfiles);
    
    iuse(iup-1:iup) = [iuse(iup) iuse(iup-1)];
   
    curfiles = curfiles(iuse);
    CSEM = CSEM(iuse);
  
  % Add the new list of files to the menu figure:  
    set(hfilelist,'string',curfiles,'value',iup-1);   
    
  % Store CSEM structure in figure userdata field:   
    set(hmenufig,'userdata',CSEM);    
    
    
%---------------------------------------------------------    
    function selectRx(varargin)
%---------------------------------------------------------  
  % Get CSEM structure in figure userdata field:
    hmenufig = findobj('tag','csemmenufig');  
    CSEM =  get(hmenufig,'userdata');
    if isempty(CSEM)
        return
    end
    
    index = get(findobj(gcf,'tag','hselectRx'),'userdata');
% Ask which Rx to plot:
    for i = 1:CSEM(1).nRx
            s{i} = sprintf('# %i, %6.1f %6.1f %6.1f',i,CSEM(1).xRx(i)/1d3,CSEM(1).yRx(i)/1d3,CSEM(1).zRx(i)/1d3);  %#ok<AGROW>
    end
   
     [answer] = listdlg('PromptString','Select Rx''s (#,x,y,z):',...
                      'SelectionMode','multi',...
                      'ListString',s,'InitialValue',index,'fus',12,'ffs',12,'uh',32);
    if isempty(answer)
        return
    end
    index = answer(:);
    set(findobj('tag','hselectRx'),'userdata',index);
   
%---------------------------------------------------------    
    function selectTx(varargin)
%---------------------------------------------------------  
  % Get CSEM structure in figure userdata field:
    hmenufig = findobj('tag','csemmenufig');  
    CSEM =  get(hmenufig,'userdata');
    if isempty(CSEM)
        return
    end
    
    index = get(findobj(gcf,'tag','hselectTx'),'userdata');
% Ask which Tx to plot:
    for i = 1:CSEM(1).nTx
            s{i} = sprintf('# %i, %6.1f %6.1f %6.1f %5.1f %5.1f',i,CSEM(1).xTx(i)/1d3,CSEM(1).yTx(i)/1d3,CSEM(1).zTx(i)/1d3,CSEM(1).AzimuthTx(i),CSEM(1).DipTx(i));  %#ok<AGROW>
    end
   
     [answer] = listdlg('PromptString','Select Tx''s (#,x,y,z,AzimuthTx,DipTx):',...
                      'SelectionMode','multi',...
                      'ListString',s,'InitialValue',index,'fus',12,'ffs',12,'uh',32);
    if isempty(answer)
        return
    end
    index = answer(:);
    set(findobj('tag','hselectTx'),'userdata',index);
       
    
%---------------------------------------------------------    
    function doplotCSEM(varargin)
% Plot the CSEM responses at sites
%---------------------------------------------------------  
    
  % First we get the data from the menu figure:
    hmenufig = findobj('tag','csemmenufig');  
    CSEM = get(hmenufig,'userdata');
    
    if isempty(CSEM)
        return
    end
    
  % Next we parse all the menu check boxes, mostly we just store the index
  % values to the menu lists, so we will need to remember later what the listed
  % command orders are.
    
  % Frequency
    if isnumeric(varargin{1})
        
        plotFreq = varargin{1};
        if plotFreq > CSEM(1).nFreq
            plotFreq = 1;
        elseif plotFreq < 1
            plotFreq = CSEM(1).nFreq;
        end
        h_oldfig = gcf;
        clf;
    else
        plotFreq = get(findobj(hmenufig,'tag','hfreqlist'),'value');
       h_oldfig = [];
    end
    
    %figure(findobj('tag','csemmenufig'));
    
  % Plottype:
    plottype = get(findobj(hmenufig,'tag','hplottype'),'value'); % 1,2,3: Tx Gather, Rx Gather, Pseudosection   

  % Plotphase:
    plotphase = get(findobj(hmenufig,'tag','hplotphase'),'value'); % 0 or 1, off or on

  % Unwrap phase:
    unwrapphase = get(findobj(hmenufig,'tag','hphaseunwrap'),'value'); % 0 or 1, off or on

  % Plot Model Fit Residual:
    plotresidual = get(findobj(hmenufig,'tag','hplotresidual'),'value'); % 0 or 1, off or on
  
  % Color lines and symbols using:
    colorby = get(findobj(hmenufig,'tag','hcolorby'),'value'); % 0 or 1, off or on
    
  % X-scale:
    xscale = get(findobj(hmenufig,'tag','hxaxis'),'value'); %1,2,3,4,5,6: x,y,z,r,rh,rv

  % Y-scale
    yscale = get(findobj(hmenufig,'tag','hyaxis'),'value'); % 1,2,3,4,5...: AmpPhase,Ratio,RelDiff,
    
 % Get selected components, plus primary fields if anomaly plot requested
 % (with yscale variable)
    plotcomp = getCompsToPlot(yscale);
    if isempty(plotcomp)
         beep;
         errordlg('Error: no components selected, try again.', 'Error');
        return
    end
   
  % Rx to plot:
    Rxind = get(findobj(hmenufig,'tag','hselectRx'),'userdata'); % 1:CSEM(1).nRx;
    
  % Tx to plot:
    Txind = get(findobj(hmenufig,'tag','hselectTx'),'userdata'); %1:CSEM(1).nTx;
 
  % Run a few error checks at this point to make sure everything is hunky
  % dory:  
    if plottype > 1 && length(Txind) ==1
       beep
       warndlg('Error: more than 1 transmitter needed for Rx Gather and Pseudosection plots. Try again!','plotCSEM Error');
       return
    end
    if plottype == 1 && length(Rxind) ==1
       beep
       warndlg('Error: more than 1 receiver site needed for Tx Gather plots. Try again!','plotCSEM Error');
       return
    end      
   
    
    % Make call to Pseudosection Plot function:
    if plottype == 3  % Pseudosection
        makePseudosectionPlot(CSEM,xscale,yscale,plotFreq,Txind,Rxind,plotcomp,plotphase);
        return
    end
    
    
   % Now we assemble the arrays for plotting the responses:
   % 
   % Plot data is pushed into structure y: y.xdata, y.ydata for each 
   % component to be plotted
   
   % Get the y-axis data for the selected components: 
    y = getYAxisData(CSEM,Rxind,Txind,plotFreq,plotcomp,colorby);
    
   % Now get the x-axis data, depending on what's requested:
    [y xlab unwrapdim] = getXAxisData(y,CSEM,Rxind,Txind,plotcomp,plottype,xscale);
    
   % Remove nan's if data is vector, not matrix
    for i = 1:length(y)
        if any(size(y(i).ydata) ==1)
            ii = isfinite(y(i).ydata) | isfinite(y(i).yresp);
            y(i).ydata = y(i).ydata(ii);
            y(i).yresp = y(i).yresp(ii);
             y(i).sd = y(i).sd(ii);
            y(i).xdata = y(i).xdata(ii);
        end
    end
   
   
 % Next we make  a big figure for plotting the responses:
    if isempty(h_oldfig)
        screensize = get(0,'screensize');
        figsize = min([1200 800],.9*screensize(3:4));  
        figure('units','pixels','position',[100 100 figsize],'ToolBar','figure'); 
    else
        figure(h_oldfig)
    end
    
    
  % A few magic numbers:  
    figfontsize = 14;
    legendfontsize = 12;

    if (plotresidual==1)  %&& any(any(y(1).ydata)) && any(any(y(1).yresp))
        plotresidual  = 1; % stay the same...
        
        if (plotphase==1 & yscale ~=3)  || yscale == 2 % real/imag
            nAxesRows = 2; % Amplitude and phase and their residuals
            nAxesCols = 2;
        else
            nAxesRows = 2; % Amplitude and its residuals
            nAxesCols = 1;
        end
       
    else % false attempt since there's no data to plot...
        plotresidual = 0;
        if plotphase==1   || yscale == 2 % include phase or real/imag
            nAxesRows = 2; % only Amplitude and phase
            nAxesCols = 1;
        else
            nAxesRows = 1;  % only Amplitude plotted...
            nAxesCols = 1;
        end
     end
   
 % Finally, make the plots depending on requested type
 
    h1 = [];
    h2 = [];
    legstr = {};
 
    
    
    switch yscale
    
    case 1 % Amplitude and Phase:

         for i =1:length(y)  % Loop over all channels and plot the amplitude and phase:
            
             
         % Amplitude:    
            subplot(nAxesRows,nAxesCols,1)   
            set(gca,'fontsize',figfontsize) 
            xd = y(i).xdata;
            
  
           % Plot Survey Data:
            if any(any ( y(i).ydata ))                 
                yd = log10(abs(y(i).ydata)); 
                ystdU = log10( abs(y(i).ydata) + y(i).sd ) - log10( abs(y(i).ydata));
                ystdL = log10( abs(y(i).ydata)) - log10( abs(y(i).ydata) - y(i).sd );
                %ystdL(abs(imag(ystdL))>0) = log10( abs(y(i).ydata(abs(imag(ystdL))>0))) + 20;
                xder = xd;
                if any( size(xder ) ~= size(yd))
                    xder = repmat(xd,size(yd,1),1);         
                end               
                h = myerrorbar(xder,yd, ystdL, ystdU,'marker','.','color',y(i).linecolor);
                hold on;
                if h > 0 
                    legstr{end+1} = sprintf('%s %s',y(i).legstr,'data');  
                    h1(end+1) = h(1);  
                end
            end
             
            % Plot Model Response:
            if any( any( y(i).yresp))
                yd = log10(abs(y(i).yresp));
                %ii = isfinite(yd);
                %h = plot(xd(ii),yd(ii),'linestyle',y(i).linestyle,'color',y(i).linecolor);
                h = plot(xd,yd,'linestyle',y(i).linestyle,'color',y(i).linecolor);
                hold on;
                if h > 0 
                    legstr{end+1} = sprintf('%s %s',y(i).legstr,'response');  
                    h1(end+1) = h(1);
                end
            end           

      
            
            % Plot Residual 
            if plotresidual == 1
                subplot(nAxesRows,nAxesCols,1+nAxesCols) 
                set(gca,'fontsize',figfontsize) 
                xd = y(i).xdata;
                resid = ( abs(y(i).ydata) - abs(y(i).yresp) ) ./ y(i).sd;
                plot(xd,resid,'linestyle','none','marker','.','color',y(i).linecolor);
                hold on;
            end
            
         % Phase:
            if plotphase == 1 
                
                subplot(nAxesRows,nAxesCols,2) 
                set(gca,'fontsize',figfontsize) 
               
                % Plot Survey Data:
                if any(any(y(i).ydata))
                    phs = getPhase(y(i).ydata,unwrapphase,unwrapdim);             
                    ystd = 180/pi*y(i).sd ./y(i).ydata;  
                    h = myerrorbar(xder,phs, ystd,ystd,'marker','.','color',y(i).linecolor);
                    hold on;
                    h2(end+1) = h(1);
                end              
                % Plot Model Response:
                if any(any(y(i).yresp))
                    phs = getPhase(y(i).yresp,unwrapphase,unwrapdim);
                   % ii = isfinite(yd); % kludge for when nan's in responses make the response line have gaps       
                   % h = plot(xd(ii)',phs(ii)','linestyle',y(i).linestyle,'color',y(i).linecolor) ;  
                    h = plot(xd,phs,'linestyle',y(i).linestyle,'color',y(i).linecolor) ;
                    hold on;
                    h2(end+1) = h(1);
                    hold on;
                end
                
                

                
                % Plot Residual 
                if plotresidual == 1
                    subplot(nAxesRows,nAxesCols,2+nAxesCols) 
                    set(gca,'fontsize',figfontsize) 
                    xd = y(i).xdata;
                    
                    phsd = getPhase(y(i).ydata,unwrapphase,unwrapdim);    
                    phsr = getPhase(y(i).yresp,unwrapphase,unwrapdim);
                    ystd = abs(180/pi*y(i).sd ./y(i).ydata); 
                    resid = ( phsd  - phsr );
                    
                    phsplus = abs( ( phsd  - phsr ) + 360);
                    phsminus = abs( ( phsd  - phsr ) - 360);
                    
                    t = [resid phsplus phsminus]';
                    [junk row] = min(abs(t));
                    for ii = 1:length(junk)
                        resid(ii) = t(row(ii),ii)';
                    end
          
                    resid = resid./ ystd;
                    plot(xd,resid,'linestyle','none','marker','.','color',y(i).linecolor);
                    hold on;
                end
                            

            end
            
        end % loop over all channels in y
        
       % Add Labels:
        
        subplot(nAxesRows,nAxesCols,1) 

        box on;
        xlabel(xlab)
        ylabel('Amplitude, log10 V/m/Am, T/Am') 
        h = legend( h1,legstr,'interpreter','none');
        hc = get(h,'children');
        set(hc,'tag','legend');
        title(sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq)));
        axis tight
        
        if plotresidual == 1
            subplot(nAxesRows,nAxesCols,1+nAxesCols) 
            xlabel(xlab)
            ylabel('Normalized Residual') 
            % Center the yscale so that biased residual more apparent:
            axis tight
            ax = axis;
            my = max(abs(ax(3:4)));
            axis([ax(1:2) -my my]);
            box on;
             
        end
        
        if plotphase==1          
            subplot(nAxesRows,nAxesCols,2) 
            xlabel(xlab)
            axis ij
            ylabel('Phase Lag, Degrees') 
            % legend in phase axes is redundant...
            %legend(h2, legstr,'interpreter','none','location','southwest');
            box on;
            axis tight
            if ~unwrapphase
                set(gca,'ylim',[-180 180]);
            end
            if plotresidual == 1
                subplot(nAxesRows,nAxesCols,2+nAxesCols) 
                xlabel(xlab)
                ylabel('Normalized Residual') 
                % Center the yscale so that biased residual more apparent:
                axis tight
                ax = axis;
                 box on;
                my = max(abs(ax(3:4)));
                axis([ax(1:2) -my my]);
            end
        end
   
        
        case 2 % Real / imaginary

         for i =1:length(y)  % Loop over all channels and plot the amplitude and phase:

                
          % Real:
             subplot(nAxesRows,nAxesCols,1)            
            set(gca,'fontsize',figfontsize)           
            xd = y(i).xdata;
           
            % Plot Survey Data:
             if any(any( y(i).ydata ) )                
                yd = log10(abs(real(y(i).ydata))); 
                ystdU = log10( abs(real(y(i).ydata)) + y(i).sd ) - log10( abs(real(y(i).ydata)));
                ystdL = log10( abs(real(y(i).ydata))) - log10( abs(real(y(i).ydata)) - y(i).sd );
                xder = xd;
                if any( size(xder ) ~= size(yd))
                    xder = repmat(xd,size(yd,1),1);         
                end               
                h = myerrorbar(xder,yd, ystdL, ystdU,'marker','.','color',y(i).linecolor);
                hold on;
                if h > 0 
                    legstr{end+1} = sprintf('%s %s',y(i).legstr,'data');  
                    h1(end+1) = h(1);  
                end
                 set(gca,'xlim',[min(min(xd)) max(max(xd))]);
             end
             
            % Plot Model Response:
            if any(any ( y(i).yresp))
                yd = log10(abs(real(y(i).yresp)));
                ii = isfinite(yd);
                h = plot(xd(ii),yd(ii),'linestyle',y(i).linestyle,'color',y(i).linecolor);
                hold on;
                if h > 0 
                    legstr{end+1} = sprintf('%s %s',y(i).legstr,'response');  
                    h1(end+1) = h(1);  
                end
            end           


             
             % Plot Residual 
            if plotresidual == 1
                subplot(nAxesRows,nAxesCols,1+nAxesCols) 
                set(gca,'fontsize',figfontsize) 
                xd = y(i).xdata;
                resid = ( real(y(i).ydata) - real(y(i).yresp) ) ./ y(i).sd;
                plot(xd,resid,'linestyle','none','marker','.','color',y(i).linecolor);
                hold on;
            end    
         
            
          % Imaginary: 
          
            subplot(nAxesRows,nAxesCols,2)             
            set(gca,'fontsize',figfontsize)  
            xd = y(i).xdata;
           
             % Plot Survey Data:
            if any(any ( y(i).ydata ))                 
                yd = log10(abs(imag(y(i).ydata))); 
                ystdU = log10( abs(imag(y(i).ydata)) + y(i).sd ) - log10( abs(imag(y(i).ydata)));
                ystdL = log10( abs(imag(y(i).ydata))) - log10( abs(imag(y(i).ydata)) - y(i).sd );
                xder = xd;
                if any( size(xder ) ~= size(yd))
                    xder = repmat(xd,size(yd,1),1);         
                end               
                h = myerrorbar(xder,yd, ystdL, ystdU,'marker','.','color',y(i).linecolor);
                hold on;
                if h > 0 
                    h2(end+1) = h(1);  
                end
                set(gca,'xlim',[min(min(xd)) max(max(xd))]);
            end   
            
            % Plot Model Response:
            if any(any ( y(i).yresp))
                yd = log10(abs(imag(y(i).yresp)));
                ii = isfinite(yd);
                h = plot(xd(ii),yd(ii),'linestyle',y(i).linestyle,'color',y(i).linecolor);
                hold on;
                if h > 0 
                    h2(end+1) = h(1);  
                end
            end           

  
            
            
             % Plot Residual 
            if plotresidual == 1
                subplot(nAxesRows,nAxesCols,2+nAxesCols) 
                set(gca,'fontsize',figfontsize) 
                xd = y(i).xdata;
                resid = ( imag(y(i).ydata) - imag(y(i).yresp) ) ./ y(i).sd;
                plot(xd,resid,'linestyle','none','marker','.','color',y(i).linecolor);
                hold on;
            end       
           

         end % loop over all channels in y
       
        subplot(nAxesRows,nAxesCols,1)   
        xlabel(xlab)
        ylabel('abs(Real), log10 V/m/Am, T/Am') 
        h = legend(h1,legstr,'interpreter','none');
        hc = get(h,'children');
        set(hc,'tag','legend');
        title(sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq)));
        box on;
        axis tight
        
        if plotresidual == 1
            subplot(nAxesRows,nAxesCols,1+nAxesCols) 
            xlabel(xlab)
            ylabel('Normalized Residual') 
            % Center the yscale so that biased residual more apparent:
            axis tight
            ax = axis;
             box on;
            my = max(abs(ax(3:4)));
            axis([ax(1:2) -my my]);
        end        
       
        subplot(nAxesRows,nAxesCols,2) 
        xlabel(xlab)
        ylabel('abs(Imaginary), log10 V/m/Am, T/Am') 
        %legend(h2,legstr,'interpreter','none');
        box on;
        axis tight
        
        if plotresidual == 1
            subplot(nAxesRows,nAxesCols,2+nAxesCols) 
            xlabel(xlab)
            ylabel('Normalized Residual') 
            % Center the yscale so that biased residual more apparent:
            axis tight
            ax = axis;
            box on;
            my = max(abs(ax(3:4)));
            axis([ax(1:2) -my my]);
        end       
        
    case 3 % Pmax/Pmin

         for i =1:length(y)  % Loop over all channels and plot the amplitude and phase:
            
             
         % Amplitude:    
            subplot(nAxesRows,nAxesCols,1)   
            set(gca,'fontsize',figfontsize) 
            xd = y(i).xdata;
            
  
           % Plot Survey Data:
            if any(any ( y(i).ydata ) )                
                yd = log10(abs(y(i).ydata)); 
                ystdU = log10( abs(y(i).ydata) + y(i).sd ) - log10( abs(y(i).ydata));
                ystdL = log10( abs(y(i).ydata)) - log10( abs(y(i).ydata) - y(i).sd );
                %ystdL(abs(imag(ystdL))>0) = log10( abs(y(i).ydata(abs(imag(ystdL))>0))) + 20;
                xder = xd;
                if any( size(xder ) ~= size(yd))
                    xder = repmat(xd,size(yd,1),1);         
                end               
                h = myerrorbar(xder,yd, ystdL, ystdU,'marker','.','color',y(i).linecolor);
                hold on;
                if h > 0 
                    legstr{end+1} = sprintf('%s %s',y(i).legstr,'data');  
                    h1(end+1) = h(1);  
                end
            end
             
            % Plot Model Response:
            if any(any ( y(i).yresp))
                yd = log10(abs(y(i).yresp));
                %ii = isfinite(yd);
                %h = plot(xd(ii),yd(ii),'linestyle',y(i).linestyle,'color',y(i).linecolor);
                h = plot(xd,yd,'linestyle',y(i).linestyle,'color',y(i).linecolor);
                hold on;
                if h > 0 
                    legstr{end+1} = sprintf('%s %s',y(i).legstr,'response');  
                    h1(end+1) = h(1);
                end
            end           

      
            
            % Plot Residual 
            if plotresidual == 1
                subplot(nAxesRows,nAxesCols,1+nAxesCols) 
                set(gca,'fontsize',figfontsize) 
                xd = y(i).xdata;
                resid = ( abs(y(i).ydata) - abs(y(i).yresp) ) ./ y(i).sd;
                plot(xd,resid,'linestyle','none','marker','.','color',y(i).linecolor);
                hold on;
            end
            
         end % loop of y(i)
         
       % Add Labels:
        
        subplot(nAxesRows,nAxesCols,1) 

        box on;
        xlabel(xlab)
        ylabel('Amplitude, log10 V/m/Am, T/Am') 
        h = legend( h1,legstr,'interpreter','none');
        hc = get(h,'children');
        set(hc,'tag','legend');
        title(sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq)));
        axis tight
        
        if plotresidual == 1
            subplot(nAxesRows,nAxesCols,1+nAxesCols) 
            xlabel(xlab)
            ylabel('Normalized Residual') 
            % Center the yscale so that biased residual more apparent:
            axis tight
            ax = axis;
            box on;
            my = max(abs(ax(3:4)));
            axis([ax(1:2) -my my]);
             
        end    
           
   
        
    case {4,5} % 'ratio' or relative difference of 2D/primary fields:
        
        % Dec 2008: only set up to handle model responses, not Data!
        % Responses are stored in pairs of 2D,primary in y(i),y(i+1)

        legstr = {}; 
        hamp = [];
        for i =1:2:length(y)

            if plotphase==1 
                subplot(2,1,1)
            else 
                axis;
            end
            set(gca,'fontsize',figfontsize) 
            xd = y(i).xdata;
            
            f1 = y(i).yresp;
            f2 = y(i+1).yresp;
            
            switch yscale
                case 4
                     yd = abs(f1)./abs(f2);
                     legstr ={legstr{:} sprintf('%s / %s',y(i).legstr,y(i+1).legstr)};
                     ylab = 'Anomaly, Ratio';
                case 5
                     
                    yd = 100*( abs(f1)- abs(f2) )./abs(f2);
                    legstr ={legstr{:} sprintf('(%s - %s) / %s',y(i).legstr,y(i+1).legstr,y(i+1).legstr)};
                    ylab = 'Relative Difference, %';
                    
            end
            
            h = plot(xd,yd,'linestyle',y(i).linestyle,'color',y(i).linecolor);
            hold on;
            hamp = [hamp h(1)]; %#ok<AGROW>
           

            if plotphase==1                
                subplot(2,1,2)
                set(gca,'fontsize',figfontsize) 
                p1 = angle(f1);
                p2 = angle(f2);
                pdiff = p1-p2;
                pdiff = 180/pi*unwrap(pdiff,[],unwrapdim);
                plot(y(i).xdata,pdiff,'linestyle',y(i).linestyle,'color',y(i).linecolor)         
                hold on;
             end
        end

        if plotphase==1 
            subplot(2,1,1)
        end     
        xlabel(xlab)
        ylabel(ylab)
         box on;
        set(gca,'fontsize',figfontsize) 
        title(sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq)));

        h = legend(hamp,legstr,'interpreter','none');
        hc = get(h,'children');
        set(hc,'tag','legend');

        if plotphase==1  
            subplot(2,1,2)
            xlabel(xlab)
            axis ij
             box on;
            ylabel('Phase Difference, Degrees')
            set(gca,'fontsize',figfontsize) 
        end


    case {6,7} % File 1 / File 2 Anomaly ratio or relative difference:
        % Dec 2008: only set up to handle model responses, not Data!    
        
      
        ncomp = length(plotcomp);
   
        legstr = {}; 
        hamp = [];
        for i =1:ncomp

            if plotphase==1 
                subplot(2,1,1)
                set(gca,'fontsize',figfontsize) 
            else 
                axis;
            end
            f1 = y(i).yresp;
            f2 = y(i+ncomp).yresp;          
            
            switch yscale
                case 6
                    yd = abs(f1)./abs(f2);
                    legstr ={legstr{:} sprintf('%s / %s',y(i).legstr,y(i+ncomp).legstr)};
                    ylab = 'Anomaly, Ratio';
                case 7
                    yd = 100*( abs(f1)- abs(f2) )./abs(f2);
                    legstr ={legstr{:} sprintf('(%s - %s) / %s',y(i).legstr,y(i+ncomp).legstr,y(i+ncomp).legstr)};
                    ylab = 'Relative Difference, %';
            end
            
            h = plot(y(i).xdata,yd,'linestyle',y(i).linestyle,'color',y(i).linecolor);
            hold on;
            hamp = [hamp h(1)]; %#ok<AGROW>
            

             if plotphase==1         
                subplot(2,1,2)
                set(gca,'fontsize',figfontsize) 
                p1 = angle(f1);
                p2 = angle(f2);
                pdiff = p1-p2;
                pdiff = 180/pi*pdiff;
               % pdiff = 180/pi*unwrap(pdiff,[],unwrapdim);
                plot(y(i).xdata,pdiff,'linestyle',y(i).linestyle,'color',y(i).linecolor)         
                hold on;
            end
        end

        if plotphase==1 
            subplot(2,1,1)
        end     
        xlabel(xlab)
        ylabel(ylab)
        set(gca,'fontsize',figfontsize) 
        title(sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq)));            
        h = legend(hamp,legstr,'interpreter','none');
        hc = get(h,'children');
        set(hc,'tag','legend');
         box on;
        if plotphase==1  
            subplot(2,1,2)
            xlabel(xlab)
            axis ij
             box on;
            ylabel('Phase Difference, Degrees')
            set(gca,'fontsize',figfontsize) 
        end

    end
    set(findobj(gcf,'type','axes'),'xgrid','on','ygrid','on')
    
    
% Add some buttons for changing frequency:
    if CSEM(1).nFreq > 1
   
        set(gcf,'units','normalized');

        % Now add the buttons:
        p2 = [.13  .96 .07 .03 ];
        p1 = [.23  .96 .07 .03 ];

        cbstr = sprintf('plotCSEM(''doplotCSEM'', %i)',plotFreq+1);
        h = uicontrol('Style', 'pushbutton','units','normalized', 'String', 'Next Freq...',...
        'Position', p1, 'Callback', cbstr);  

        cbstr = sprintf('plotCSEM(''doplotCSEM'', %i)',plotFreq-1);
        h = uicontrol('Style', 'pushbutton','units','normalized', 'String', 'Previous Freq...',...
        'Position', p2, 'Callback', cbstr);  
    end
 
 % Set figure  title:
 str = sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq)); 
 set(gcf,'name',str) ;
    
 % tweak the legend font sizes:
   hl = findobj(gcf','tag','legend','type','axes');
   legendfontsize = 10;
   set(hl,'fontsize',legendfontsize)  ;
%--------------------------------------------------------------------------
function phs = getPhase(data,unwrapphase,unwrapdim)


        if unwrapphase==0
             phs = 180/pi*angle(data);
        else            
            phs = 180/pi*unwrap(angle(data),pi,unwrapdim);
        end
 
%--------------------------------------------------------------------------    
 function  [y xlab unwrapdim] = getXAxisData(y,CSEM,Rxind,Txind,plotcomp,plottype,xscale)
%--------------------------------------------------------------------------
    hmenufig = findobj('tag','csemmenufig');  
    ict = 0;
    
    % Loop over all files and selected components:
    for j=1:length(CSEM)
        for i = 1:length(plotcomp)
            ict = ict+1; 
             
            str = get(findobj(hmenufig,'tag','hxaxis'),'str');
            xscaleStr = str{xscale};
            switch xscaleStr

            case  'x'
                if plottype == 2  % Rx Gather:    
                    y(ict).xdata = CSEM(j).xTx(Txind)/1d3; 
                     xlab = 'Transmitter position along x (km)';
                else % Tx Gather
                     y(ict).xdata = CSEM(j).xRx(Rxind)'/1d3; 
                    xlab = 'Receiver position along x (km)';  
                end

            case 'y'
                if plottype == 2  % Rx Gather:  
                    y(ict).xdata = CSEM(j).yTx(Txind)/1d3;
                    xlab = 'Transmitter position along y (km)';
                else % Tx Gather
                    y(ict).xdata = CSEM(j).yRx(Rxind)'/1d3;
                    xlab = 'Receiver position along y (km)';
                end
            case 'z'
                if plottype == 2  % Rx Gather:                      
                    y(ict).xdata = CSEM(j).zTx(Txind)/1d3;
                    xlab = 'Transmitter position along z (km)';
                else
                    y(ict).xdata = CSEM(j).zRx(Rxind)'/1d3;
                    xlab = 'Receiver position along z (km)';
                end
            case 'Range xyz'
               % We need to compute the radial distance from the selected receivers (index) to each Tx...              
                [xr xt] = meshgrid(CSEM(j).xRx(Rxind),CSEM(j).xTx(Txind));
                [yr yt] = meshgrid(CSEM(j).yRx(Rxind),CSEM(j).yTx(Txind));
                [zr zt] = meshgrid(CSEM(j).zRx(Rxind),CSEM(j).zTx(Txind));
                y(ict).xdata = sqrt( (xr-xt).^2 + (yr-yt).^2 + (zr-zt).^2)/1d3;
                y(ict).xdata = y(ict).xdata';
                xlab = 'Range (km)';


            case 'Horizontal Range'
                [xr xt] = meshgrid(CSEM(j).xRx(Rxind),CSEM(j).xTx(Txind));
                [yr yt] = meshgrid(CSEM(j).yRx(Rxind),CSEM(j).yTx(Txind));
                y(ict).xdata = sqrt( (xr-xt).^2 + (yr-yt).^2)/1d3;
                y(ict).xdata = y(ict).xdata';
                xlab = 'Horizontal Range (km)';

            case 'Horizontal Range (in-tow/out-tow)'
                % Need to get in and out tow indices...
                
                [xr xt] = meshgrid(CSEM(j).xRx(Rxind),CSEM(j).xTx(Txind));
                [yr yt] = meshgrid(CSEM(j).yRx(Rxind),CSEM(j).yTx(Txind));
                r = sqrt( (xt-xr).^2 + (yt-yr).^2)/1d3;
                
                if plottype == 2  % Rx Gather, diff along Tx spacing:    
                     rsign = sign(diff(r,1,1));
                     y(ict).xdata = (r.*[rsign; rsign(end,:); ]);
                else % Tx Gather, diff along receiver spacing:
                   rsign = sign(diff(r,1,2));
                    y(ict).xdata = r.*[ rsign rsign(:,end)];
                end
                
                

                
                y(ict).xdata = y(ict).xdata';
                xlab = ' Horizontal Range (km), in-tow(-), out-tow(+)';                       

            case 'Vertical Range'
                [zr zt] = meshgrid(CSEM(j).zRx(Rxind),CSEM(j).zTx(Txind));
                y(ict).xdata = sqrt( (zr-zt).^2)/1d3;
                y(ict).xdata = y(ict).xdata';
                xlab = 'Vertical Range (km)';       

            case 'Rx-Tx Azimuth' % The angle from the receiver to the transmitter, degrees clockwise from x
                [xr xt] = meshgrid(CSEM(j).xRx(Rxind),CSEM(j).xTx(Txind));
                [yr yt] = meshgrid(CSEM(j).yRx(Rxind),CSEM(j).yTx(Txind));
                dx = xt - xr;
                dy = yt - yr;
                azimuth = 180/pi*atan2(dx,dy);
                y(ict).xdata = azimuth';
                xlab = 'Source-Receiver Azimuth (Degrees)';  
                    
            end  % switch
        end % loop over number of components to plot
             
    end % loop over number of files
% Check to make sure xdata and ydata are same size arrays:
% Arrays should be nRx by nTx:
 for i = 1:length(y)
    if any(size(y(i).xdata) ~= size(y(i).ydata))
        [nxi nxj] = size(y(i).xdata);
        [nyi nyj] = size(y(i).ydata);
        % usually x needs from rows added:
        y(i).xdata = repmat(y(i).xdata,nyi/nxi,1);
        y(i).xdata = repmat(y(i).xdata,1,nyj/nxj);
    end
 end
    
% Set phase unwrapping dimension: 
if plottype == 1  % Tx Gather:
   unwrapdim = 1;
else
   unwrapdim = 2;
end
  
    
    % Now clean up the arrays by getting rid of nan's:

    ytemp = y;
    ict = 0;
    for i = 1:length(y)
        if ndims(y(i).ydata)==2
            continue;
        end
 
        yd = y(i).ydata;
        yr = y(i).yresp;
        
        if isempty(yd)
            ii = isfinite(yr);
        else
            ii = isfinite(yr) | isfinite(yd);
        end
        if any(ii)
            ict = ict + 1;
            ytemp(ict) = y(i);
            ytemp(ict).xdata = y(i).xdata(ii);
            ytemp(ict).ydata = y(i).ydata(ii);
            ytemp(ict).yresp = y(i).yresp(ii);
            ytemp(ict).sd    = y(i).sd(ii);
        end
    end
    
    y = ytemp;

 for i = 1:length(y)
    if plottype == 1  % Tx Gather:
        y(i).ydata = (y(i).ydata); 
        y(i).xdata = (y(i).xdata);
        y(i).yresp = (y(i).yresp); 
    else
        y(i).ydata = transpose(y(i).ydata); 
        y(i).xdata = transpose(y(i).xdata);
        y(i).yresp = transpose(y(i).yresp); 
        y(i).sd = transpose(y(i).sd); 
    end
 end    
    
%--------------------------------------------------------------------------
function y = getYAxisData(CSEM,Rxind,Txind,plotFreq,plotcomp,colorby)
%--------------------------------------------------------------------------    
    
   % Take the subset of the fields for the selected transmitters:
    st = struct([]);
    for i=1:length(CSEM)
        % survey dat: 
        st(i).exd =  CSEM(i).ex_data(Rxind,Txind,plotFreq);
        st(i).eyd =  CSEM(i).ey_data(Rxind,Txind,plotFreq);
        st(i).ezd =  CSEM(i).ez_data(Rxind,Txind,plotFreq);
        st(i).bxd =  CSEM(i).bx_data(Rxind,Txind,plotFreq);
        st(i).byd =  CSEM(i).by_data(Rxind,Txind,plotFreq);
        st(i).bzd =  CSEM(i).bz_data(Rxind,Txind,plotFreq);

        % model responses: 
        st(i).exr =  CSEM(i).ex_resp(Rxind,Txind,plotFreq);
        st(i).eyr =  CSEM(i).ey_resp(Rxind,Txind,plotFreq);
        st(i).ezr =  CSEM(i).ez_resp(Rxind,Txind,plotFreq);
        st(i).bxr =  CSEM(i).bx_resp(Rxind,Txind,plotFreq);
        st(i).byr =  CSEM(i).by_resp(Rxind,Txind,plotFreq);
        st(i).bzr =  CSEM(i).bz_resp(Rxind,Txind,plotFreq);
        
        st(i).exp =  CSEM(i).exp(Rxind,Txind,plotFreq);
        st(i).eyp =  CSEM(i).eyp(Rxind,Txind,plotFreq);
        st(i).ezp =  CSEM(i).ezp(Rxind,Txind,plotFreq);
        st(i).bxp =  CSEM(i).bxp(Rxind,Txind,plotFreq);
        st(i).byp =  CSEM(i).byp(Rxind,Txind,plotFreq);
        st(i).bzp =  CSEM(i).bzp(Rxind,Txind,plotFreq);
        
        st(i).exsd =  CSEM(i).ex_sd(Rxind,Txind,plotFreq);
        st(i).eysd =  CSEM(i).ey_sd(Rxind,Txind,plotFreq);
        st(i).ezsd =  CSEM(i).ez_sd(Rxind,Txind,plotFreq);
        st(i).bxsd =  CSEM(i).bx_sd(Rxind,Txind,plotFreq);
        st(i).bysd =  CSEM(i).by_sd(Rxind,Txind,plotFreq);
        st(i).bzsd =  CSEM(i).bz_sd(Rxind,Txind,plotFreq);
        
    end
    
    % Polarization parameters:
	if strmatch('PEmax',plotcomp)
        for i=1:length(CSEM)
            
          [ pmax pmin alpha] = getPolarizationParams(st(i).exd,st(i).eyd);
          st(i).pemaxd = pmax;
          st(i).pemind = pmin;
          [ pmax pmin alpha] = getPolarizationParams(st(i).exr,st(i).eyr);
          st(i).pemaxr = pmax;
          st(i).peminr = pmin;
          % Kludge for when data file has only pmax in it (stored in ex),
          % so that ey is all nans:
          if all(isnan(st(i).eyd));
              st(i).pemaxd = st(i).exd;
          end
          if all(isnan(st(i).eyr));
             st(i).pemaxr = st(i).exr;
          end
                       
          
        end
    end
    
	if strmatch('PBmax',plotcomp)
        for i=1:length(CSEM)
          [ pmax pmin alpha] = getPolarizationParams(st(i).bxd,st(i).byd);
          st(i).pbmaxd = pmax;
          st(i).pbmind = pmin;
         [ pmax pmin alpha] = getPolarizationParams(st(i).bxr,st(i).byr);
          st(i).pbmaxr = pmax;
          st(i).pbminr = pmin;   
          % Kludge for when data file has only pmax in it (stored in ex),
          % so that ey is all nans:
          if all(isnan(st(i).byd));
              st(i).pbmaxd = st(i).bxd;
          end
          if all(isnan(st(i).byr));
              st(i).pbmaxr = st(i).bxr;
          end          
        end
    end    
                
    
  % Now form some structures for each selected component 
  % this way I can loop the plotting function over the number of components
  % 
  
   ict = 0;
   
   % get the default colororder:
   cc = axes('visible','off');
   col = get(gca,'colororder');
   delete(cc);
   
   for i = 1:length(col(:,1))
       colors{i} = col(i,:);
   end
%    colors = {       [      0         0    1.0000]
%                     [      0    0.5000         0]
%                     [ 1.0000         0         0]
%                     [      0    0.7500    0.7500]
%                     [ 0.7500         0    0.7500]
%                     [ 0.7500    0.7500         0]
%                     [ 0.2500    0.2500    0.2500]    };
 
    for j=1:length(CSEM)
        
        istart = ict;
        for i = 1:length(plotcomp)
            thiscomp = plotcomp{i};
            [p fname e] = fileparts(CSEM(j).filename); %#ok<NASGU,NASGU>
            
            styles ={'-' '--'  ':'  '-.' '-' '--' '-.' ':' '-' '--' '-.' ':'}; % kwk debug
            usestyle =  styles{j}; %'-';   
            
            switch thiscomp
 
            case 'Ex'
                ict = ict+1; 
                y(ict).ydata = st(j).exd;   
                y(ict).yresp = st(j).exr;   
                y(ict).sd = abs(st(j).exsd);
                y(ict).legstr = sprintf('Ex:   %s',fname);
                y(ict).linestyle = usestyle;
                y(ict).linecolor = colors{1}; %'b';       
                
                
            case 'Ey'
                ict = ict+1;
                y(ict).ydata = st(j).eyd;  
                y(ict).yresp = st(j).eyr;  
                y(ict).sd = abs(st(j).eysd);
                y(ict).legstr = sprintf('Ey:   %s',fname);
                y(ict).linestyle = usestyle;
                y(ict).linecolor = colors{2}; %'c';     
                
                
            case 'Ez'
                ict = ict+1;
                y(ict).ydata = st(j).ezd; 
                y(ict).yresp = st(j).ezr; 
                y(ict).sd = abs(st(j).ezsd);
                y(ict).legstr = sprintf('Ez:   %s',fname);
                y(ict).linestyle = usestyle;
                y(ict).linecolor = colors{3}; %'c';
                

            case 'Bx'
                ict = ict+1;
                y(ict).ydata = st(j).bxd;
                y(ict).yresp = st(j).bxr; 
                y(ict).sd = abs(st(j).bxsd);
                y(ict).legstr = sprintf('Bx:   %s',fname);
                y(ict).linestyle = usestyle;
                y(ict).linecolor = colors{4}; %'r';   
                


            case 'By'
                ict = ict+1;
                y(ict).ydata = st(j).byd;
                y(ict).yresp = st(j).byr; 
                y(ict).sd = abs(st(j).bysd);
                y(ict).legstr = sprintf('By:   %s',fname);
                y(ict).linestyle = usestyle;
                y(ict).linecolor = colors{5}; %'m';    
                

            case 'Bz'
                ict = ict+1;
                y(ict).ydata = st(j).bzd; 
                y(ict).yresp = st(j).bzr;  
                y(ict).sd = abs(st(j).bzsd);
                y(ict).legstr = sprintf('Bz:   %s',fname);
                y(ict).linestyle = usestyle;
                y(ict).linecolor = colors{6}; %'k';  
                

            case 'Exp'
                ict = ict+1;
                y(ict).yresp = st(j).exp;   
                y(ict).ydata = nan*st(j).exp;  
                y(ict).legstr = sprintf('Exp: %s',fname);
                y(ict).linestyle = '--';
                y(ict).linecolor = colors{1}; %'b';   

            case 'Eyp'
                ict = ict+1;
                y(ict).yresp = st(j).eyp;  
                y(ict).ydata = nan*st(j).eyp;  
                y(ict).legstr = sprintf('Eyp: %s',fname);
                y(ict).linestyle = '--';
                y(ict).linecolor = colors{2}; %'g';     

            case 'Ezp'
                ict = ict+1;
                y(ict).yresp = st(j).ezp; 
                y(ict).ydata = nan*st(j).ezp;  
                y(ict).legstr = sprintf('Ezp: %s',fname);
                y(ict).linestyle = '--';
                y(ict).linecolor = colors{3}; %'c';   

            case 'Bxp'
                ict = ict+1;
                y(ict).yresp = st(j).bxp;   
                y(ict).ydata = nan*st(j).bxp; 
                y(ict).legstr = sprintf('Bxp: %s',fname);
                y(ict).linestyle = '--';
                y(ict).linecolor = colors{4}; %'r';     

            case 'Byp'
                ict = ict+1;
                y(ict).yresp = st(j).byp;   
                y(ict).ydata = nan*st(j).byp; 
                y(ict).legstr = sprintf('Byp: %s',fname);
                y(ict).linestyle = '--';
                y(ict).linecolor = colors{5}; %'m';     

            case 'Bzp'
                ict = ict+1;
                y(ict).yresp = st(j).bzp; 
                y(ict).ydata = nan*st(j).bzp; 
                y(ict).legstr = sprintf('Bzp: %s',fname);
                y(ict).linestyle = '--';
                y(ict).linecolor = colors{6}; %'k';    

                
            case 'PEmax'
                ict = ict+1;
                y(ict).ydata = st(j).pemaxd; 
                y(ict).yresp = st(j).pemaxr; 
                y(ict).sd = abs(st(j).exsd);
                y(ict).legstr = sprintf('PEmax: %s',fname);
                y(ict).linestyle = '-';
                y(ict).linecolor = colors{1};    
                
             case 'PEmin'
                ict = ict+1;
                y(ict).ydata = st(j).pemind; 
                y(ict).yresp = st(j).peminr; 
                y(ict).sd = abs(st(j).eysd);
                y(ict).legstr = sprintf('PEmin: %s',fname);
                y(ict).linestyle = '-';
                y(ict).linecolor = colors{2};  
                
            case 'PBmax'
                ict = ict+1;
                y(ict).ydata = st(j).pbmaxd; 
                y(ict).yresp = st(j).pbmaxr; 
                y(ict).sd = abs(st(j).bxsd);
                y(ict).legstr = sprintf('PBmax: %s',fname);
                y(ict).linestyle = '-';
                y(ict).linecolor = colors{4};    
                
             case 'PBmin'
                ict = ict+1;
                y(ict).ydata = st(j).pbmind; 
                y(ict).yresp = st(j).pbminr; 
                y(ict).sd = abs(st(j).bysd);
                y(ict).legstr = sprintf('PBmin: %s',fname);
                y(ict).linestyle = '-';
                y(ict).linecolor = colors{5};                  
            end

        end % i
        iend = ict;
        
        if colorby == 2; % color by file, overide component colors:
            mm = mod(j,length(colors));
            for i2 = istart+1:iend;
                y(i2).linecolor = colors{max(mm,1)};
                y(i2).linestyle = '-'; % now we use different color lines.
            end
        end
    end % j 
        
%--------------------------------------------------------------------------
    function makePseudosectionPlot(CSEM,xscale,yscale,plotFreq,Txind,Rxind,plotcomp,plotphase)
%--------------------------------------------------------------------------
     figfontsize = 14;



    %  Get the Midpoint and offsets:

    for i = 1:length(plotcomp)

        str = get(findobj(gcf,'tag','hxaxis'),'str');
        xscaleStr = str{xscale};
        switch xscaleStr
            % KWK Debug: these need to be cleanup a bit:
        case 'x'
            [YS YYTX ] = meshgrid(CSEM(1).xRx(Rxind)/1d3,CSEM(1).xTx(Txind)/1d3);
            OFFSET = YYTX - YS;
            MP = YS + OFFSET/2;
            xlab = 'Tx - Rx midpoint along x (km)';

        case 'y'
            [YS YYTX ] = meshgrid(CSEM(1).yRx(Rxind)/1d3,CSEM(1).yTx(Txind)/1d3);
            OFFSET = YYTX - YS;
            MP = YS + OFFSET/2;
            xlab = 'Tx - Rx midpoint along y (km)';

        case 'z'
            [YS YYTX ] = meshgrid(CSEM(1).zRx(Rxind)/1d3,CSEM(1).zTx(Txind)/1d3);
            OFFSET = YYTX - YS;
            MP = YS + OFFSET/2;
            xlab = 'Tx - Rx midpoint along z (km)';

        case {'Horizontal Range (in-tow/out-tow)' ,'Horizontal Range'}
            [XS XXTX ] = meshgrid(CSEM(1).xRx(Rxind)/1d3,CSEM(1).xTx(Txind)/1d3);
            XOFFSET = XXTX - XS;
            [YS YYTX ] = meshgrid(CSEM(1).yRx(Rxind)/1d3,CSEM(1).yTx(Txind)/1d3);
            YOFFSET = YYTX - YS;
            
            % unsigned offsets:
            OFFSET = sqrt(XOFFSET.^2 + YOFFSET.^2);
            rsign = sign(diff(OFFSET));
        
            OFFSET = [rsign(1,:);rsign].*OFFSET;
            RR= sqrt( (XS - XS(1,1)).^2 + (YS - YS(1,1)).^2);
            MP = RR + OFFSET/2;

            xlab = ' Horizontal Midpoint Position (km)';                           
            
        otherwise 
            disp('Sorry, only x,y,z or horizontal range support for horizontal scale of Pseudosections')
            return

         end % switch

    end % loop over number of components to plot
    
    
 % Get the y-axis data for the requested components: 
    y = getYAxisData(CSEM,Rxind,Txind,plotFreq,plotcomp,1);
    
    
%------------------------------------------        
% Plot Pseudosections using MP and OFFSET
%------------------------------------------
 % Dec 2008: only set up to handle model responses, not Data 
        switch yscale
        
        case {1} % Amplitude/Phase or Real/Imag
            
           for i =1:length(y) 
  
                figure('units','pixels','position',[100 100 1200 800]); 

                if plotphase==1 
                    subplot(2,1,1)
                else 
                    axis;
                end
                yd = log10(abs(y(i).yresp));
                
                pcolor(MP',OFFSET',yd);
                shading flat;
                view(2);
                set(gca,'fontsize',figfontsize) 
                xlabel(xlab)
                ylabel('Offset Tx-Rx (km)')
                set(gca,'tag','hcsemplot');
                hc = colorbar('vert');
                set(get(hc,'ylabel'),'string','Amplitude, log10 V/m/Am, T/Am','fontsize',14);  
                str = sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq));
                title(sprintf('%s\n %s',y(i).legstr,str),'interpreter','none')
                legend off
                hold on;    


                if plotphase==1    
                    subplot(2,1,2)
                    pp = 180/pi*unwrap(unwrap(angle(y(i).yresp),pi,2),pi,1);
                    pcolor(MP',OFFSET',pp);
                    shading flat;
                    view(2);
                    set(gca,'fontsize',figfontsize) 
                    xlabel(xlab)
                    ylabel('Offset Tx-Rx (km)')
                    set(gca,'tag','hcsemplot');
                    hc = colorbar('vert');
                    set(get(hc,'ylabel'),'string','Phase Lag, Degrees','fontsize',14); 
                    hold on;

                end
                
              % option to add in contours of the field strengths:
                data.x = MP';
                data.y = OFFSET';
                data.f1 = log10(abs(y(i).yresp));
                data.legstr{1} = y(i).legstr;

                addPseudosectionFigMenus(data)
                
            end %
                  
        case {2} %  Real/Imag
            
           for i =1:length(y) 
  
                figure('units','pixels','position',[100 100 1200 800]); 

                
                subplot(2,1,1)
               
                pcolor(MP',OFFSET',log10(abs(real(y(i).yresp))));
                shading flat;
                view(2);
                set(gca,'fontsize',figfontsize) 
                xlabel(xlab)
                ylabel('Offset Tx-Rx (km)')
                set(gca,'tag','hcsemplot');
                hc = colorbar('vert');
                set(get(hc,'ylabel'),'string','|Real|, log10 V/m/Am, T/Am','fontsize',14);  
                str = sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq));
                title(sprintf('%s\n %s',y(i).legstr,str),'interpreter','none')
                legend off
                hold on;
                
                subplot(2,1,2)
               
                pcolor(MP',OFFSET',log10(abs(imag(y(i).yresp))));
                shading flat;
                view(2);
                set(gca,'fontsize',figfontsize) 
                xlabel(xlab)
                ylabel('Offset Tx-Rx (km)')
                set(gca,'tag','hcsemplot');
                hc = colorbar('vert');
                set(get(hc,'ylabel'),'string','|Imaginary|, log10 V/m/Am, T/Am','fontsize',14);  
                str = sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq));
                title(sprintf('%s\n %s',y(i).legstr,str),'interpreter','none')
                legend off
                hold on;

                
              % option to add in contours of the field strengths:
                data.x = MP';
                data.y = OFFSET';
                data.f1 = log10(abs(y(i).yresp));
                data.legstr{1} = y(i).legstr;

                addPseudosectionFigMenus(data)
                
            end %
                  
      case {3} % Polarization parameters
            
           for i =1:length(y) 
  
                figure('units','pixels','position',[100 100 1200 800]); 

                if plotphase==1 
                    subplot(2,1,1)
                else 
                    axis;
                end
                yd = log10(abs(y(i).yresp));
                
                pcolor(MP',OFFSET',yd);
                shading flat;
                view(2);
                set(gca,'fontsize',figfontsize) 
                xlabel(xlab)
                ylabel('Offset Tx-Rx (km)')
                set(gca,'tag','hcsemplot');
                hc = colorbar('vert');
                set(get(hc,'ylabel'),'string','Amplitude, log10 V/m/Am, T/Am','fontsize',14);  
                str = sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq));
                title(sprintf('%s\n %s',y(i).legstr,str),'interpreter','none')
                legend off
                hold on;   
                
              % option to add in contours of the field strengths:
                data.x = MP';
                data.y = OFFSET';
                data.f1 = log10(abs(y(i).yresp));
                data.legstr{1} = y(i).legstr;

                addPseudosectionFigMenus(data)
                
            end %
            
        case {4,5} % 2D/primary fields ratio or relative difference
            
            for i =1:2:length(y)
                 
                figure('units','pixels','position',[100 100 1200 800]);  
            
                if plotphase==1 
                    subplot(2,1,1)
                else 
                    axis;
                end
                switch yscale
                    case (4)
                        ratio = abs(y(i).yresp)./abs(y(i+1).yresp);
                        str = sprintf('Anomaly Ratio: %s / %s',y(i).legstr,y(i+1).legstr);
                    case (5)
                        ratio = (abs(y(i).yresp) - abs(y(i+1).yresp) )./abs(y(i+1).yresp);
                        str = sprintf('Anomaly, Relative Difference: (%s - %s) / %s',y(i).legstr,y(i+1).legstr,y(i+1).legstr);
                end
                
                pcolor(MP',OFFSET',ratio);
                shading flat;
                view(2);
                set(gca,'fontsize',figfontsize) 
                xlabel(xlab)
                ylabel('Offset Tx-Rx (km)')
                set(gca,'tag','hcsemplot');
                hc = colorbar('vert');
                set(get(hc,'ylabel'),'string','Anomaly','fontsize',14);  

               
                str2 = sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq));
                title(sprintf('%s\n %s',str,str2),'interpreter','none')            

                hold on;

           
                if plotphase==1    
                    subplot(2,1,2)
                    p1 = angle(y(i).yresp);
                    p2 = angle(y(i+1).yresp);
                    pdiff = p1-p2;
                    pcolor(MP',OFFSET',180/pi*unwrap(unwrap(pdiff,[],1),[],2));
                    shading flat;
                    view(2);
                    set(gca,'fontsize',figfontsize) 
                    set(gca,'tag','hcsemplot'); 
                    hold on;

                    xlabel(xlab)
                    ylabel('Offset Tx-Rx (km)')
                    hc = colorbar('vert');
                    set(get(hc,'ylabel'),'string','Phase Difference, Degrees','fontsize',14); 

                end
                
                data.x = MP';
                data.y = OFFSET';
                data.f1 = log10(abs(y(i).yresp));
                data.f2 = log10(abs(y(i+1).yresp));
                data.legstr{1} = y(i).legstr;
                data.legstr{2} = y(i+1).legstr;
                
                addPseudosectionFigMenus(data)
               
            end
            
      
            
        case {6,7} % File1/File2 ratio or relative difference
            
            ncomp = length(plotcomp);
            
            for i =1:ncomp
                
                 figure('units','pixels','position',[100 100 1200 800]);
                 
                % Data are stored in pairs of 2D,2D in y(i),y(i+ncomp)

                if plotphase==1 
                    subplot(2,1,1)
                else 
                    axis;
                end
                switch yscale
                    case (6)
                         ratio = abs(y(i).yresp)./abs(y(i+ncomp).yresp);
                         str = sprintf('Anomaly, Ratio: %s / %s',y(i).legstr,y(i+ncomp).legstr);
                    case (7)
                         ratio = 100*(abs(y(i).yresp)-abs(y(i+ncomp).yresp))./abs(y(i+ncomp).yresp);
                         str = sprintf('Anomaly, Relative Difference: (%s - %s) / %s',y(i).legstr,y(i+ncomp).legstr,y(i+ncomp).legstr);
                end
               
               
                pcolor(MP',OFFSET',ratio);
                shading flat;
                view(2);
                set(gca,'fontsize',figfontsize) 
                hold on;
                set(gca,'tag','hcsemplot');


                xlabel('Midpoint (km)')
                ylabel('Offset Tx-Rx (km)')
                hc = colorbar('vert');
                set(get(hc,'ylabel'),'string','Anomaly','fontsize',14);  
                
                str2 = sprintf('Frequency: %g Hz',CSEM(1).Freq(plotFreq));
                title(sprintf('%s\n %s',str,str2),'interpreter','none')   


                if plotphase==1    
                    subplot(2,1,2)
                    p1 = angle(y(i).yresp);
                    p2 = angle(y(i+ncomp).yresp);
                    pdiff = p1-p2;
                    pcolor(MP',OFFSET',180/pi*unwrap(unwrap(pdiff,[],1),[],2));
                    shading flat;
                    view(2);
                    set(gca,'fontsize',figfontsize) 
                    hold on;
                    set(gca,'tag','hcsemplot');

                    xlabel('Midpoint (km)')
                    ylabel('Offset Tx-Rx (km)')
                    hc = colorbar('vert');
                    set(get(hc,'ylabel'),'string','Phase Difference, Degrees','fontsize',14); 

                end
                
                data.x = MP';
                data.y = OFFSET';
                data.f1 = log10(abs(y(i).yresp));
                data.f2 = log10(abs(y(i+ncomp).yresp));
                data.legstr{1} = y(i).legstr;
                data.legstr{2} = y(i+ncomp).legstr;
                
                addPseudosectionFigMenus(data)
            end
 
        end


    
%--------------------------------------------------------------------------
    function addPseudosectionFigMenus(data)
%--------------------------------------------------------------------------       
        % Add some menubar call backs to the pseudosection plots that
        % control the offset plotting: positive, negative, or both:
            h0 = uimenu('label','Offset Options');
            cbstr = 'plotCSEM(''adjustPseudosectionAxes'',''Positive'')';
            uimenu('parent',h0,'label','Positive Only','callback',cbstr);
            cbstr = 'plotCSEM(''adjustPseudosectionAxes'',''Negative'')';
            uimenu('parent',h0,'label','Negative Only','callback',cbstr);
            cbstr = 'plotCSEM(''adjustPseudosectionAxes'',''Both'')';
            uimenu('parent',h0,'label','Positive and Negative','callback',cbstr);    
       
            set(gcf,'userdata',data);
            h0 = uimenu('label','Contour Options');
            cbstr = 'plotCSEM(''adjustPseudosectionContours'',1)';
            uimenu('parent',h0,'label',sprintf('File 1: %s',data.legstr{1}),'callback',cbstr);   
            if length(data.legstr) > 1 
                cbstr = 'plotCSEM(''adjustPseudosectionContours'',2)';
                uimenu('parent',h0,'label',sprintf('File 2: %s',data.legstr{2}),'callback',cbstr); 
                cbstr = 'delete(findobj(gcf,''tag'',''hcontours''));';
                uimenu('parent',h0,'label','Delete Contours','callback',cbstr); 
            end

    
%--------------------------------------------------------------------------
    function adjustPseudosectionAxes(limit)
%--------------------------------------------------------------------------
     hax = findobj(gcf,'tag','hcsemplot'); 
     
     for i= 1:length(hax)
         axes(hax(i));
         switch limit
         case 'Positive'
             axis auto
             axis ij;
             ax = axis;
             axis([ax(1:2) 0 ax(4)])
         case 'Negative'
             axis auto
             axis xy;
             ax = axis;
             axis([ax(1:2) ax(3) 0 ])
         case 'Both'
             axis auto
             axis xy
         end
     end
%--------------------------------
    function adjustPseudosectionContours(file)
%--------------------------------
     hax = findobj(gcf,'tag','hcsemplot'); 
     
     delete(findobj(gcf,'tag','hcontours'));

     data = get(gcf,'userdata');
      if file==1
          ff = data.f1;
      else
          ff = data.f2;
      end    
      for i=1:length(hax)
          axes(hax(i))
          ca = caxis;
         [c h] = contour(data.x,data.y,ff,-20:1:-8,'k-' );
         h2 = clabel(c,h);
         caxis(ca);
         set(h,'tag','hcontours');
         set(h2,'tag','hcontours');
      end

%--------------------------------
    function type = getsitearraytype(CSEM)
% Get the site array type:
%--------------------------------

  % See if there's more Tx's than Rx's
    if CSEM.nTx > CSEM.nRx
        % unique locations along each axis::
        xx = unique(CSEM.xTx); 
        yy = unique(CSEM.yTx);
        zz = unique(CSEM.zTx);
    else 
        xx = unique(CSEM.xRx); 
        yy = unique(CSEM.yRx);
        zz = unique(CSEM.zRx);    
    end
    
    % get spatial extents:
    dx = max(xx) - min(xx);
    dy = max(yy) - min(yy);
    dz = max(zz) - min(zz);
    
    % Select line type based on maximum spatial extent.  This works for
    % long lines anlong the model axes but not slants or  grids..
    if dx > max(dy,dz)
        type = 'xline';
    elseif dy > max(dx,dz)
        type = 'yline';
    elseif dz > max(dx,dy)
        type = 'zline';
    else
        type = 'unknown';
    end
   



%--------------------------------------------------------------------------
    function plotcomp = getCompsToPlot(yscale)
    hmenufig = findobj('tag','csemmenufig'); 
    plotcomp = {};
    if get(findobj(hmenufig,'tag','hex'),'value') == 1 
        plotcomp = {plotcomp{:} 'Ex'};
    end
    if get(findobj(hmenufig,'tag','hey'),'value') == 1 
        plotcomp = {plotcomp{:} 'Ey'};
    end
    if get(findobj(hmenufig,'tag','hez'),'value') == 1 
        plotcomp = {plotcomp{:} 'Ez'};
    end    
    if get(findobj(hmenufig,'tag','hbx'),'value') == 1 
        plotcomp = {plotcomp{:} 'Bx'};
    end
    if get(findobj(hmenufig,'tag','hby'),'value') == 1 
        plotcomp = {plotcomp{:} 'By'};
    end
    if get(findobj(hmenufig,'tag','hbz'),'value') == 1 
        plotcomp = {plotcomp{:} 'Bz'};
    end    
    if get(findobj(hmenufig,'tag','hexp'),'value') == 1 
        plotcomp = {plotcomp{:} 'Exp'};
    end
    if get(findobj(hmenufig,'tag','heyp'),'value') == 1 
        plotcomp = {plotcomp{:} 'Eyp'};
    end
    if get(findobj(hmenufig,'tag','hezp'),'value') == 1 
        plotcomp = {plotcomp{:} 'Ezp'};
    end    
    if get(findobj(hmenufig,'tag','hbxp'),'value') == 1 
        plotcomp = {plotcomp{:} 'Bxp'};
    end
    if get(findobj(hmenufig,'tag','hbyp'),'value') == 1 
        plotcomp = {plotcomp{:} 'Byp'};
    end
    if get(findobj(hmenufig,'tag','hbzp'),'value') == 1 
        plotcomp = {plotcomp{:} 'Bzp'};
    end    
    
     % If 2D/primary anomaly plots, then make sure we include the primary components:
    if yscale == 4 || yscale ==5
       nc = length(plotcomp);
       for i = 1:nc
           switch plotcomp{i}
           case 'Ex'
                plotcomp = {plotcomp{:} 'Exp'};
           case 'Ey'
                plotcomp = {plotcomp{:} 'Eyp'};
           case 'Ez'
                plotcomp = {plotcomp{:} 'Ezp'};    
           case 'Bx'
                plotcomp = {plotcomp{:} 'Bxp'};
           case 'By'
                plotcomp = {plotcomp{:} 'Byp'};
           case 'Bz'
                plotcomp = {plotcomp{:} 'Bzp'};                   
           end
       end
    
    end
    
  % Now overide these values if polarization plot requested:
   if yscale == 3 
        plotcomp = {'PEmax' 'PEmin' 'PBmax' 'PBmin'};
        % Add z comps if requested:
        if get(findobj(hmenufig,'tag','hez'),'value') == 1 
            plotcomp = {plotcomp{:} 'Ez'};
        end  
        if get(findobj(hmenufig,'tag','hbz'),'value') == 1 
            plotcomp = {plotcomp{:} 'Bz'};
        end            
   end

  % Sort the plotcomponent order to standardize things:
    plotcomp = unique(plotcomp);    

 %------------------------------------------------------------------------ 
 
    function [ pmax pmin alpha] = getPolarizationParams(ex,ey)
     % compute the polarization parameters:
    ax = abs(ex);
    ay = abs(ey);
    px = angle(ex);
    py = angle(ey);
    dp = py-px; 
    alpha = 1/2*atan2(2*ax.*ay.*cos(dp),(ax.^2-ay.^2));
    II = sqrt(-1);
    pmax = abs(ay.*exp(II*dp).*sin(alpha) + ax.*cos(alpha));
    pmin = abs(ay.*exp(II*dp).*cos(alpha) - ax.*sin(alpha));
    
    