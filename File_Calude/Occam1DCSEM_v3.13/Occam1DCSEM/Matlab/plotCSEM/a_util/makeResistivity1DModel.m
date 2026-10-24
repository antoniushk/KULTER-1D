%
%
% function makeResistivity1DModel(filename,oceanDepth,seaZ,seaRho,...
%                                nSeaBedLay,maxDepth,zScale)
%
% function to create a Resistivity1DMod_1.0 format model file for 1D Marine 
% CSEM inversions.
%
%
% oceanDepth - depth of entire seawater column,and the top of the first free
%              parameter layer
%
% seaZ      - depth,resistivity of seawater column. seaZ(1) needs to be 0;
% seaRho      but these can be column vectors of stratified conductivity
%             obtained from CTD or XBT data.
%
%
% nSeaBedLay - number of layers to create below the seabed
%
% maxDepth  - depth to the top of the deepest layer
%
% zScale  - depth scale to use for creating seabed layer thicknesses
%           Options:'uniform', 'log'
%
%
% Kerry Key
% Scripps Institution of Oceanography
% University of California, San Diego
% kkey@ucsd.edu
%
function makeResistivity1DModel(filename,oceanDepth,seaZ,seaRho,...
                                nSeaBedLay,maxDepth,zScale)

% Create air:
    zsea(1) = -100d3;  % air
    rsea(1) = 1d12;

% Add sea layer(s):    
    zsea = [zsea; seaZ];  % sea level
    rsea = [ rsea; seaRho];
    
% Create seabed layers:
    switch lower(zScale)
        case 'uniform'
            z = linspace(oceanDepth,maxDepth, nSeaBedLay);
        case {'log','logarithmic'}
            z = logspace(log10(oceanDepth),log10(maxDepth), nSeaBedLay);
    end
    r = z*0 - 1; % make vector of -1's
    

    Model(:,1) = [zsea; z(:)];
    Model(:,2) = [rsea; r(:)];
    
    Model(:,3) = 1;
    Model(1:length(zsea)+1,3) = 0;  % +1 is for top of first seabed layer. 
    Model(:,4) = 0; % pref penalty
    Model(:,5) = 0; % pref penalty

% Write Model File:

% Open file:
    fid = fopen(filename,'w');
    if fid <= 0 
        fprintf('Error creating model file: %s\n',filename); 
        status = -1;
        return
    end

% Format:
  fprintf(fid,'Format:     Resistivity1DMod_1.0\n');
  
% Num Layers:
 nlay = length(Model(:,1));
 fprintf(fid,'#Layers:    %i\n',nlay);
    
% Comments with column labels:
    fprintf(fid,'! top_depth 	resistivity  penalty	preference   pref_penalty\n');

% Write out the array:
  fprintf(fid,'%12g %12g %12g %12g %12g\n',Model'); 

% Close the file:
   fclose(fid);
   
  

end

    
