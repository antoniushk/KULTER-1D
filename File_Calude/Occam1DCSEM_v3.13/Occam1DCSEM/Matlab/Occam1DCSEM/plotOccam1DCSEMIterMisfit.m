function plotOccam1DCSEMIterMisfit( varargin  )
%--------------------------------------------------------------------------    
% function plotOccamIterMisfit(sFullFile);
%
% Reads in all iteration files up to lastfile and plots up the misfit and
% roughness
%
% Kerry Key
% Scripps Institution of Oceanography
% 
% 09/01/2006 Created
% DGM Nov 2006 - updated to new iteration format & file naming convention
%
% Dec 2010, KWK: Renamed to avoid conflict with similar code in Occam2DMT,
% This code is slighyly different since the CSEM iteration files have an 
% updated naming convention that is not fixed at 2 characters like the
% clunky 2DMT convention.
%--------------------------------------------------------------------------
    
    if nargin ==1
        sRoot = varargin{1};
        [sPath sRoot] =fileparts(sRoot) ;
        t = regexp(sRoot,'([a-zA-Z]+)(\d*|_)','tokens');
        sRoot = t{1}{1};
        if regexp(t{1}{2},'_')
            sDelim = '_';
        else
            sDelim = '';
        end
    else
       sPath ='./';
       sRoot = '*'; % no file root, just use whatever is in the current directory
       sDelim = '_';
    end
    
    
    % Get most recent iteration file
%     files = dir(sprintf('%s.iter',sRoot));
    files = dir(fullfile(sPath, [sRoot '*.iter']));
    for i = 1:length(files)
        files(i).date = datenum(files(i).date);
    end
    
    % Now sort them by date:
    [temp isort] = sort([files.date]);
    isort = fliplr(isort); % descending order
    sFile = files(isort(1)).name;    

    
    % Get most recent iteration number:
    stIter = readOccamIteration(fullfile(sPath,sFile));
    ilast = stIter.nIteration;
    
    % If no sRoot given, find out what it is now:
    sRoot = strtok(sRoot,'_');
     if strcmpi(sRoot,'*')
         str = sprintf('_%i.iter',ilast);
          ii = findstr(sFile,str);
         sRoot = sFile(1:ii-1);
     end
    
    % Now read in all files up to that one and plot the misfit and
    % roughness:
    for i = 1:ilast

        
        % Read in the Iteration File:  
        sFile = fullfile(sPath,sprintf('%s%s%i.iter',sRoot,sDelim,i)); 
        if exist( sFile, 'file' )
            stIter = readOccamIteration(sFile);
            misfit(i)    = stIter.nMisfit;
            roughness(i) = stIter.nRoughness;
        else
            misfit(i)    = NaN;
            roughness(i) = NaN;
        end
    end
    
    % plot it:
    
    figure;
    
    % Misfit
    subplot(3,1,1)
    semilogy(misfit,'.-');
    xlabel('Iteration Number');
    ylabel('RMS Misfit');
    
    % Model roughness
    subplot(3,1,2); 
    plot(roughness,'.-');
    xlabel('Iteration Number');
    ylabel('Roughness');
 
    subplot(3,1,3); 
    plot(roughness,misfit,'.-');
    xlabel('Roughness');
    ylabel('Misfit');

    % New March 6, 2007: read in logfile and plot that up....
    lfile= sprintf('%s.logfile',sRoot); %'LogFile.logfile';
    if ~exist(lfile,'file')
        lfile = 'LogFile.logfile';
        if ~exist(lfile,'file')
            return
        end
    end
    fid = fopen(lfile,'r');
    if fid<0 
        return
    end
    misfit = [];
    mu = [];
    iter = 1;
    while 1
        line=fgets(fid);
        if line==-1
            break
        end
        line  = lower(line);
        if strfind(line,'iteration');
            % first save last loop
            stOCC(iter).misfit = misfit;
            stOCC(iter).mu = mu;
             
            iter = sscanf(line,' ** iteration      %i   **');
            misfit = []; % reset
            mu = [];
        end
        if strfind(line,'tofmu'); 
           temp = sscanf(line,' tofmu: misfit =%g amu = %g');
           if numel(temp)==2
               misfit = [misfit, temp(1)];
               mu = [mu, 10.^temp(2)];
           end
        end    
    end
    
    stOCC(iter).misfit = misfit;
    stOCC(iter).mu = mu;
 
    fclose(fid);
    figure;
    for i=1:length(stOCC)
        [ y isort] = sort(stOCC(i).mu);
        loglog(stOCC(i).mu(isort),stOCC(i).misfit(isort),'.-');
        hold all;
        
    end
    xlabel('Mu');ylabel('Misfit')
    legend(num2str([1:length(stOCC)]'))
    title('Misfit vs Lagrange multiplier for Occam iterations');
    
    
    
return    
