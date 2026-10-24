function nFields = Dipole1D(nTransmitter,nFreq,nLayers,nReceiver,varargin)
%
%  nFields = Dipole1D(nTransmitter,nFreq,nLayers,nReceiver,varargin)
%
% A Matlab function for computing 1D CSEM responses using the Dipole1D 
% Fortran modeling code.  Uses the Mex file interface mexDipole1D.f90
% written by David Myer.
% 
% This function checks that the inputs are sensible before passing them
% along to mexDipole1D.f90, otherwise Matlab will crash bigtime with a seg
% fault if anything goes wrong during the Fortran call.
%
% Kerry Key
% Scripps Institution of Oceanography
%
% Versions:
%
% 1.1  July 26, 2010  Added some error checks for invalid models      
% 1.0  June 24, 2010  Created
%
%
%
% ! Params:
% !       nTransmitter - array with cols: X, Y, Z, Azimuth, Dip
% !       nFreq        - vector of frequencies
% !       nLayers      - array with cols: TopDepth, Resistivity
% !       nReceiver    - array with cols: X, Y, Z
% !       nTalk        - (optional) 0=say nothing, 1=show fwd calls, 
% !                       2=spew lots of text (default)
% !       bPhaseConv   - (optional) 0=phase lag (dflt), 1=phase lead
% !       nDipoleLen   - (optional; dflt=0) length of dipole in meters centered
% !                       at the transmitter position(s).  0 = point dipole.
% !       numIntegPts - (optional; dflt=10) number of integration points
% !                       for Gauss quadrature integrations for finite dipole computations.
% !
% ! Returns:
% !       nFields     - array with cols: 
% !                       Xmtr #, Freq #, Rcvr #, Ex, Ey, Ez, Bx, By, Bz
% !                     Sorted by columns 1,2,3
% !

% Set the defaults:
    nFields = [];
    nTalk       = 2;
    bPhaseConv  = 0;
    nDipoleLen  = 0;
    numIntegPts = 10;

% Parse inputs:
    if nargin >=5
        nTalk = varargin{1};
    end
    if nargin >=6
        bPhaseConv = varargin{2};
    end
    if nargin >=7
        nDipoleLen = varargin{3};
    end
    if nargin >=8
        numIntegPts = varargin{4};
    end
    
 % Run some error checks on the inputs:
    n = size(nTransmitter,2);
    if n~=5 || ~isnumeric(nTransmitter) 
        Dipole1DErrorMessage('nTransmitter',nTransmitter)        
        return;
    end
    n = size(nLayers,2);
    if n~=2 || ~isnumeric(nLayers) 
        Dipole1DErrorMessage('nLayers',nLayers)
        return;
    end 
    n = size(nReceiver,2);
    if n~=3 || ~isnumeric(nReceiver) 
        Dipole1DErrorMessage('nReceiver',nReceiver)
        return;
    end     
    if numel(nTalk) ~= 1 || ~isnumeric(nTalk)
        Dipole1DErrorMessage('nTalk',nTalk)
        return;   
    end   
    if numel(bPhaseConv) ~= 1 || ~isnumeric(bPhaseConv)
        Dipole1DErrorMessage('bPhaseConv',bPhaseConv)
        return;   
    end          
    if numel(nDipoleLen) ~= 1 || ~isnumeric(nDipoleLen)
        Dipole1DErrorMessage('nDipoleLen',nDipoleLen)
        return;   
    end
    if numel(numIntegPts) ~= 1 || ~isnumeric(numIntegPts)
        Dipole1DErrorMessage('numIntegPts',numIntegPts)
        return;   
    end   
 % Make sure the model has increasing depths:
    if any(diff(nLayers(:,1)) <= 0)
        fprintf('\n Error in Dipole1D.m: \n');
        fprintf(' nLayers is not valid:  \n');
        fprintf(' Depths are not increasing!!! \n');
        fprintf(' Depths        Resistivity \n');
        for i = 1:length(nLayers(:,1))
            fprintf('%12g %12g\n',nLayers(i,:));
        end
        fprintf(' \n');
        return;           
    end
 % Make sure the model has positive resistivity values:    
    if any(nLayers(:,2) <= 0)
        fprintf('\n Error in Dipole1D.m: \n');
        fprintf(' Negative resistivity is not valid:  \n');
        fprintf(' Depths        Resistivity \n');
        for i = 1:length(nLayers(:,1))
            fprintf('%12g %12g\n',nLayers(i,:));
        end
        fprintf(' \n');
        return;           
    end    
    
% We've done out best to make sure the input is reasonable, now let's call
% the mex function for Dipole1D:
 nFields = mexDipole1D(double(nTransmitter),double(nFreq),...
                       double(nLayers),double(nReceiver),...
                        double(nTalk),double(bPhaseConv),...
                        double(nDipoleLen),double(numIntegPts));
                    % note the doubles here in case these are somehow int32
                    % or whatever from bugs on older matlab versions when
                    % an input variable was also an iteration variable
                   

function Dipole1DErrorMessage(param,value)
        beep;
        fprintf('\n Error in Dipole1D.m: \n');
        fprintf(' %s is not valid:  ',param);
        disp(value);
        fprintf(' Try again!\n \n');

