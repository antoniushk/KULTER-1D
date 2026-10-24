function  CSEM =  readCSEM(file)
%    
% A wrapper function for reading CSEM response files.
%
% Supports Formats:
%
% MARE2DCSEM_2.0
% Dipole1D_1.0, 1.1
% EMData_1.0, 1.1, 1.2
% EMResp_1.0, 1.1, 1.2
% EMGS Processed data (no format is specified in these...).
%
% Note this is outputs B (T/Am) and not H.
%
% Outputs CSEM responses in CSEM structure:
%
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
% You can easily add your own data format and reading kernel so long as it
% uses this format for the structure.  
%
% Note that all ex,bx, etc arrays need to be initialized as [ nRxs by nTx by nFreq]
% and set then to nan's if no data is present. 
%
%
% Copyright 2007,2008
% Kerry Key
% Scripps Institution of Oceanography
% University of California, San Diego
% kkey@ucsd.edu
%
%--------------------------------------------------------------------------  
  % First test to see if it is a processed data file:  
    [ p n e] = fileparts(file);     
    if strcmpi(e,'.mat')
        CSEM = readScrippsProcessedCSEM(file); 
        return
    else % File is output from MARE2DCSEM or Dipole1D codes:
        
        fid     = fopen(file,'r');
        if fid<1
            fprintf('Error reading file: %s',file);
            return
        end    
        format = strtrim(fgets(fid));
        fclose(fid);
        
        % See if its a "sCode:Svalue" expression, if so get the value following it:
         [sCode, sValue] = strtok( format, ':' );
         sCode = lower(strtrim(sCode));
         
        % Test for EMGS File
          if strcmpi(sCode,'job_id')
              CSEM = readEMGS_ProcCSEM(file);
              return
          end
         
         if ~isempty(sValue)
           sValue(1) = [];     % remove the leading token
           format = strtrim(sValue);
         else
           format = strtrim(sCode);
         end
     
        C ={ 'Dipole1D_1.0'  'Dipole1D_1.1' 'MARE2DCSEM_2.0' 'MARE2DCSEM_3.0' ...
             'EMData_1.0' 'EMResp_1.0'  ...
             'EMData_1.1' 'EMResp_1.1' ...
             'EMData_1.2' 'EMResp_1.2'};
        if ~any(strcmpi(format,C)) ; % && ~strcmpi(format,'Dipole1D_1.0')
            beep;
            fprintf('Error in reading file: %s',file);
            fprintf('Unknown File format: %s',format);
            %disp('Only MARE2DCSEM_2.0 and Dipole1D_1.0 are currently supported.');
            return
        end    
    
    % Now read in the entire file:    
        switch lower(format)
            case {'mare2dcsem_2.0','mare2dcsem_3.0'}
                CSEM = readMARE2DCSEM(file);
            case {'dipole1d_1.0','dipole1d_1.1'}
                CSEM = readDipole1DKK(file);
            case {'emdata_1.0', 'emdata_1.1', 'emdata_1.2'}
                CSEM = readEMData(file);
            case {'emresp_1.0', 'emresp_1.1', 'emresp_1.2'}
                CSEM = readEMResp(file);  
        end

    end

