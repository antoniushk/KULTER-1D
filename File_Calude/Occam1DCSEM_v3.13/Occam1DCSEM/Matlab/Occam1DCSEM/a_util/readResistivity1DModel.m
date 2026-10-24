%--------------------------------------------------------------------------    
% function stModel = readResistivity1DModel( sFile )
%
% Function to read in an Occam1DCSEM Model File
% Supports Format: Resistivity1DMod_1.0
%
% Inputs: 
%   sFile - full pathname of data file
%
% Outputs:
%   stModel - a structure containing the model.
%
% Kerry Key
% Scripps Institution of Oceanography
%
% Revisions:        
% 1.1   November 2008       Modified read string to use strtok command.
% 1.0    2008               Created
%-------------------------------------------------------------------------    
function stModel = c( sFile )   
fid = fopen( sFile, 'r' );
        
    % The header of the file consists of a bunch of "code: value" pairs
    % terminated by a pair that tells how many parameters there are (and is
    % immediately followed by the parameter list).
    % Read & process the pairs.
    while ~ feof(fid)
        % Get the current line & break up the code / value pair
        sLine = fgets( fid );
        [sCode, sValue] = strtok( sLine, ':' );
        sCode = lower(strtrim(sCode));
        if ~isempty(sValue)
         sValue(1) = [];     % remove the leading token
        end
        % If there is a user comment in the value, eliminate it.
        sValue = strtrim( strtok(sValue, '!%') );
        
        % Which code do we have?
        switch (sCode)
        case {'format'}
            stModel.sFormat = sValue;
            
        case {'#layers'}
           stModel.nLayers = str2double(sValue);
            
           nLayersReadin = 0;
           
           % Now read in the layers
            while nLayersReadin < stModel.nLayers
                 sLine = fgets( fid );
                 
                 [sLine lComment] = parseLine(sLine);
                 
                 if ~lComment
                     nLayersReadin = nLayersReadin + 1;
                    % stModel.layers(nLayersReadin,1:5) = sscanf(sLine,'%g %g %g %g %g');
                    
                    % new code for handling ? instead of -1 for free
                    % parmeters:
                     [tok, restofSline ] = strtok(sLine);
                     stModel.layers(nLayersReadin,1) = sscanf(tok,'%g');
                     [tok, restofSline ] = strtok(restofSline);
                     if isstrprop(tok,'punct') % its a ? denoting a free parameter:
                        stModel.layers(nLayersReadin,2) = -1;
                     else % its numeric
                        stModel.layers(nLayersReadin,2) =sscanf(tok ,'%g');
                     end
                     stModel.layers(nLayersReadin,3:5) = sscanf(restofSline ,'%g');
                 end
                            
            end
           
        otherwise % ignore other fields since they're not needed for ploting

        end
        
    end


    % Close up & return
    fclose(fid);

    return   
    
