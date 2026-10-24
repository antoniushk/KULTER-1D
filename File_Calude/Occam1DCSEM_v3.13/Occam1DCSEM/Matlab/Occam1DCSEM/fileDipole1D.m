function fileDipole1D( sFile, nXmtr, nFreq, nModel, nRcvr, bPhaseConv, nDipLen, nNumIntegPts )
% fileDipole1D( sFile, nXmtr, nFreq, nModel, nRcvr, bPhaseConv, nDipLen, nNumIntegPts )
% 
% Companion function to mexDipole1D for when the mex compilation doesn't work
% and you need to make an input file for dipole1D. Usage:
%
% fileDipole1D( sFile, ...) % sets up the file
% ... run Dipole1D with the name of your file as the input
% [] = readDipole1D( sFile )% get the output from dipole1D
% 
% David Myer
%
% Params:
%       sFile     - path+filename to create & fill.
%       nXmtr     - array with cols: X, Y, Z, Azimuth, Dip
%       nFreq     - vector of frequencies
%       nModel    - array with cols: TopDepth, Resistivity (linear, NOT log)
%       nRcvr     - array with cols: X, Y, Z
%       bPhaseConv   - (optional) 0=phase lag (dflt), 1=phase lead
%       nDipLen   - (optional; dflt=0) length of dipole in meters centered
%                    at the transmitter position(s).  Zero = point dipole.
%       nNumIntegPts - (optional; dflt=10) number of integration points to
%                       use along nDipLen in gaussian quadrature
%                       integration.
%-------------------------------------------------------------------------------
% See also readDipole1D, mexDipole1D

    fid = fopen( sFile, 'w' );  % open & obliterate existing file.
    fprintf( fid, 'Version: FlexFormat\n' );
    
    if exist( 'nDipLen', 'var' ) && ~isempty( nDipLen ) && nDipLen > 0
        fprintf( fid, 'Dipole Length: %f\n', nDipLen );
        
        if exist( 'nNumIntegPts', 'var' ) && ~isempty( nNumIntegPts ) && nNumIntegPts > 0
            fprintf( fid, '# Integration Points: %d\n', round( nNumIntegPts ) );
        end
    end
    
    if exist( 'bPhaseConv', 'var' ) && ~isempty( bPhaseConv ) && bPhaseConv
        fprintf( fid, 'Phase Convention: lead\n' );
    end
    
    fprintf( fid, '# Transmitters: %d\nX Y Z Azimuth Dip\n', size(nXmtr,1) );
    fprintf( fid, '%d %d %d %d %d\n', round( nXmtr(:,1:5).' ) );
    
    fprintf( fid, '# Frequencies: %d\n', numel(nFreq) );
    fprintf( fid, '%f\n', nFreq );
    
    fprintf( fid, '# Receivers: %d\n', size(nRcvr,1) );
    fprintf( fid, '%d %d %d\n', round( nRcvr(:,1:3).' ) );
    
    fprintf( fid, '# Layers: %d\n', size(nModel,1) );
    for i = 1:size(nModel,1)
        fprintf( fid, '%d %f\n', round(nModel(i,1)), nModel(i,2) );
    end
    
    fclose(fid);
    
    return
end
