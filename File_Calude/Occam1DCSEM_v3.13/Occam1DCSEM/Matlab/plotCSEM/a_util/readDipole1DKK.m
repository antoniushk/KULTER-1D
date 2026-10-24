%--------------------------------------------------------------------------
% function CSEM = readDipole1D(file)
%
% Reads in the .csem file output from Dipole1D into a Matlab structure.
%
% Note this is outputting B (T/Am) and not H.
%
% Outputs CSEM responses in CSEM structure:
%
% CSEM.filename 
% CSEM.DipoleLen  
% CSEM.nTx
% CSEM.xTx, CSEM.yTx, CSEM.zTx, CSEM.AzimuthTx, CSEM.DipTx
% CSEM.nRx
% CSEM.xRx, CSEM.yRx, CSEM.zRx
% CSEM.ThetaRx,CSEM.AlphaRx, CSEM.BetaRx   Orientation angles for Rx
% CSEM.nFreq
% CSEM.Freq
% CSEM.ex_data, CSEM.ey_data, CSEM.ez_data    [ nRxs by nTx by nFreq] complex data arrays = nan for forward code
% CSEM.bx_data, CSEM.by_data, CSEM.bz_data    [ nRxs by nTx by nFreq] complex data arrays = nan for forward code
% CSEM.ex_resp, CSEM.ey_resp, CSEM.ez_resp    [ nRxs by nTx by nFreq] complex model response arrays
% CSEM.bx_resp, CSEM.by_resp, CSEM.bz_resp    [ nRxs by nTx by nFreq] complex model response arrays
% CSEM.ex_sd, CSEM.ey_sd, CSEM.ez_sd  Standard errors = nan for forward code
% CSEM.bx_sd, CSEM.by_sd, CSEM.bz_sd  Standard errors = nan for forward code
% CSEM.exp, CSEM.eyp, CSEM.ezp   Primary fields from scattered field comp = nan for 1D code
% CSEM.bxp, CSEM.byp, CSEM.bzp   Primary fields from scattered field comp = nan for 1D code
%
% Kerry Key
% Scripps Institution of Oceanography
%
% Revisions: 
% 1.2    February, 2010  Added in support for Dipole1D_1.1 (DipoleLen)
% 1.1    December, 2008  Modified structure
% 1.0    Spring 2008     Created
%
%--------------------------------------------------------------------------
    function CSEM = readDipole1D(file)
%--------------------------------------------------------------------------        
%
% Reads in the output file from Dipole1D.f90
% Returns entire problem description and CSEM response
% in the structure CSEM
%
    fid = fopen(file,'r');
    if (fid<=0)
           disp(sprintf('Error opening Dipole1D output file: %s' ,file));
           return
    end
    format = strtrim(fgets(fid));
    if ~any(strcmpi(format,{'Dipole1D_1.0','Dipole1D_1.1'}))
        beep;
        disp(sprintf('Error in reading file: %s',file))
        disp(sprintf('Unknown File format: %s',format))
        disp('Only Dipole1D_1.0 and _1.1 currently supported.');
        return    
    end
    [p n ] = fileparts(file);
    CSEM.filename = n;
    if strcmpi(format,'Dipole1D_1.0')
       CSEM.DipoleLen = 0;
    else
       CSEM.DipoleLen      = fscanf(fid,'%g\n',1); 
    end
    
    
    CSEM.nTx       = fscanf(fid,'%i\n',1);
    temp           = fscanf(fid,'%g %g %g %g %g\n',[5 CSEM.nTx]);
    CSEM.xTx       = temp(1,:);
    CSEM.yTx       = temp(2,:);
    CSEM.zTx       = temp(3,:);
    CSEM.AzimuthTx = temp(4,:);
    CSEM.DipTx     = temp(5,:);
    
    CSEM.nFreq      = fscanf(fid,'%i\n',1);  
    CSEM.Freq       = fscanf(fid,'%g\n',CSEM.nFreq);      
    
