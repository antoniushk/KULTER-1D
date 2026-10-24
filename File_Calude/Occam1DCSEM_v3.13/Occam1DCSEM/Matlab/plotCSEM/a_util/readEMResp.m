%--------------------------------------------------------------------------    
% function CSEM = readEMResp( sFile )
%
% Function to read in an EMResp_1.0 - 1.2 format data file output by the new
%  Occam1DCSEM inversion.
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
% CSEM.ex_data, CSEM.ey_data, CSEM.ez_data    [ nRxs by nTx by nFreq] complex data arrays
% CSEM.bx_data, CSEM.by_data, CSEM.bz_data    [ nRxs by nTx by nFreq] complex data arrays
% CSEM.ex_resp, CSEM.ey_resp, CSEM.ez_resp    [ nRxs by nTx by nFreq] complex model response arrays
% CSEM.bx_resp, CSEM.by_resp, CSEM.bz_resp    [ nRxs by nTx by nFreq] complex model response arrays
% CSEM.ex_sd, CSEM.ey_sd, CSEM.ez_sd  Standard errors = nan for forward code
% CSEM.bx_sd, CSEM.by_sd, CSEM.bz_sd  Standard errors = nan for forward code
% CSEM.exp, CSEM.eyp, CSEM.ezp   Primary fields from scattered field comp = nan for 1D code
% CSEM.bxp, CSEM.byp, CSEM.bzp   Primary fields from scattered field comp = nan for 1D code
%
% Notes on Real/Imag and Amplitude and Phase:
%   The fields output in the CSEM structure are stored as complex numbers.
%   If the data contains only amplitude data, it is converted into the real
%   part of the complex number and the phase is set to 0. Otherwise,
%   amplitude and phase data are converted into complex number.
%
%
% Kerry Key
% Scripps Institution of Oceanography
%
% Revisions:  
% 1.2    February, 2010  Added in support for EMResp_1.2 (DipoleLen)
% 1.1    December, 2008  Added in support for EMResp_1.1
% 1.0    December, 2008  Created
%
%------------------------------------------------------------------------- 
    function CSEM = readEMResp( sFile )
 
    CSEM.DipoleLen   = 0; % initialize to point dipole
    
    fid = fopen( sFile, 'r' );
        
    % The header of the file consists of a bunch of "code: value" pairs
    % terminated by a pair that tells how many parameters there are (and is
    % immediately followed by the parameter list).
    % Read & process the pairs.
    while ~ feof(fid)
        
        % set Filename:
        CSEM.filename = sFile;
        % Get the current line & break up the code / value pair
        sLine = fgets( fid );
        [sCode, sValue] = strtok( sLine, ':' );
        sCode = lower(strtrim(sCode));
        if ~isempty(sValue)
         sValue(1) = [];     % remove the leading token
        end
        % If there is a user comment in the value, eliminate it.
        sValue = strtrim( strtok(sValue, '%%') );
        
        % Which code do we have?
        switch (sCode)
        case {'format'}
            sFormat = sValue;
        
        case{'dipole length','dipole','dipolelength'}
            CSEM.DipoleLen = str2double(sValue);
            
        case {'# transmitters','#transmitters'}
           CSEM.nTx = str2double(sValue);
            
           nTxReadin = 0;
           
           % Now read in the transmitters:
            while nTxReadin < CSEM.nTx
                 sLine = fgets( fid );
                 
                 [sLine lComment] = parseLine(sLine);
                 
                 if ~lComment
                     nTxReadin = nTxReadin + 1;
                     % read in x,y,z,azimuth,dip
                    temp = sscanf(sLine,'%g %g %g %g %g');
                    CSEM.xTx(nTxReadin) = temp(1);
                    CSEM.yTx(nTxReadin) = temp(2);
                    CSEM.zTx(nTxReadin) = temp(3);
                    CSEM.AzimuthTx(nTxReadin)  = temp(4);
                    CSEM.DipTx(nTxReadin)  = temp(5);
                    
                 end
                            
            end
            
        case {'# frequencies','#frequencies'}
            CSEM.nFreq = str2double(sValue);

            nFreqReadin = 0;
            CSEM.Freq =[];
            % Now read in the frequencies:
            while nFreqReadin < CSEM.nFreq
                 sLine = fgets( fid );

                 [sLine lComment] = parseLine(sLine);

                 if ~lComment
                     temp = sscanf(sLine,'%g');
                     nFreqReadin = nFreqReadin + length(temp);
                     % 
                     CSEM.Freq(end+1:nFreqReadin) = temp;
                 end

            end     
            % make sure its a column vector:
            if size(CSEM.Freq,2) > 1
                CSEM.Freq = CSEM.Freq';
            end
            

        case {'# receivers','#receivers'}
            CSEM.nRx= str2double(sValue);

            nRxReadin = 0;

            % Now read in the frequencies:
            while nRxReadin < CSEM.nRx
                 sLine = fgets( fid );

                 [sLine lComment] = parseLine(sLine);

                 if ~lComment
                    switch lower(strtrim(sFormat))
                        
                         case {'emresp_1.0'}
                            temp = sscanf(sLine,'%g',3);
                            nRxReadin = nRxReadin + 1;
                            % 
                            CSEM.xRx(nRxReadin) = temp(1);
                            CSEM.yRx(nRxReadin) = temp(2);
                            CSEM.zRx(nRxReadin) = temp(3);
                            % rotations in another section for 1.0
                            
                         case {'emresp_1.1','emresp_1.2'}
                            temp = sscanf(sLine,'%g',3);
                            nRxReadin = nRxReadin + 1;
                            % 
                            CSEM.xRx(nRxReadin) = temp(1);
                            CSEM.yRx(nRxReadin) = temp(2);
                            CSEM.zRx(nRxReadin) = temp(3);  

                            % initialize to nan's
                            CSEM.ThetaRx(nRxReadin) = nan;
                            CSEM.AlphaRx(nRxReadin) = nan;
                            CSEM.BetaRx(nRxReadin)  = nan;                            
                            [ t r] = strtok(sLine);
                            [ t r] = strtok(r);
                            [ t r] = strtok(r);
                            [ t r] = strtok(r);
                            val = sscanf(t,'%g');
                            if ~isempty(val)
                                CSEM.ThetaRx(nRxReadin) = val;
                            end
                            [ t r] = strtok(r);
                            val = sscanf(t,'%g');
                            if ~isempty(val)
                                CSEM.AlphaRx(nRxReadin) = val;
                            end
                            [ t r] = strtok(r);
                            val = sscanf(t,'%g');
                            if ~isempty(val)
                                CSEM.BetaRx(nRxReadin) = val;
                            end
                            
                        otherwise
                            fprintf('error: unknown format: %s',sFormat)
                            return
                     end
                                          
                 end
                 

            end       

        case {'# data','#data'}
            
            % First allocate the data arrays:
            CSEM.ex_data = zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
            CSEM.ey_data = CSEM.ex_data;
            CSEM.ez_data = CSEM.ex_data; 
            CSEM.bx_data = CSEM.ex_data;
            CSEM.by_data = CSEM.ex_data;
            CSEM.bz_data = CSEM.ex_data;

            CSEM.ex_resp = zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
            CSEM.ey_resp = CSEM.ex_data;
            CSEM.ez_resp = CSEM.ex_data; 
            CSEM.bx_resp = CSEM.ex_data;
            CSEM.by_resp = CSEM.ex_data;
            CSEM.bz_resp = CSEM.ex_data;
 
            
            CSEM.ex_sd = CSEM.ex_data;
            CSEM.ey_sd = CSEM.ex_data;
            CSEM.ez_sd = CSEM.ex_data;
            CSEM.bx_sd = CSEM.ex_data;
            CSEM.by_sd = CSEM.ex_data;
            CSEM.bz_sd = CSEM.ex_data;          
            
            nData= str2double(sValue);

            nDataReadin = 0;

            % Now read in the frequencies:
            while nDataReadin < nData
                 sLine = fgets( fid );

                 [sLine lComment] = parseLine(sLine);

                 if ~lComment
                     
                     nDataReadin = nDataReadin + 1;
                     
                     % Decode the line and fill in the data array:
                     CSEM = decodeDataLine(sLine,CSEM);
                     
                 end

            end       
            
            otherwise % ignore other fields since they're not needed for ploting

        end
        
    end


    % Close up & return
    fclose(fid);
    
    % Create some dummy arrays:
    CSEM.exp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.eyp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.ezp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bxp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.byp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bzp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);

    % Nan the data and resp arrays where amplitude is 0:
    CSEM.ex_data( abs(CSEM.ex_data)==0 ) = nan;
    CSEM.ey_data( abs(CSEM.ey_data)==0 ) = nan;
    CSEM.ez_data( abs(CSEM.ez_data)==0 ) = nan;
    CSEM.bx_data( abs(CSEM.bx_data)==0 ) = nan;
    CSEM.by_data( abs(CSEM.by_data)==0 ) = nan;
    CSEM.bz_data( abs(CSEM.bz_data)==0 ) = nan;            
    CSEM.ex_resp( abs(CSEM.ex_resp)==0 ) = nan;
    CSEM.ey_resp( abs(CSEM.ey_resp)==0 ) = nan;
    CSEM.ez_resp( abs(CSEM.ez_resp)==0 ) = nan;
    CSEM.bx_resp( abs(CSEM.bx_resp)==0 ) = nan;
    CSEM.by_resp( abs(CSEM.by_resp)==0 ) = nan;
    CSEM.bz_resp( abs(CSEM.bz_resp)==0 ) = nan;          
  % Sort the fields in alphabetical order  
    CSEM = orderfields(CSEM);
    
    return   
    
