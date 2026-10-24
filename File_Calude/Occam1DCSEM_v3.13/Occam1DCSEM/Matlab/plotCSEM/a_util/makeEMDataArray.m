    
function  DATA =  makeEMDataArray(sCSEM,lCreateSyntheticData,outputComps,dataType,...
                   lomitMinAbs,absNoiseE,relNoiseE, absNoiseB, ...
                   relNoiseB)
%               
% Create the DATA array:
%
% initialize a really large array for handling the data.
% 12 is for 6 complex components.
    DATA = nan*zeros(sCSEM.nFreq*sCSEM.nTx*sCSEM.nRx*12,6);  
    nData = 0;
    
    %
    % Do something special when dataType is pmaxpmin and outputComps
    % contains Ez and Bz.  
    %
    if strcmpi(dataType,'pmaxpmin')  || strcmpi(dataType,'pmax')
        
        newComps = {};
        
        if strmatch('Ex',outputComps)
            newComps{end+1} = 'pEmax';
            if strcmpi(dataType,'pmaxpmin')
                newComps{end+1} = 'pEmin';
            end
        end
        if strmatch('Bx',outputComps)
            newComps{end+1} = 'pBmax';
            if strcmpi(dataType,'pmaxpmin')
                newComps{end+1} = 'pBmin';
            end
        end
        
        % Now we have flags for PE and PB ellipses.  See if user also
        % requested Ez and Bz:
        if strmatch('Ez',outputComps)
            newComps{end+1} = 'Ez';
        end
        if strmatch('Bz',outputComps)
           newComps{end+1} = 'Bz';
        end
        
        % Now update outputComps with new ones:
        outputComps = newComps;
        
        % What about dataType?  Well, one might use pmaxpmin when either
        % the sensor orientation and/or the absolute phase aren't well
        % known, so let's go with amplitude only:
        dataType = 'amp';
        
    end
    
    %
    % Loop over frequencies:
    %
    for iFreq = 1:sCSEM.nFreq
        
        %
        % loop over Tx's
        %
        for iTx = 1:sCSEM.nTx
                
            %
            % Field vector amplitudes:
            %
            if lCreateSyntheticData  % get model response:
                
                ex = sCSEM.ex_resp(:,iTx,iFreq);
                ey = sCSEM.ey_resp(:,iTx,iFreq);
                ez = sCSEM.ez_resp(:,iTx,iFreq);
                
                bx = sCSEM.bx_resp(:,iTx,iFreq);
                by = sCSEM.by_resp(:,iTx,iFreq);
                bz = sCSEM.bz_resp(:,iTx,iFreq);
                
                ex_sd = 0;
                ey_sd = 0;
                ez_sd = 0;
                
                bx_sd = 0;
                by_sd = 0;
                bz_sd = 0;
                
            else % get real data:
                ex = sCSEM.ex_data(:,iTx,iFreq);
                ey = sCSEM.ey_data(:,iTx,iFreq);
                ez = sCSEM.ez_data(:,iTx,iFreq);
                
                bx = sCSEM.bx_data(:,iTx,iFreq);
                by = sCSEM.by_data(:,iTx,iFreq);
                bz = sCSEM.bz_data(:,iTx,iFreq);   
                
                ex_sd = sCSEM.ex_sd(:,iTx,iFreq);
                ey_sd = sCSEM.ey_sd(:,iTx,iFreq);
                ez_sd = sCSEM.ez_sd(:,iTx,iFreq);
                
                bx_sd = sCSEM.bx_sd(:,iTx,iFreq);
                by_sd = sCSEM.by_sd(:,iTx,iFreq);
                bz_sd = sCSEM.bz_sd(:,iTx,iFreq);                    
            end
            
            % Check for nan's:

            ex(isnan(ex)) = 0;
            ey(isnan(ey)) = 0;
            ez(isnan(ez)) = 0;
            bx(isnan(bx)) = 0;
            by(isnan(by)) = 0;
            bz(isnan(bz)) = 0;

            ex_sd(isnan(ex_sd)) = 0;
            ey_sd(isnan(ey_sd)) = 0;
            ez_sd(isnan(ez_sd)) = 0;
            bx_sd(isnan(bx_sd)) = 0;
            by_sd(isnan(by_sd)) = 0;
            bz_sd(isnan(bz_sd)) = 0;  
            
           
            evec_amp =  sqrt( abs(ex).^2 + abs(ey).^2 + abs(ez).^2 ); 
            bvec_amp =  sqrt( abs(bx).^2 + abs(by).^2 + abs(bz).^2 );
            
 
            
            %
            %  Set noisefloors by 0'ing out data where
            %  amplitudes below requested noise floors:   
            %            
            if lomitMinAbs
                ex(evec_amp < absNoiseE(iFreq)) = 0;
                ey(evec_amp < absNoiseE(iFreq)) = 0;
                ez(evec_amp < absNoiseE(iFreq)) = 0;
                
                bx(bvec_amp < absNoiseB(iFreq)) = 0;
                by(bvec_amp < absNoiseB(iFreq)) = 0;
                bz(bvec_amp < absNoiseB(iFreq)) = 0;                
            end
            
          % Get horizontal polarization parameterts for both E and B 
            [ pmaxE pminE alpha] = getPolarizationParams(ex,ey);
            [ pmaxB pminB alpha] = getPolarizationParams(bx,by);           
            
            %
            % Gather the field data for the requested components:
            %

            for iType = 1:length(outputComps)
        
                switch outputComps{iType}
                   
                case ('Ex')  
                    f = ex;
                    relerr = relNoiseE(iFreq);
                    abserr = absNoiseE(iFreq);
                    f_sd = ex_sd;
                    comp = 1;
                    vecamp = evec_amp;
                    
                case('Ey')
                    f = ey;
                    relerr = relNoiseE(iFreq);
                    abserr = absNoiseE(iFreq);
                    f_sd = ey_sd;
                    comp = 3;
                     vecamp = evec_amp;
                case('Ez')
                    f = ez;
                    relerr = relNoiseE(iFreq);
                    abserr = absNoiseE(iFreq);
                    f_sd = ez_sd;
                    comp = 5;
                    vecamp = evec_amp;
                 case ('Bx')  
                    f = bx;
                    relerr = relNoiseB(iFreq);
                    abserr = absNoiseB(iFreq);
                    f_sd = bx_sd;
                    comp = 11;
                    vecamp = bvec_amp;
                case('By')
                    f = by;
                    relerr = relNoiseB(iFreq);
                    abserr = absNoiseB(iFreq);
                    f_sd = by_sd;
                    comp = 13;
                    vecamp = bvec_amp;
                case('Bz')
                    f = bz;
                    relerr = relNoiseB(iFreq);
                    abserr = absNoiseB(iFreq);
                    f_sd = bz_sd;
                    comp = 15;    
                    vecamp = bvec_amp;
                    
                case('pEmax')
                    f = pmaxE;
                    relerr = relNoiseE(iFreq);
                    abserr = absNoiseE(iFreq);
                    f_sd = 0; %hmmm....just use rel and abs error for now..
                    comp = 21;     % pmaxpmin use datatype 'amp', which adds 20 to current type, so use comp = 21, which sets this to 41
                    vecamp = pmaxE;                       
                
                case('pEmin')
                    f = pminE;
                    relerr = relNoiseE(iFreq);
                    abserr = absNoiseE(iFreq);
                    f_sd = 0; %hmmm....just use rel and abs error for now..
                    comp = 22;     % pmaxpmin use datatype 'amp', which adds 20 to current type, so use comp = 21, which sets this to 41
                    vecamp = pmaxE;  % noise floor set on larger pmax amplitude        
                    
                case('pBmax')
                    f = pmaxB;
                    relerr = relNoiseB(iFreq);
                    abserr = absNoiseB(iFreq);
                    f_sd = 0; %hmmm....just use rel and abs error for now..
                    comp = 23;     % pmaxpmin use datatype 'amp', which adds 20 to current type, so use comp = 21, which sets this to 41
                    vecamp = pmaxB;                       
                
                case('pBmin')
                    f = pminB;
                    relerr = relNoiseB(iFreq);
                    abserr = absNoiseB(iFreq);
                    f_sd = 0; %hmmm....just use rel and abs error for now..
                    comp = 24;     % pmaxpmin use datatype 'amp', which adds 20 to current type, so use comp = 21, which sets this to 41
                    vecamp = pmaxB;  % noise floor set on larger pmax amplitude                          
                end
                
               % Transform the complex data to the requested type: 
                [myData myStd myTypes myRx ] = getDataTfm(f,relerr,abserr,f_sd,comp,dataType,vecamp);          
    
              %
              % Generate some random normally distributed noise:
              %
                if lCreateSyntheticData
                    
                    myNoise = randn(size(myData)).*myStd; 
                    myData = (abs(myData)>0).*(myData + myNoise);  % the abs() term keeps the data below noisefloor 0
              
                end
     
                
              %
              % Assemble into the DATA array: 
              %
                 if ~isempty(myData)
                    newData = [];
                    % Now assemble the next bit of the DATA array:
                    newData(:,1) = myTypes;
                    newData(:,2) = iFreq;
                    newData(:,3) = iTx;   
                    newData(:,4) = myRx;  % KWK debug: will need to fix this for omitting noisy bits                  
                    newData(:,5) = myData;
                    newData(:,6) = myStd; 
                    
                    nnewData = length(newData(:,1));
                    DATA(nData+1:nData+nnewData,:) = newData;
                    
                    nData = nData + nnewData;
                 end
                   
            end % iType
            
        end % iTx
        
    end % iFreq
    

