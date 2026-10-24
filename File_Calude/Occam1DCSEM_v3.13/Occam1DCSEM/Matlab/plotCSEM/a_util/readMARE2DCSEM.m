%--------------------------------------------------------------------------
% function CSEM = readMARE2DCSEM(file)
%
% Reads in the .csem file output from MARE2DCSEM into a Matlab structure.
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
%--------------------------------------------------------------------------
    function CSEM = readMARE2DCSEM(file)
%--------------------------------------------------------------------------
    % Set dummy value for dipole length, here a point dipole 
    CSEM.DipoleLen = 0;    
    
    % Open the file:
    fid     = fopen(file,'r');
    if fid<1
        return
    end   
    format = lower(strtrim(fgets(fid)));
    switch format
        case {'mare2dcsem_2.0'}
        % a okay, do nothing 
        case {'mare2dcsem_3.0'}
            temp  = fgetl(fid); % skip the first comment line
        otherwise
            beep;
            disp(sprintf('Error in reading file: %s',file))
            disp(sprintf('Unknown File format: %s',format))
            disp('Only MARE2DCSEM_2.0 is currently supported.');
    end

    
    temp  = fgets(fid);
    temp  = sscanf(temp,'%g',3);
    CSEM.nTx   = temp(1);
    CSEM.nRx = temp(2);
    CSEM.nFreq = temp(3);
    
    [p n ] = fileparts(file);
    CSEM.filename = file;