%--------------------------------------------------------------------------    
    function CSEM = decodeDataLine(sLine,CSEM)
% this code is my lamest code ever.     
        
    [tok, restofSline ] = strtok(sLine);
    temp =  sscanf(restofSline ,'%g');
     
    iFreq = temp(1);
    iTx = temp(2);
    iRx = temp(3);
    datum = temp(4);
    std_dataev = temp(5);
    resp = temp(6);
    residual = temp(7);


        
% This format is compatible with 2D and 3D CSEM modeling.
% 
%   CSEM Electric Data, Real/Imag:
% 	  indRealEx = 1;
% 	  indImagEx = 2;
% 	  indRealEy = 3;
% 	  indImagEy = 4;
% 	  indRealEz = 5;
% 	  indImagEz = 6;
% 
% 	
% %	CSEM Magnetic Data, Real/Imag:
% 	  indRealBx = 11;
% 	  indImagBx = 12;
% 	  indRealBy = 13;
% 	  indImagBy = 14;
% 	  indRealBz = 15;
% 	  indImagBz = 16;
% 	
% %   CSEM Electric Data, Amp/Phs:
% 	  indAmpEx = 21;
% 	  indPhsEx = 22;
% 	  indAmpEy = 23;
% 	  indPhsEy = 24;
% 	  indAmpEz = 25;
% 	  indPhsEz = 26;
% 
% 	
% %	CSEM Magnetic Data, Amp/Phs:
% 	  indAmpBx = 31;
% 	  indPhsBx = 32;
% 	  indAmpBy = 33;
% 	  indPhsBy = 34;
% 	  indAmpBz = 35;
% 	  indPhsBz = 36;
% 
% % To do: polarization ellipses, E/H transfer functions, etc
% 
% %	
% % Magnetotelluric Data:  
% %
% % This format is compatible with 2D and 3D MT modeling codes.
% %
% % 	Apparent Resistivity and Phase:
% 	  indRhoZXX  = 101;   % not used for 1D
% 	  indPhsZXX  = 102;   % not used for 1D
% 	  indRhoZXY  = 103;   % 
% 	  indPhsZXY  = 104;   %	
% 	  indRhoZYX  = 105;   %
% 	  indPhsZYX  = 106;   % 
% 	  indRhoZYY  = 107;   % not used for 1D
% 	  indPhsZYY  = 108;   % not used for 1D
% 	
% %   Impedances:	
% 	  indRealZXX  = 111;   % not used for 1D
% 	  indImagZXX  = 112;   % not used for 1D
% 	  indRealZXY  = 113;   % 
% 	  indImagZXY  = 114;   %	
% 	  indRealZYX  = 115;   %
% 	  indImagZYX  = 116;   % 
% 	  indRealZYY  = 117;   % not used for 1D
% 	  indImagZYY  = 118;   % not used for 1D	
      
