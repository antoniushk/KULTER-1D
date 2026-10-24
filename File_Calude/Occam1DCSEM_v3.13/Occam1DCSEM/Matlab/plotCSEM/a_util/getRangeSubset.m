function  CSEM = getRangeSubset(CSEM,minRange,maxRange )
%
% Assumes single receiver...
%
% min,maxRange given for each frequency in CSEM
% Doesn't shrink arrays, just nan's data outside range window for each
% frequency

    r = sqrt( (CSEM.xTx-CSEM.xRx).^2 + (CSEM.yTx-CSEM.yRx).^2)/1d3;       
   
    for i = 1:length(minRange)
        ii = r < minRange(i) | r > maxRange(i);


    % Take subset:

%         CSEM.xTx = CSEM.xTx(ii);
%         CSEM.yTx = CSEM.yTx(ii);
%         CSEM.zTx = CSEM.zTx(ii);
%         CSEM.nTx = length(CSEM.xTx);

        CSEM.ex_data(:,ii,i) = nan;
        CSEM.ey_data(:,ii,i) = nan;
        CSEM.ez_data(:,ii,i) = nan;  
        CSEM.bx_data(:,ii,i) = nan;
        CSEM.by_data(:,ii,i) = nan;
        CSEM.bz_data(:,ii,i) = nan;  

        CSEM.ex_resp(:,ii,i) = nan;
        CSEM.ey_resp(:,ii,i) = nan;
        CSEM.ez_resp(:,ii,i) = nan;  
        CSEM.bx_resp(:,ii,i) = nan;
        CSEM.by_resp(:,ii,i) = nan;
        CSEM.bz_resp(:,ii,i) = nan;  

        CSEM.ex_sd(:,ii,i) = nan;
        CSEM.ey_sd(:,ii,i) = nan;
        CSEM.ez_sd(:,ii,i) = nan;  
        CSEM.bx_sd(:,ii,i) = nan;
        CSEM.by_sd(:,ii,i) = nan;
        CSEM.bz_sd(:,ii,i) = nan;  
    end
    