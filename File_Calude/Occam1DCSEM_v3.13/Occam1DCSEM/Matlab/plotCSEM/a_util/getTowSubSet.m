function  CSEM = getTowSubSet(CSEM,towSubset)
%
% Assumes single receiver...
%

    r = sqrt( (CSEM.xTx-CSEM.xRx).^2 + (CSEM.yTx-CSEM.yRx).^2)/1d3;       
    rsign = sign(diff(r));
    rsign = rsign([1 1:end]);

    switch lower(towSubset)
        case 'all'
            return
            
        case 'in'
            ii = rsign < 0;

        case 'out'
            ii = rsign > 0; 
    end

% Take subset:

    CSEM.xTx = CSEM.xTx(ii);
    CSEM.yTx = CSEM.yTx(ii);
    CSEM.zTx = CSEM.zTx(ii);
    CSEM.nTx = length(CSEM.xTx);
    
    CSEM.ex_data = CSEM.ex_data(:,ii,:);
    CSEM.ey_data = CSEM.ey_data(:,ii,:);
    CSEM.ez_data = CSEM.ez_data(:,ii,:);  
    CSEM.bx_data = CSEM.bx_data(:,ii,:);
    CSEM.by_data = CSEM.by_data(:,ii,:);
    CSEM.bz_data = CSEM.bz_data(:,ii,:);  

    CSEM.ex_resp = CSEM.ex_resp(:,ii,:);
    CSEM.ey_resp = CSEM.ey_resp(:,ii,:);
    CSEM.ez_resp = CSEM.ez_resp(:,ii,:);  
    CSEM.bx_resp = CSEM.bx_resp(:,ii,:);
    CSEM.by_resp = CSEM.by_resp(:,ii,:);
    CSEM.bz_resp = CSEM.bz_resp(:,ii,:);  

    CSEM.ex_sd = CSEM.ex_sd(:,ii,:);
    CSEM.ey_sd = CSEM.ey_sd(:,ii,:);
    CSEM.ez_sd = CSEM.ez_sd(:,ii,:);  
    CSEM.bx_sd = CSEM.bx_sd(:,ii,:);
    CSEM.by_sd = CSEM.by_sd(:,ii,:);
    CSEM.bz_sd = CSEM.bz_sd(:,ii,:);  

    