%     CSEM.gathertype = [];
%     CSEM.gatherindex = [];
    
 % Read in the transmitter info:   
    fgets(fid); % skip comment line
    temp    = fscanf(fid,'%g\n',[5 CSEM.nTx]);
    CSEM.xTx     = temp(1,:);
    CSEM.yTx     = temp(2,:);
    CSEM.zTx     = temp(3,:);
    CSEM.AzimuthTx = temp(4,:);
    CSEM.DipTx     = temp(5,:);
    
 % Read in the site locations:
    fgets(fid);  % skip comment line
    temp      = fscanf(fid,'%g\n',[4 CSEM.nRx]);
    CSEM.xRx     = temp(1,:);
    CSEM.yRx     = temp(2,:);
    CSEM.zRx     = temp(3,:);
       % CSEM.siteslope = temp(4,:);  
    CSEM.ThetaRx = 0*CSEM.zRx;
    CSEM.AlphaRx = CSEM.ThetaRx;
    CSEM.BetaRx  = CSEM.ThetaRx;


 % Read in Frequencies:
    fgetl(fid); % skip comment line
    CSEM.Freq = fscanf(fid,'%g\n',[CSEM.nFreq]);

 % Now loop though the nFreq by nTx blocks of site responses:
 % Arrays will be dimensioned ex(1:nRx,1:nTx,1:nFreq)
 % pre-allocate for faster performance
 %   [CSEM.ex, CSEM.ey, CSEM.ez, CSEM.bx, CSEM.by, CSEM.bz] = deal(zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq));
   
   fgetl(fid);  % skip comment line   

    for iFreq=1:CSEM.nFreq
        for itx = 1:CSEM.nTx
            temp = fgetl(fid); % skip comment line 
            switch format
                case 'mare2dcsem_2.0'
                    temp = fscanf(fid,'%g\n', [24,CSEM.nRx]);
                    CSEM.ex_resp(:,itx,iFreq) = [temp(1,:)  + sqrt(-1)*temp(2,:)].';
                    CSEM.ey_resp(:,itx,iFreq) = [temp(3,:)  + sqrt(-1)*temp(4,:)].';
                    CSEM.ez_resp(:,itx,iFreq) = [temp(5,:)  + sqrt(-1)*temp(6,:)].';
                    CSEM.bx_resp(:,itx,iFreq) = [temp(7,:)  + sqrt(-1)*temp(8,:)].';
                    CSEM.by_resp(:,itx,iFreq) = [temp(9,:)  + sqrt(-1)*temp(10,:)].';
                    CSEM.bz_resp(:,itx,iFreq) = [temp(11,:) + sqrt(-1)*temp(12,:)].';
                    CSEM.exp(:,itx,iFreq) = [temp(13,:)  + sqrt(-1)*temp(14,:)].';
                    CSEM.eyp(:,itx,iFreq) = [temp(15,:)  + sqrt(-1)*temp(16,:)].';
                    CSEM.ezp(:,itx,iFreq) = [temp(17,:)  + sqrt(-1)*temp(18,:)].';
                    CSEM.bxp(:,itx,iFreq) = [temp(19,:)  + sqrt(-1)*temp(20,:)].';
                    CSEM.byp(:,itx,iFreq) = [temp(21,:)  + sqrt(-1)*temp(22,:)].';
                    CSEM.bzp(:,itx,iFreq) = [temp(23,:) + sqrt(-1)*temp(24,:)].'; 
                case  'mare2dcsem_3.0'
                    temp = fscanf(fid,'%g\n', [12 CSEM.nRx]);
                    CSEM.ex_resp(:,itx,iFreq) = [temp(1,:)  + sqrt(-1)*temp(2,:)].';
                    CSEM.ey_resp(:,itx,iFreq) = [temp(3,:)  + sqrt(-1)*temp(4,:)].';
                    CSEM.ez_resp(:,itx,iFreq) = [temp(5,:)  + sqrt(-1)*temp(6,:)].';
                    CSEM.bx_resp(:,itx,iFreq) = [temp(7,:)  + sqrt(-1)*temp(8,:)].';
                    CSEM.by_resp(:,itx,iFreq) = [temp(9,:)  + sqrt(-1)*temp(10,:)].';
                    CSEM.bz_resp(:,itx,iFreq) = [temp(11,:) + sqrt(-1)*temp(12,:)].';
                    
                    CSEM.exp(:,itx,iFreq) = 0*CSEM.ex_resp(:,itx,iFreq); 
                    CSEM.eyp(:,itx,iFreq) = 0*CSEM.ex_resp(:,itx,iFreq); 
                    CSEM.ezp(:,itx,iFreq) = 0*CSEM.ex_resp(:,itx,iFreq); 
                    CSEM.bxp(:,itx,iFreq) = 0*CSEM.ex_resp(:,itx,iFreq); 
                    CSEM.byp(:,itx,iFreq) = 0*CSEM.ex_resp(:,itx,iFreq); 
                    CSEM.bzp(:,itx,iFreq) = 0*CSEM.ex_resp(:,itx,iFreq);  

            end
           
        end
    end
    
    fclose(fid);
   
   % Convert H to B using mu0:
    mu0 = 4*pi*10^-7;
    CSEM.bx_resp  = mu0*CSEM.bx_resp;
    CSEM.by_resp  = mu0*CSEM.by_resp;
    CSEM.bz_resp  = mu0*CSEM.bz_resp;
    CSEM.bxp = mu0*CSEM.bxp;
    CSEM.byp = mu0*CSEM.byp;
    CSEM.bzp = mu0*CSEM.bzp;
  
    % Add in the unused fields:
    CSEM.ex_sd = nan*CSEM.ex_resp;
    CSEM.ey_sd = nan*CSEM.ey_resp;
    CSEM.ez_sd = nan*CSEM.ez_resp;
    CSEM.bx_sd = nan*CSEM.bx_resp;
    CSEM.by_sd = nan*CSEM.by_resp;
    CSEM.bz_sd = nan*CSEM.bz_resp;  
    
    CSEM.ex_data = nan*CSEM.ex_resp;
    CSEM.ey_data = nan*CSEM.ey_resp;
    CSEM.ez_data = nan*CSEM.ez_resp;
    CSEM.bx_data = nan*CSEM.bx_resp;
    CSEM.by_data = nan*CSEM.by_resp;
    CSEM.bz_data = nan*CSEM.bz_resp;  
    
  % Sort the fields in alphabetical order  
  % This is required when the fields are defined in a different order
  % between the readfileMARE2DCSEM and readfileDipole1D. This is a lame
  % Matlab "issue".
  
    CSEM = orderfields(CSEM);    
    