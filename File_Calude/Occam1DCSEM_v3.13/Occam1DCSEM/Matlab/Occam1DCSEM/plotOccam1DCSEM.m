    function plotOccam1DCSEM(varargin)
%
% Function to read in and plot an iteration from Occam1DCSEM.
%
% Usage:
%
%  >> plotOccam1DCSEM  -  asks you to select the iteration file to plot
%
%  >> plotOccam1DCSEM('MyIterationFile.iter') - plots MyIterationFile.iter
%
%  >> plotOccam1DCSEM('lastiter') - plots most recent iteration in current
%                                   directory
%
%  >> plotOccam1DCSEM('alliter') - plots all iterations in the current
%                                  directory
%
%  >> plotOccam1DCSEM({myiters}) - plots all iterations in the cell
%                                 array 'myiters'
%
%
% Kerry Key
% Scripps Institution of Oceanography
%
% November, 2008.  Still a work in progress. No support for data and
% responses yet.
% 
%
    if nargin == 0   % New plot, ask for file:
        
        cFileSpec = {'*.iter','Iteration files (*.iter)';'*.*','All Files'};
        [sFile,sIterPath] ...
            = uigetfile( cFileSpec, 'Select OCCAM iteration file to plot:' );
        if ~ischar(sFile)
            disp('No files selected for plotting, returning...')
            return
        end    
        sFile = fullfile(sIterPath,sFile);
        
        makeNewPlot(sFile);  
  
        
    elseif nargin ==1
        
        sFile = varargin{1};
        
        if iscellstr(sFile) % User has input cell array of many file names:
            
            makeNewPlotCell(sFile)
            
        else 
            

            switch  lower(sFile)

                case {'lastiter'}

                    % Get all iteration files
                   files = dir('*.iter'); 

                   % If that returns nothing, try old Occam filename convention: 
                   if isempty(files)
                        files = dir('ITER*');
                   end

                   % Now sort them by date:
                   for i = 1:length(files)
                       files(i).date = datenum(files(i).date);
                   end
                    [temp isort] = sort([files.date]);
                    isort = fliplr(isort); % descending order
                    sFile = files(isort(1)).name;    

                    makeNewPlot(sFile);  

                case {'alliter'}

                    % Get all iteration files
                   files = dir('*.iter'); 

                   % If that returns nothing, try old Occam filename convention: 
                   if isempty(files)
                        files = dir('ITER*');
                   end

                   % Now sort them by date:
                   for i = 1:length(files)
                       files(i).date = datenum(files(i).date);
                   end
                    [temp isort] = sort([files.date]);
                    %isort = fliplr(isort); % descending order
                    sFile =[];
                    for i = 1:length(files)
                        sFile{i} = files(isort(i)).name;   
                    end

                    makeNewPlotCell(sFile)
                    
                otherwise % sFile is name of file to plot:

                    makeNewPlot(sFile);  

            end
        end
      
    end
    
% Plot the misfit roughness profile:
   % plotOccamIterMisfit(sFile)

   % plotResp1DCSEM(sFile)

%--------------------------------------------------------------------------   
   function makeNewPlot(sFile)
%
% Reads in iteration named in sFile, and plots it to a new figure window
   
    if isempty(sFile)
        return
    end
  % Read in the iteration, model and data files:
    stOccam = readOccam1DCSEM(sFile);
  % stOccam now has substructures stIter,stModel and stData 
 
   % Plot the Model:
    hfig = figure;
    plotModel(stOccam,hfig)
    [p f] = fileparts(sFile);
    legstr = sprintf('%s : RMS %5.2f',f,stOccam.stIter.nMisfit);
    hl = legend(legstr,'Location','west');
    set(hl,'interpreter','none','fontsize',10);
   
%--------------------------------------------------------------------------   
   function makeNewPlotCell(sFile)
%
% Reads in iteration named in sFile, and plots it to a new figure window
% for cell array of files in sFile  
    if isempty(sFile)
        return
    end
    hfig = figure;
    
    nF = length(sFile);
    cc = logspace(-1.,-.2,nF-1);
    cc = abs(cc-1);
    cc(end+1) = 0;

    
    for i=1:length(sFile)

      % Read in the iteration, model and data files:
        stOccam = readOccam1DCSEM(sFile{i});
         % stOccam now has substructures stIter,stModel and stData 
 
        % Plot the Model:
        plotModel(stOccam,hfig,[cc(i),cc(i),cc(i)])
            [p f] = fileparts(sFile{i});
        legstr{i} = sprintf('%s : RMS %5.2f',f,stOccam.stIter.nMisfit);
    end
    
    hl = legend(legstr,'Location','west');
    
    set(hl,'interpreter','none','fontsize',10);
    
%--------------------------------------------------------------------------
    function stOccam = readOccam1DCSEM(sFile)
% A subfunction for reading in the interation, model and data files for an
% Occam1DCSEM inversion

% Read in the Iteration File:  
    stOccam.stIter = readOccamIteration( sFile );
  
    % DGM Dec 2009 - assume model & data files are in the same folder as the
    % iteration file.
    [p f e] = fileparts( sFile );
    stOccam.stIter.sModelFile   = fullfile( p, stOccam.stIter.sModelFile );
    stOccam.stIter.sDataFile    = fullfile( p, stOccam.stIter.sDataFile );
    
% Read in the Model File:
    stOccam.stModel = readResistivity1DModel( stOccam.stIter.sModelFile);

% Read in the Data File:   


% Read in the Response File:

    
%--------------------------------------------------------------------------   
    function plotModel(stOccam,hfig,varargin)
%
% Utility function for the actual plotting commands

  if nargin ==3
      linecolor = varargin{1};
  else
      linecolor = 'k';
  end

  % Set up the model for plotting:   
  % If first layer is an air layer, we omit it:
    if stOccam.stModel.layers(1,2) >1e6 
        stOccam.stModel.layers = stOccam.stModel.layers(2:end,:);
    end
 
    zTop = stOccam.stModel.layers(:,1)/1d3;  % Convert depths to km
    rho = stOccam.stModel.layers(:,2);       % Get resistivities, inclduing fixed layers
    rho(rho<0) = 10.^stOccam.stIter.nParams;  % If resistivity is free parameter, push in results from iteration file.
    
    % Create the model layer and resistivity staircase arrays:
    Tops = zTop;  % Add a fake top
    Bots = [zTop(2:end);zTop(end)+(zTop(end)-zTop(end-1))];
    Depths = [Tops Bots];
    Depths =reshape(Depths',numel(Depths),1);
    Rhos   = [rho rho; ];
    Rhos = reshape(Rhos',numel(Rhos),1);
    
    % Plot the Model:
    
    figure(hfig); 
    semilogx(Rhos,Depths,'-','linewidth',2,'color',linecolor);
    set(gca,'fontsize',12)
    hold on;
    axis ij
    xlabel('Resistivity (ohm-m)')
    ylabel('Depth (km)')

  

 
    return