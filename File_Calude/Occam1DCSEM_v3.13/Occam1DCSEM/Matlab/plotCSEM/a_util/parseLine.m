%--------------------------------------------------------------------------    
function  [sLine lComment] = parseLine(sLine)
%--------------------------------------------------------------------------  
%
% Function to identify whether a line is a comment or not.
% Also strips off comments at end of a line of data.
%
% Kerry Key
% Scripps Institution of Oceanography
%
%-------------------------------------------------------------------------
    lComment = false;
    
    for iFrom = 1:length(sLine)
        if ~strcmp(sLine(iFrom),' ')
            break 
        end
    end
    
    % Test to see if line is a comment
    if iFrom > length(sLine) || strcmp(sLine(iFrom),'%') || strcmp(sLine(iFrom),'!')
        lComment = true;
        return
    end
    
    % Trim off any comments at the end:
    iTo = length(sLine);
    iFrom = strfind(sLine,'%');
    if ~isempty(iFrom) && iFrom(1) < iTo
        sLine(iFrom:iTo) = '';
    end
     iTo = length(sLine);
    iFrom = strfind(sLine,'!');
    if ~isempty(iFrom) && iFrom(1) < iTo
        sLine(iFrom:iTo) = '';
    end   
    
    % finally, convert an 1d12 type numbers to 1e12:
    sLine = strrep(sLine,'d','e');
    
    