%
% Extract data that is above noise floor (data below noise floor has been
% set to 0
%
    inotnoise = DATA(:,5) ~= 0 & isfinite(DATA(:,5)) ;
    DATA = DATA(inotnoise,:);
    
%
% Lastly, reorder the data in x,y,z so that it's ready for the rotation solver, if 
% requested
%
    D2 = nan*zeros(size(DATA)); % pre initialize array for speed

    i1 = find(DATA(:,1) == 1);
    i2 = find(DATA(:,1) == 2);
    i3 = find(DATA(:,1) == 3);
    i4 = find(DATA(:,1) == 4); 
    i5 = find(DATA(:,1) == 5); 
    i6 = find(DATA(:,1) == 6); 
    
    i11 = find(DATA(:,1) == 11);
    i12 = find(DATA(:,1) == 12);
    i13 = find(DATA(:,1) == 13);
    i14 = find(DATA(:,1) == 14);    
    i15 = find(DATA(:,1) == 15);    
    i16 = find(DATA(:,1) == 16);    
    
    nd2 = 0;
    for i = 1:max([ length(i1),length(i3),length(i5)])
        if ~isempty(i1)   
            D2(nd2+1,:)  = DATA(i1(i),:);
            D2(nd2+2,:) = DATA(i2(i),:);
            nd2 = nd2+2;
        end
        if ~isempty(i3)
            D2(nd2+1,:)  = DATA(i3(i),:);
            D2(nd2+2,:) = DATA(i4(i),:);
            nd2 = nd2+2;
        end
        if ~isempty(i5)
            D2(nd2+1,:)  = DATA(i5(i),:);
            D2(nd2+2,:) = DATA(i6(i),:);
            nd2 = nd2+2;
        end
    end
    
   for i = 1:max([ length(i11),length(i13),length(i15)])
        if ~isempty(i11)
            D2(nd2+1,:)  = DATA(i11(i),:);
            D2(nd2+2,:) = DATA(i12(i),:);
            nd2 = nd2+2;
        end
        if ~isempty(i13)
            D2(nd2+1,:)  = DATA(i13(i),:);
            D2(nd2+2,:) = DATA(i14(i),:);
            nd2 = nd2+2;
        end
        if ~isempty(i15)
            D2(nd2+1,:)  = DATA(i15(i),:);
            D2(nd2+2,:) = DATA(i16(i),:);
            nd2 = nd2+2;
        end
   end    
   if any(any(isfinite(D2)))  % D2 could be empty if amplitudes output, then no reordering
        DATA = D2;
        inotnoise = DATA(:,5) ~= 0 & isfinite(DATA(:,5)) ;
        DATA = DATA(inotnoise,:);
   else
       DATA = DATA;
   end
 %------------------------------------------------------------------------ 
 
    function [ pmax pmin alpha] = getPolarizationParams(ex,ey)
     % compute the polarization parameters:
    ax = abs(ex);
    ay = abs(ey);
    px = angle(ex);
    py = angle(ey);
    dp = py-px; 
    alpha = 1/2*atan2(2*ax.*ay.*cos(dp),(ax.^2-ay.^2));
    II = sqrt(-1);
    pmax = abs(ay.*exp(II*dp).*sin(alpha) + ax.*cos(alpha));
    pmin = abs(ay.*exp(II*dp).*cos(alpha) - ax.*sin(alpha));
    
    
  %------------------------------------------------------------------------  
  
    function   [myData myStd myTypes myRx ] = getDataTfm(f,relerr,abserr, ...
                                          f_sd,comp,datatype,vecamp)
                                      
   ii = ones(size(f));
                                       
    switch datatype    
       
        case 'realimag'
            myData  = [real(f); imag(f);];
            myStd   = max(relerr/100.*vecamp,f_sd);
            myStd   = [myStd; myStd]; 
            myTypes = [comp*ii; (comp+1)*ii];

        case 'ampphs'
            myData  = [abs(f); 180/pi*angle(f);];
            myStd   = max(relerr/100.*vecamp,f_sd);
            myStd   = [myStd; myStd/vecamp*180/pi];
            myTypes = [(comp+20)*ii; (comp+21)*ii];                        

        case 'amp'
            myData  = [abs(f)];
            myStd   = max(relerr/100.*vecamp,f_sd);
            myStd   = [myStd];
            myTypes = [(comp+20)*ii];    

        case 'phs'
            myData  = [180/pi*angle(f);];
            myStd   = 180/pi*max(relerr/100.*vecamp,f_sd)/vecamp;
            myTypes = [(comp+21)*ii];             

    end
    
    ii      = ones(size(f));
    myRx    = [ 1:length(ii);];
    if length(myData) > length(myRx)
        myRx = [myRx; myRx];
    end
        
        
        % Make sure absolute floor is obeyed:
        % assumes abserr is always much smaller than phs error, so I can 
        % ignore the fact that this operates on phase uncertainty as
        % well...
          myStd(myStd < abserr) = abserr;


