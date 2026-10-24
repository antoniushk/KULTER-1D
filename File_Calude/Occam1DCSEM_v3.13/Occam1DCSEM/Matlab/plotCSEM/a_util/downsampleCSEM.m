function CSEM = downsampleCSEM(CSEM,decimation)
% Function to downsample CSEM data in structure CSEM by an integer factor
% only works for single site CSEM structure...
%

    CSEM.ex_data = CSEM.ex_data(:,1:decimation:end,:);
    CSEM.ey_data = CSEM.ey_data(:,1:decimation:end,:);
    CSEM.ez_data = CSEM.ez_data(:,1:decimation:end,:);
    CSEM.bx_data = CSEM.bx_data(:,1:decimation:end,:);
    CSEM.by_data = CSEM.by_data(:,1:decimation:end,:);
    CSEM.bz_data = CSEM.bz_data(:,1:decimation:end,:); 
    CSEM.ex_sd = CSEM.ex_sd(:,1:decimation:end,:);
    CSEM.ey_sd = CSEM.ey_sd(:,1:decimation:end,:);
    CSEM.ez_sd = CSEM.ez_sd(:,1:decimation:end,:);
    CSEM.bx_sd = CSEM.bx_sd(:,1:decimation:end,:);
    CSEM.by_sd = CSEM.by_sd(:,1:decimation:end,:);
    CSEM.bz_sd = CSEM.bz_sd(:,1:decimation:end,:);        
    CSEM.ex_resp = CSEM.ex_resp(:,1:decimation:end,:);
    CSEM.ey_resp = CSEM.ey_resp(:,1:decimation:end,:);
    CSEM.ez_resp = CSEM.ez_resp(:,1:decimation:end,:);
    CSEM.bx_resp = CSEM.bx_resp(:,1:decimation:end,:);
    CSEM.by_resp = CSEM.by_resp(:,1:decimation:end,:);
    CSEM.bz_resp = CSEM.bz_resp(:,1:decimation:end,:);        

    CSEM.nTx = length(CSEM.ex_data(1,:,1));
    CSEM.xTx = CSEM.xTx(1:decimation:end);
    CSEM.yTx = CSEM.yTx(1:decimation:end);
    CSEM.zTx = CSEM.zTx(1:decimation:end);
    CSEM.AzimuthTx = CSEM.AzimuthTx(1:decimation:end);
    CSEM.DipTx = CSEM.DipTx(1:decimation:end);
    