%--------------------------------------------------------------------------    
% function [stIter] = readOccamIteration( sFile )
%
% readOccamIteration - read & parse an Occam iteration file.
%
% v1.0, July 2001 by: Kerry Key IGPP/SIO/UCSD
% v2.0, Nov 2006 by David Myer - rewritten to support new OCCAMITER_FLEX
% format files which have new entries for diagonal penalties, and roughness
% modification.  And which no longer require entries to be in a particular
% order.
%
% Parameters:
%   sFile   - path+name of iteration file to open.
% Returns:
%   stIter  - structure with members for each of the header items.  See code
%           for a list of possible members.  Structure will only have members
%           for the items that exist in the iteration file.  So not all
%           members will be present every time.
% 
%--------------------------------------------------------------------------
    function [stIter] = readOccamIteration( sFile )
    % Open the iteration file
    fid = fopen( sFile, 'r' );
    
    if fid < 1
        fprintf('Error opening file: %s\n',sFile);
        beep
        return
    end
    
    % Default a value or two that should always exist.
    stIter.nMisfit      = 1000.0;
    stIter.nRoughness   = 0.0;
    
    % The header of the file consists of a bunch of "code: value" pairs
    % terminated by a pair that tells how many parameters there are (and is
    % immediately followed by the parameter list).
    % Read & process the pairs.
    while ~ feof(fid)
        % Get the current line & break up the code / value pair
        sLine = fgets( fid );
        [sCode, sValue] = strtok( sLine, ':' );
        sCode = lower(strtrim(sCode));
        sValue(1) = [];     % remove the leading token
        
        % If there is a user comment in the value, eliminate it.
        sValue = strtrim( strtok(sValue, '!%') );
        
        % Which code do we have?
        switch (sCode)
        case {'format'}
            stIter.sFormat = sValue;
            
        case {'description'}
            stIter.sDesc = sValue;
            
        case {'model file'}
            stIter.sModelFile = sValue;
            
        case {'data file'}
            stIter.sDataFile = sValue;
            
        case {'date/time'}
            stIter.sDateTime = sValue;
            
        case {'max iter', 'iterations to run'}
            stIter.nIterToRun = str2double( sValue );
            
        case {'req tol', 'target misfit'}
            stIter.nTargetMisfit = str2double( sValue );
            
        case {'iruf', 'roughness type'}
            stIter.nRoughnessType = str2double( sValue );
            stIter.bDiagPenalties = (stIter.nRoughnessType < 0);
            stIter.nRoughnessType = abs( stIter.nRoughnessType );
            % KWK March 2010: RoughnessType may now be a string
            stIter.sRoughString	  = sValue;
            
        case {'diagonal penalties'}
            stIter.bDiagPenalties = (str2double( sValue ) ~= 0);
            if isfield( stIter, 'nRoughnessType' )
                stIter.nRoughnessType = abs( stIter.nRoughnessType );
            end
            
        case {'debug level'}
            stIter.DebugLevel = str2double( sValue );
            
        case {'iteration'}
            stIter.nIteration = str2double( sValue );
            
        case {'pmu', 'lagrange value'}
            stIter.nLagrange = str2double( sValue );
            
        case {'rlast', 'roughness value'}
            stIter.nRoughness = str2double( sValue );
            
        case {'tlast', 'misfit value'}
            stIter.nMisfit = str2double( sValue );
            
        case {'ifftol', 'misfit reached'}
            stIter.bReachedMisfit = (str2double( sValue ) ~= 0);
            
        case {'modify roughness'}
            stIter.sModifyRoughness = sValue;
            
        case {'no. parms', 'param count'}
            stIter.nNumParams = str2double( sValue );
            break;	% The next thing in the file is the data param list!
            
            otherwise % do nothing
                
%         case default
%             disp( 'Error reading startup/iteration file!' );
%             error( ['Unknown or unsupported code: ' sCode] );
            
        end
        
    end
    if feof(fid) 
        error( ['Error: iteration file ' sFile ' terminated early!'] );
    end
    
    % Read the parameters
    stIter.nParams = fscanf( fid, '%f', stIter.nNumParams );
    
    % Close up & return
    fclose(fid);

    return
