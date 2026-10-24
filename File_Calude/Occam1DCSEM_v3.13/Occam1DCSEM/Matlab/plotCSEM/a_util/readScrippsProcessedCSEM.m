
function CSEM = readScrippsProcessedCSEM(sFile)


% Load in the file:
    try
        load(sFile)
    catch
        fprintf('Error opening file: %s',sFile)
        return
    end
    
    % set Filename:
    CSEM.filename = sFile;     
    
% Move into the CSEM structure arrays:
  
    CSEM.nTx       = size(stCSEM.nTF, 1);
    CSEM.xTx       = stCSEM.nAnt(:, stCSEM.colAnt.N);
    CSEM.yTx       = stCSEM.nAnt(:, stCSEM.colAnt.E);
    CSEM.zTx       = stCSEM.nAnt(:, stCSEM.colAnt.Z);
    CSEM.AzimuthTx = stCSEM.nAnt(:, stCSEM.colAnt.COG);
    CSEM.DipTx     = stCSEM.nAnt(:, stCSEM.colAnt.Dip);
    
    % CSEM.DipoleLen = 
    
    % Frequencies:
    CSEM.nFreq = size(stCSEM.nTF, 3);
    CSEM.Freq = stCfg.nFreqList';
   
    % Site locations:
    CSEM.nRx = 1;
    CSEM.xRx = stCfg.nSiteN;
    CSEM.yRx = stCfg.nSiteE;
    CSEM.zRx = stCfg.nSiteZ;
  
    
    % initialize data arrays:
    CSEM.ex_data = zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.ey_data = CSEM.ex_data;
    CSEM.ez_data = CSEM.ex_data; 
    CSEM.bx_data = CSEM.ex_data;
    CSEM.by_data = CSEM.ex_data;
    CSEM.bz_data = CSEM.ex_data;

    CSEM.ex_sd = CSEM.ex_data;
    CSEM.ey_sd = CSEM.ex_data;
    CSEM.ez_sd = CSEM.ex_data;
    CSEM.bx_sd = CSEM.ex_data;
    CSEM.by_sd = CSEM.ex_data;
    CSEM.bz_sd = CSEM.ex_data;          

    
    % Get channel IDs:
   % mu0 = 4*pi*10^-7;
    for i = 1:length( stSPChan)
      switch  lower(stSPChan(i).sType)
          case 'hx'
               CSEM.bx_data(1,:,:) =  stCSEM.nTF(:,i,:);
               xDir = stSPChan(i).nOrient;
          case 'hy'
               CSEM.by_data(1,:,:) = stCSEM.nTF(:,i,:);
          case 'ex'
               CSEM.ex_data(1,:,:) = stCSEM.nTF(:,i,:);
          case 'ey'
               CSEM.ey_data(1,:,:) = stCSEM.nTF(:,i,:);
          case 'ez'
               CSEM.ez_data(1,:,:) = stCSEM.nTF(:,i,:);
      end  
    end
     
    % Orientation angles, fixed for now kwk debug kludge!
    CSEM.ThetaRx = xDir;
    CSEM.AlphaRx = 0;
    CSEM.BetaRx  = 0;

    % take conj to put into phase lag form:
     CSEM.ex_data = conj(CSEM.ex_data);
     CSEM.ey_data = conj(CSEM.ey_data);
     CSEM.ez_data = conj(CSEM.ez_data);   % SIO Ez convention is + up, so change to + down...
     CSEM.bx_data = conj(CSEM.bx_data);
     CSEM.by_data = conj(CSEM.by_data);
     CSEM.bz_data = conj(CSEM.bz_data);       

% Clean out any nans

    inan = isnan(CSEM.xTx) | isnan(CSEM.yTx) | isnan(CSEM.zTx);
    CSEM.xTx(inan) = [];
    CSEM.yTx(inan) = [];
    CSEM.zTx(inan) = [];
    CSEM.AzimuthTx(inan) = [];
    CSEM.DipTx(inan) = [];
    CSEM.nTx = length(CSEM.xTx);
    
    CSEM.bx_data(:,inan,:) = [];
    CSEM.by_data(:,inan,:) = [];
    CSEM.bz_data(:,inan,:) = [];
    CSEM.ex_data(:,inan,:) = [];
    CSEM.ey_data(:,inan,:) = [];
    CSEM.ez_data(:,inan,:) = [];
    CSEM.bx_sd(:,inan,:) = [];
    CSEM.by_sd(:,inan,:) = [];
    CSEM.bz_sd(:,inan,:) = [];
    CSEM.ex_sd(:,inan,:) = [];
    CSEM.ey_sd(:,inan,:) = [];
    CSEM.ez_sd(:,inan,:) = []; 
 
% CSEM.ex_data, CSEM.ey_data, CSEM.ez_data    [ nRxs by nTx by nFreq] complex data arrays = nan for forward code
% CSEM.bx_data, CSEM.by_data, CSEM.bz_data    [ nRxs by nTx by nFreq] complex data arrays = nan for forward code
% CSEM.ex_resp, CSEM.ey_resp, CSEM.ez_resp    [ nRxs by nTx by nFreq] complex model response arrays
% CSEM.bx_resp, CSEM.by_resp, CSEM.bz_resp    [ nRxs by nTx by nFreq] complex model response arrays
% CSEM.ex_sd, CSEM.ey_sd, CSEM.ez_sd  Standard errors = nan for forward code
% CSEM.bx_sd, CSEM.by_sd, CSEM.bz_sd  Standard errors = nan for forward code
% CSEM.exp, CSEM.eyp, CSEM.ezp   Primary fields from scattered field comp = nan for 1D code
% CSEM.bxp, CSEM.byp, CSEM.bzp   Primary fields from scattered field comp = nan for 1D code
%
    



    
    % Create some dummy arrays:
    CSEM.exp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.eyp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.ezp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bxp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.byp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bzp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);

     % Create some dummy arrays:
    CSEM.ex_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.ey_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.ez_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bx_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.by_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bz_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq); 
            
    % Nan the data arrays where amplitude is 0:
    CSEM.ex_data( abs(CSEM.ex_data)==0 ) = nan;
    CSEM.ey_data( abs(CSEM.ey_data)==0 ) = nan;
    CSEM.ez_data( abs(CSEM.ez_data)==0 ) = nan;
    CSEM.bx_data( abs(CSEM.bx_data)==0 ) = nan;
    CSEM.by_data( abs(CSEM.by_data)==0 ) = nan;
    CSEM.bz_data( abs(CSEM.bz_data)==0 ) = nan;
    
  % Sort the fields in alphabetical order  
    CSEM = orderfields(CSEM);
    
    return   
    
