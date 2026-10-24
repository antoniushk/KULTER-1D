%
% sCSEM = rotateSurveyAxes(sCSEM,angle)
%
% rotates survey axes by angle
%--------------------------------------------------------------------------    
    function  CSEM = rotateSurveyAxes(CSEM,angle)
%--------------------------------------------------------------------------
    cc = cosd(angle);
    ss = sind(angle);
    
    % Rotate Tx vector:
    for iTx = 1:CSEM.nTx
        
        xt =  cc*CSEM.xTx(iTx) + ss*CSEM.yTx(iTx);
        yt = -ss*CSEM.xTx(iTx) + cc*CSEM.yTx(iTx);
        
        CSEM.xTx(iTx) = xt;
        CSEM.yTx(iTx) = yt;
    end
    
    % Rotate Tx azimuth angle:
    CSEM.AzimuthTx =  CSEM.AzimuthTx - angle;
      
   % Keep heading within +-360 degrees
    ip =  CSEM.AzimuthTx > 360;
    CSEM.AzimuthTx(ip) =  CSEM.AzimuthTx(ip) - 360;
    ip =  CSEM.AzimuthTx <-360;
    CSEM.AzimuthTx(ip) =  CSEM.AzimuthTx(ip) + 360;    

    % Rotate Rx location vector:
    for iRx = 1:CSEM.nRx
        xt =  cc*CSEM.xRx(iRx) + ss*CSEM.yRx(iRx);
        yt = -ss*CSEM.xRx(iRx) + cc*CSEM.yRx(iRx);
        CSEM.xRx(iRx) = xt;
        CSEM.yRx(iRx) = yt;        
    end
    
    % Rotate Rx theta angle:
    if isnumeric(CSEM.ThetaRx)
        CSEM.ThetaRx = CSEM.ThetaRx - angle;
        ip =  CSEM.ThetaRx > 360;
        CSEM.ThetaRx(ip) =  CSEM.ThetaRx(ip) - 360;
        ip =  CSEM.ThetaRx <-360;
       CSEM.ThetaRx(ip) =  CSEM.ThetaRx(ip) + 360;  
    end

    
 