%     CSEM.nlay       = fscanf(fid,'%i\n',1);  
%     temp            = fscanf(fid,'%g %g\n',[2 CSEM.nlay]);  
%     CSEM.zlay       = temp(1,:);
%     CSEM.rholay     = temp(2,:);
  % Skip these for now since they aren't compatible with plotCSEM.m
  % file
    skip       = fscanf(fid,'%i\n',1);  
    temp       = fscanf(fid,'%g %g\n',[2 skip]);  
    skip       = temp(1,:);
    skip     =   temp(2,:);    
    
    CSEM.nRx        = fscanf(fid,'%i\n',1);  
    temp            = fscanf(fid,'%g %g %g\n',[3 CSEM.nRx]);  
    CSEM.xRx        = temp(1,:);
    CSEM.yRx        = temp(2,:);        
    CSEM.zRx        = temp(3,:);  
%    CSEM.siteslope  = 0*temp(3,:); % dummy array    
    CSEM.ThetaRx = 0*CSEM.zRx;
    CSEM.AlphaRx = CSEM.ThetaRx;
    CSEM.BetaRx  = CSEM.ThetaRx;
    
% initialize:
    CSEM.ex_resp = zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.ey_resp = CSEM.ex_resp;
    CSEM.ez_resp = CSEM.ex_resp; 
    CSEM.bx_resp = CSEM.ex_resp;
    CSEM.by_resp = CSEM.ex_resp;
    CSEM.bz_resp = CSEM.ex_resp;
 

% Now read the nTx by nFreq blocks of the CSEM responses, which are 
% each nRx by 6 (real, imaginary) pairs for ex,ey,ez,bx,by,bz:    
    for iTx = 1:CSEM.nTx
        for iFreq = 1:CSEM.nFreq
            temp = fscanf(fid,'%g %g %g %g %g %g %g %g %g %g %g %g\n',[12 CSEM.nRx]);  
            
            CSEM.ex_resp(:,iTx,iFreq) = temp(1,:)  + sqrt(-1)* temp(2,:)  ; 
            CSEM.ey_resp(:,iTx,iFreq) = temp(3,:)  + sqrt(-1)* temp(4,:)  ; 
            CSEM.ez_resp(:,iTx,iFreq) = temp(5,:)  + sqrt(-1)* temp(6,:)  ; 
            CSEM.bx_resp(:,iTx,iFreq) = temp(7,:)  + sqrt(-1)* temp(8,:)  ; 
            CSEM.by_resp(:,iTx,iFreq) = temp(9,:)  + sqrt(-1)* temp(10,:) ; 
            CSEM.bz_resp(:,iTx,iFreq) = temp(11,:) + sqrt(-1)* temp(12,:) ;   
            
               
        end
    end
    fclose(fid);
    
  % Dummy arrays for primary fields
    CSEM.exp = nan*CSEM.ex_resp; 
    CSEM.eyp = nan*CSEM.ex_resp; 
    CSEM.ezp = nan*CSEM.ex_resp; 
    CSEM.bxp = nan*CSEM.ex_resp; 
    CSEM.byp = nan*CSEM.ex_resp; 
    CSEM.bzp = nan*CSEM.ex_resp;   
    
% Dummy arrays for standard errors:
    CSEM.ex_sd = nan*CSEM.ex_resp; 
    CSEM.ey_sd = nan*CSEM.ex_resp; 
    CSEM.ez_sd = nan*CSEM.ex_resp; 
    CSEM.bx_sd = nan*CSEM.ex_resp; 
    CSEM.by_sd = nan*CSEM.ex_resp; 
    CSEM.bz_sd = nan*CSEM.ex_resp;  
    
% Dummy arrays for data:
    CSEM.ex_data = nan*CSEM.ex_resp; 
    CSEM.ey_data = nan*CSEM.ex_resp; 
    CSEM.ez_data = nan*CSEM.ex_resp; 
    CSEM.bx_data = nan*CSEM.ex_resp; 
    CSEM.by_data = nan*CSEM.ex_resp; 
    CSEM.bz_data = nan*CSEM.ex_resp;   

    
  % Sort the fields in alphabetical order  
    CSEM = orderfields(CSEM);
    