% Given a data code character string, return the numeric value:
        switch (lower(tok))
	
		% Electric Real/Imag Data:
		case {'1','realex','reex'}
			CSEM.ex_data(iRx,iTx,iFreq) = CSEM.ex_data(iRx,iTx,iFreq) + datum;
            CSEM.ex_resp(iRx,iTx,iFreq) = CSEM.ex_resp(iRx,iTx,iFreq) + resp;
            CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev;
		case {'2','imagex','imex','imaginaryex'}
		    CSEM.ex_data(iRx,iTx,iFreq) = CSEM.ex_data(iRx,iTx,iFreq) + sqrt(-1)*datum;
            CSEM.ex_resp(iRx,iTx,iFreq) = CSEM.ex_resp(iRx,iTx,iFreq) + sqrt(-1)*resp;
            CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev;
		case {'3','realey','reey'}
			CSEM.ey_data(iRx,iTx,iFreq) = CSEM.ey_data(iRx,iTx,iFreq) + datum;
            CSEM.ey_resp(iRx,iTx,iFreq) = CSEM.ey_resp(iRx,iTx,iFreq) + resp;
            CSEM.ey_sd(iRx,iTx,iFreq) = std_dataev;
		case {'4','imagey','imey','imaginaryey'}
			CSEM.ey_data(iRx,iTx,iFreq) = CSEM.ey_data(iRx,iTx,iFreq) + sqrt(-1)*datum;
            CSEM.ey_resp(iRx,iTx,iFreq) = CSEM.ey_resp(iRx,iTx,iFreq) + sqrt(-1)*resp;
            CSEM.ey_sd(iRx,iTx,iFreq) = std_dataev;
		case {'5','realez','reez'}
			CSEM.ez_data(iRx,iTx,iFreq) = CSEM.ez_data(iRx,iTx,iFreq) + datum;
            CSEM.ez_resp(iRx,iTx,iFreq) = CSEM.ez_resp(iRx,iTx,iFreq) + resp;
            CSEM.ez_sd(iRx,iTx,iFreq) = std_dataev;
		case {'6','imagez','imez','imaginaryez'}	
			CSEM.ez_data(iRx,iTx,iFreq) = CSEM.ez_data(iRx,iTx,iFreq) + sqrt(-1)*datum;
            CSEM.ez_resp(iRx,iTx,iFreq) = CSEM.ez_resp(iRx,iTx,iFreq) + sqrt(-1)*resp;
            CSEM.ez_sd(iRx,iTx,iFreq) = std_dataev;
		
		% Magnetic Real/Imag Data:
		case {'11','realbx','rebx'}
			CSEM.bx_data(iRx,iTx,iFreq) = CSEM.bx_data(iRx,iTx,iFreq) + datum;
            CSEM.bx_resp(iRx,iTx,iFreq) = CSEM.bx_resp(iRx,iTx,iFreq) + resp;
            CSEM.bx_sd(iRx,iTx,iFreq) = std_dataev;
		case {'12','imagbx','imbx','imaginarybx'}
			CSEM.bx_data(iRx,iTx,iFreq) = CSEM.bx_data(iRx,iTx,iFreq) + sqrt(-1)*datum;
            CSEM.bx_resp(iRx,iTx,iFreq) = CSEM.bx_resp(iRx,iTx,iFreq) + sqrt(-1)*resp;
            CSEM.bx_sd(iRx,iTx,iFreq) = std_dataev;
		case {'13','realby','reby'}
			CSEM.by_data(iRx,iTx,iFreq) = CSEM.by_data(iRx,iTx,iFreq) + datum;
            CSEM.by_resp(iRx,iTx,iFreq) = CSEM.by_resp(iRx,iTx,iFreq) + resp;
            CSEM.by_sd(iRx,iTx,iFreq) = std_dataev;
		case {'14','imagby','imby','imaginaryby'}
			CSEM.by_data(iRx,iTx,iFreq) = CSEM.by_data(iRx,iTx,iFreq) + sqrt(-1)*datum;
            CSEM.by_resp(iRx,iTx,iFreq) = CSEM.by_resp(iRx,iTx,iFreq) + sqrt(-1)*resp;
            CSEM.by_sd(iRx,iTx,iFreq) = std_dataev;	
		case {'15','realbz','rebz'}
			CSEM.bz_data(iRx,iTx,iFreq) = CSEM.bz_data(iRx,iTx,iFreq) + datum;
            CSEM.bz_resp(iRx,iTx,iFreq) = CSEM.bz_resp(iRx,iTx,iFreq) + resp;
            CSEM.bz_sd(iRx,iTx,iFreq) = std_dataev;
		case {'16','imagbz','imbz','imaginarybz'}	
			CSEM.bz_data(iRx,iTx,iFreq) = CSEM.bz_data(iRx,iTx,iFreq) + sqrt(-1)*datum;
            CSEM.bz_resp(iRx,iTx,iFreq) = CSEM.bz_resp(iRx,iTx,iFreq) + sqrt(-1)*resp;
            CSEM.bz_sd(iRx,iTx,iFreq) = std_dataev;	
		
		% Electric Amplitude and Phase Data:
		case {'21','ampex','amplitudeex'}
            if abs(CSEM.ex_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.ex_data(iRx,iTx,iFreq) = CSEM.ex_data(iRx,iTx,iFreq) + datum;
                CSEM.ex_resp(iRx,iTx,iFreq) = CSEM.ex_resp(iRx,iTx,iFreq) + resp;
                CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); exp(i*phi) already set, so just mult amp:
                 CSEM.ex_data(iRx,iTx,iFreq) = CSEM.ex_data(iRx,iTx,iFreq)*datum;
                 CSEM.ex_resp(iRx,iTx,iFreq) = CSEM.ex_resp(iRx,iTx,iFreq)*resp;
                 CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev;
            end
		case {'22','phsex','phaseex'}
            datum = exp(sqrt(-1)*pi/180*datum);
            resp = exp(sqrt(-1)*pi/180*resp);
            std_dataev = std_dataev*pi/180;
            if abs(CSEM.ex_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.ex_data(iRx,iTx,iFreq) = CSEM.ex_data(iRx,iTx,iFreq) + datum;
                CSEM.ex_resp(iRx,iTx,iFreq) = CSEM.ex_resp(iRx,iTx,iFreq) + resp;
                CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); R already set, so just mult exp(i*phi):
                 CSEM.ex_data(iRx,iTx,iFreq) = CSEM.ex_data(iRx,iTx,iFreq)*datum;
                 CSEM.ex_resp(iRx,iTx,iFreq) = CSEM.ex_resp(iRx,iTx,iFreq)*resp;
                 %CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev; % using std_dev from amplitude
            end
		case {'23','ampey','amplitudeey'}
            if abs(CSEM.ey_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.ey_data(iRx,iTx,iFreq) = CSEM.ey_data(iRx,iTx,iFreq) + datum;
                CSEM.ey_resp(iRx,iTx,iFreq) = CSEM.ey_resp(iRx,iTx,iFreq) + resp;
                CSEM.ey_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); exp(i*phi) already set, so just mult amp:
                 CSEM.ey_data(iRx,iTx,iFreq) = CSEM.ey_data(iRx,iTx,iFreq)*datum;
                 CSEM.ey_resp(iRx,iTx,iFreq) = CSEM.ey_resp(iRx,iTx,iFreq)*resp;
                 CSEM.ey_sd(iRx,iTx,iFreq) = std_dataev;
            end
		case {'24','phsey','phaseey'}
            datum = exp(sqrt(-1)*pi/180*datum);
            resp = exp(sqrt(-1)*pi/180*resp);
            std_dataev = std_dataev*pi/180;
            if abs(CSEM.ey_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.ey_data(iRx,iTx,iFreq) = CSEM.ey_data(iRx,iTx,iFreq) + datum;
                CSEM.ey_resp(iRx,iTx,iFreq) = CSEM.ey_resp(iRx,iTx,iFreq) + resp;
                CSEM.ey_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); R already set, so just mult exp(i*phi):
                 CSEM.ey_data(iRx,iTx,iFreq) = CSEM.ey_data(iRx,iTx,iFreq)*datum;
                 CSEM.ey_resp(iRx,iTx,iFreq) = CSEM.ey_resp(iRx,iTx,iFreq)*resp;
                 %CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev; % using std_dev from amplitude
            end
		case {'25','ampez','amplitudeez'}
            if abs(CSEM.ez_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.ez_data(iRx,iTx,iFreq) = CSEM.ez_data(iRx,iTx,iFreq) + datum;
                CSEM.ez_resp(iRx,iTx,iFreq) = CSEM.ez_resp(iRx,iTx,iFreq) + resp;
                CSEM.ez_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); exp(i*phi) already set, so just mult amp:
                 CSEM.ez_data(iRx,iTx,iFreq) = CSEM.ez_data(iRx,iTx,iFreq)*datum;
                 CSEM.ez_resp(iRx,iTx,iFreq) = CSEM.ez_resp(iRx,iTx,iFreq)*resp;
                 CSEM.ez_sd(iRx,iTx,iFreq) = std_dataev;
            end			
		case {'26','phsez','phaseez'}
            datum = exp(sqrt(-1)*pi/180*datum);
            resp = exp(sqrt(-1)*pi/180*resp);
            std_dataev = std_dataev*pi/180;
            if abs(CSEM.ez_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.ez_data(iRx,iTx,iFreq) = CSEM.ez_data(iRx,iTx,iFreq) + datum;
                CSEM.ez_resp(iRx,iTx,iFreq) = CSEM.ez_resp(iRx,iTx,iFreq) + resp;
                CSEM.ez_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); R already set, so just mult exp(i*phi):
                 CSEM.ez_data(iRx,iTx,iFreq) = CSEM.ez_data(iRx,iTx,iFreq)*datum;
                 CSEM.ez_resp(iRx,iTx,iFreq) = CSEM.ez_resp(iRx,iTx,iFreq)*resp;
                 %CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev; % using std_dev from amplitude
            end	
		% LOG10 Electric Amplitude Data:
		case {'27','log10ampex','log10amplitudeex'}
            if abs(CSEM.ex_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.ex_data(iRx,iTx,iFreq) = CSEM.ex_data(iRx,iTx,iFreq) + 10.^datum;
                CSEM.ex_resp(iRx,iTx,iFreq) = CSEM.ex_resp(iRx,iTx,iFreq) + 10.^resp;
                CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev*0.10/.04343*CSEM.ex_data(iRx,iTx,iFreq);
            else % z = R exp(i* phi); exp(i*phi) already set, so just mult amp:
                 CSEM.ex_data(iRx,iTx,iFreq) = CSEM.ex_data(iRx,iTx,iFreq)*10.^datum;
                 CSEM.ex_resp(iRx,iTx,iFreq) = CSEM.ex_resp(iRx,iTx,iFreq)*10.^resp;
                 CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev*0.10/.04343*CSEM.ex_data(iRx,iTx,iFreq);
            end
		case {'28','log10ampey','log10amplitudeey'}
            if abs(CSEM.ey_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.ey_data(iRx,iTx,iFreq) = CSEM.ey_data(iRx,iTx,iFreq) + 10.^datum;
                CSEM.ey_resp(iRx,iTx,iFreq) = CSEM.ey_resp(iRx,iTx,iFreq) + 10.^resp;
                CSEM.ey_sd(iRx,iTx,iFreq) = std_dataev*0.10/.04343*CSEM.ey_data(iRx,iTx,iFreq);
            else % z = R exp(i* phi); exp(i*phi) already set, so just mult amp:
                 CSEM.ey_data(iRx,iTx,iFreq) = CSEM.ey_data(iRx,iTx,iFreq)*10.^datum;
                 CSEM.ey_resp(iRx,iTx,iFreq) = CSEM.ey_resp(iRx,iTx,iFreq)*10.^resp;
                 CSEM.ey_sd(iRx,iTx,iFreq) = std_dataev*0.10/.04343*CSEM.ey_data(iRx,iTx,iFreq);
            end
		case {'29','log10ampez','log10amplitudeez'}
            if abs(CSEM.ez_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.ez_data(iRx,iTx,iFreq) = CSEM.ez_data(iRx,iTx,iFreq) + 10.^datum;
                CSEM.ez_resp(iRx,iTx,iFreq) = CSEM.ez_resp(iRx,iTx,iFreq) + 10.^resp;
                CSEM.ez_sd(iRx,iTx,iFreq) = std_dataev*0.10/.04343*CSEM.ez_data(iRx,iTx,iFreq);
            else % z = R exp(i* phi); exp(i*phi) already set, so just mult amp:
                 CSEM.ez_data(iRx,iTx,iFreq) = CSEM.ez_data(iRx,iTx,iFreq)*10.^datum;
                 CSEM.ez_resp(iRx,iTx,iFreq) = CSEM.ez_resp(iRx,iTx,iFreq)*10.^resp;
                 CSEM.ez_sd(iRx,iTx,iFreq) = std_dataev*0.10/.04343*CSEM.ez_data(iRx,iTx,iFreq);
            end            
            
		% Magnetic Amplitude and Phase Data:
		case {'31','ampbx','amplitudebx'}
            if abs(CSEM.bx_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.bx_data(iRx,iTx,iFreq) = CSEM.bx_data(iRx,iTx,iFreq) + datum;
                CSEM.bx_resp(iRx,iTx,iFreq) = CSEM.bx_resp(iRx,iTx,iFreq) + resp;
                CSEM.bx_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); exp(i*phi) already set, so just mult amp:
                 CSEM.bx_data(iRx,iTx,iFreq) = CSEM.bx_data(iRx,iTx,iFreq)*datum;
                 CSEM.bx_resp(iRx,iTx,iFreq) = CSEM.bx_resp(iRx,iTx,iFreq)*resp;
                 CSEM.bx_sd(iRx,iTx,iFreq) = std_dataev;
            end		
		case {'32','phsbx','phasebx'}
            datum = exp(sqrt(-1)*pi/180*datum);
            resp = exp(sqrt(-1)*pi/180*resp);
            std_dataev = std_dataev*pi/180;
            if abs(CSEM.bx_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.bx_data(iRx,iTx,iFreq) = CSEM.bx_data(iRx,iTx,iFreq) + datum;
                CSEM.bx_resp(iRx,iTx,iFreq) = CSEM.bx_resp(iRx,iTx,iFreq) + resp;
                CSEM.bx_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); R already set, so just mult exp(i*phi):
                 CSEM.bx_data(iRx,iTx,iFreq) = CSEM.bx_data(iRx,iTx,iFreq)*datum;
                 CSEM.bx_resp(iRx,iTx,iFreq) = CSEM.bx_resp(iRx,iTx,iFreq)*resp;
                 %CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev; % using std_dev from amplitude
            end
		case {'33','ampby','amplitudeby'}
            if abs(CSEM.by_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.by_data(iRx,iTx,iFreq) = CSEM.by_data(iRx,iTx,iFreq) + datum;
                CSEM.by_resp(iRx,iTx,iFreq) = CSEM.by_resp(iRx,iTx,iFreq) + resp;
                CSEM.by_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); exp(i*phi) already set, so just mult amp:
                 CSEM.by_data(iRx,iTx,iFreq) = CSEM.by_data(iRx,iTx,iFreq)*datum;
                 CSEM.by_resp(iRx,iTx,iFreq) = CSEM.by_resp(iRx,iTx,iFreq)*resp;
                 CSEM.by_sd(iRx,iTx,iFreq) = std_dataev;
            end
		case {'34','phsby','phaseby'}
            datum = exp(sqrt(-1)*pi/180*datum);
            resp = exp(sqrt(-1)*pi/180*resp);
            std_dataev = std_dataev*pi/180;
            if abs(CSEM.by_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.by_data(iRx,iTx,iFreq) = CSEM.by_data(iRx,iTx,iFreq) + datum;
                CSEM.by_resp(iRx,iTx,iFreq) = CSEM.by_resp(iRx,iTx,iFreq) + resp;
                CSEM.by_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); R already set, so just mult exp(i*phi):
                 CSEM.by_data(iRx,iTx,iFreq) = CSEM.by_data(iRx,iTx,iFreq)*datum;
                 CSEM.by_resp(iRx,iTx,iFreq) = CSEM.by_resp(iRx,iTx,iFreq)*resp;
                 %CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev; % using std_dev from amplitude
            end
		case {'35','ampbz','amplitudebz'}
            if abs(CSEM.bz_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.bz_data(iRx,iTx,iFreq) = CSEM.bz_data(iRx,iTx,iFreq) + datum;
                CSEM.bz_resp(iRx,iTx,iFreq) = CSEM.bz_resp(iRx,iTx,iFreq) + resp;
                CSEM.bz_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); exp(i*phi) already set, so just mult amp:
                 CSEM.bz_data(iRx,iTx,iFreq) = CSEM.bz_data(iRx,iTx,iFreq)*datum;
                 CSEM.bz_resp(iRx,iTx,iFreq) = CSEM.bz_resp(iRx,iTx,iFreq)*resp;
                 CSEM.bz_sd(iRx,iTx,iFreq) = std_dataev;
            end			
		case {'36','phsbz','phasebz'}
	        datum = exp(sqrt(-1)*pi/180*datum);
            resp = exp(sqrt(-1)*pi/180*resp);
            std_dataev = std_dataev*pi/180;
            if abs(CSEM.bz_data(iRx,iTx,iFreq) ) == 0  % no part of complex datum set yet:
                CSEM.bz_data(iRx,iTx,iFreq) = CSEM.bz_data(iRx,iTx,iFreq) + datum;
                CSEM.bz_resp(iRx,iTx,iFreq) = CSEM.bz_resp(iRx,iTx,iFreq) + resp;
                CSEM.bz_sd(iRx,iTx,iFreq) = std_dataev;
            else % z = R exp(i* phi); R already set, so just mult exp(i*phi):
                 CSEM.bz_data(iRx,iTx,iFreq) = CSEM.bz_data(iRx,iTx,iFreq)*datum;
                 CSEM.bz_resp(iRx,iTx,iFreq) = CSEM.bz_resp(iRx,iTx,iFreq)*resp;
                 %CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev; % using std_dev from amplitude
            end	
          
        case {'41','pemax'}
            CSEM.ex_data(iRx,iTx,iFreq) = datum;  % stored this in ex as amplitude only
            CSEM.ex_resp(iRx,iTx,iFreq) = resp;  % stored this in ex as amplitude only
            CSEM.ex_sd(iRx,iTx,iFreq) = std_dataev;  % stored this in ex as amplitude only
        
        case {'42','pemin'}
            CSEM.ey_data(iRx,iTx,iFreq) = datum;  % stored this in ey as amplitude only
            CSEM.ey_resp(iRx,iTx,iFreq) = resp;  % stored this in ey as amplitude only
            CSEM.ey_sd(iRx,iTx,iFreq) = std_dataev;  % stored this in ey as amplitude only         
       
        case {'43','pbmax'}
            CSEM.bx_data(iRx,iTx,iFreq) = datum;  % stored this in bx as amplitude only
            CSEM.bx_resp(iRx,iTx,iFreq) = resp;  % stored this in bx as amplitude only
            CSEM.bx_sd(iRx,iTx,iFreq) = std_dataev;  % stored this in bx as amplitude only
        
        case {'44','pbmin'}
            CSEM.by_data(iRx,iTx,iFreq) = datum;  % stored this in by as amplitude only
            CSEM.by_resp(iRx,iTx,iFreq) = resp;  % stored this in by as amplitude only
            CSEM.by_sd(iRx,iTx,iFreq) = std_dataev;  % stored this in by as amplitude only     
                        
	%	
	% Magnetotelluric Data:
	%
      % Real/Imag
% 		case {'realzxx'}    		% ignored in 1D
% 			code = indRealZXX;	
% 		case {'imagzxx'}	% ignored in 1D
% 			code = indImagZXX;		
% 		case {'realzxy'}
% 			code = indRealZXY;	
% 		case {'imagzxy'}
% 			code = indImagZXY;		
% 		case {'realzyx'} 
% 			code = indRealZYX;	
% 		case {'imagzyx'} 
% 			code = indImagZYX;			
% 		case {'realzyy'}	
% 			code = indRealZYY;	
% 		case {'imagzyy'}	
% 			code = indImagZYY;					
% 		
% 		% Apparent resistivity and phase:
% 		case {'rhozxx'}    		
% 			code = indRhoZXX;	
% 		case {'phszxx'}		
% 			code = indPhsZXX;		
% 		case {'rhozxy'}   		
% 			code = indRhoZXY;	
% 		case {'phszxy'}		
% 			code = indPhsZXY;		
% 		case {'rhozyx'}    		
% 			code = indRhoZYX;	
% 		case {'phszyx'}		
% 			code = indPhsZYX;		
% 		case {'rhozyy'}    		
% 			code = indRhoZYY;	
% 		case {'phszyy'}		
% 			code = indPhsZYY;		
				
		
		% Error if unknown type:
		otherwise
			%fprintf(' Error decoding data type: %s', sField);
            fprintf(' Ignoring data type: %s\n', tok);
        end
    return

%--------------------------------------------------------------------------
    
