function [nFields, nXmtr, nFreq, nModel, nRcvr, nDipLen] = readDipole1D( sFile, nXAngle )
%
% Companion function to fileDipole1D and less convenient replacement for
% mexDipole1D (when you can't get the MatLab fortran interface compiled).
%
% Reads a file output by Dipole1D. Unfortunately, these files are not formatted
% very well, so there are just numbers with no text verifying what they are.
% Messy.
%
% David Myer
%
% Params:
%   sFile   - path + name of the file output by Dipole1D
%   nXAngle - (optional) compass angle (degrees) of the X (north) component of 
%           each receiver. If given, data are rotated. If not, data are not.
%           If given as a scalar, the angle is applied to all receivers.
% Returns:
%   nFields - 9 columns: Xmtr #, Freq #, Rcvr #, Ex, Ey, Ez, Bx, By, Bz
%               Sorted by columns 1, 2, 3
%   nXmtr   - 5 columns: X, Y, Z, Azimuth, Dip
%   nFreq   - 1 column
%   nModel  - 2 columns: depth, linear rho
%   nRcvr   - 3 columns: X, Y, Z
%   nDipLen - scalar - length of dipole. 0 = point dipole.
%-------------------------------------------------------------------------------
% See also fileDipole1D, mexDipole1D

    fid = fopen( sFile, 'r' );
    fgetl(fid); % skip format line
    
    nDipLen = str2num(fgetl(fid));  % dipole length
    
    n = str2num(fgetl(fid)); % # xmtrs
    nXmtr = fscanf( fid, '%g', [5 n] );
    fgetl(fid);              % get final line ending (MatLab doesn't strip this in fscanf)
    nXmtr = nXmtr.';
    
    n = str2num(fgetl(fid)); % # freqs
    nFreq = fscanf( fid, '%g', n );
    fgetl(fid);              % get final line ending (MatLab doesn't strip this in fscanf)
    nFreq = reshape( nFreq, n, 1 );
    
    n = str2num(fgetl(fid)); % # model layers
    nModel = fscanf( fid, '%g', [2 n] );
    fgetl(fid);              % get final line ending (MatLab doesn't strip this in fscanf)
    nModel = nModel.';
    
    n = str2num(fgetl(fid)); % # receivers
    nRcvr = fscanf( fid, '%g', [3 n] );
    fgetl(fid);              % get final line ending (MatLab doesn't strip this in fscanf)
    nRcvr = nRcvr.';
    
    nData = fscanf(fid, '%g', [12, Inf] );
    fclose(fid);
    
    % For convenience, setup nXAngle if not already setup.
	if ~exist( 'nXAngle', 'var' ) || isempty( nXAngle )
        nXAngle = zeros(size(nRcvr,1),1);
    elseif numel(nXAngle) == 1
        nXAngle = zeros(size(nRcvr,1),1) + nXAngle;
    end
    
    % Fields are in order by: Xmtr, Freq, Rcvr
    % Add ordering columns (to be just like mexDipole1D) and convert the two 
    %   separate real & imag numbers into complex #s.
    % Start at the right-most so that nFields is fully allocated by the first
    % assignment. It's faster this way.
    nData = nData.';
    j = 9;
    for i = 11:-2:1 
        nFields(:,j) = complex( nData(:,i), nData(:,i+1) );
        j = j - 1;
    end
    
    i = 1;
    for iTx = 1:size(nXmtr,1)
        for iFreq = 1:size(nFreq,1)
            for iRx = 1:size(nRcvr,1)
                nFields(i,1:3) = [iTx iFreq iRx];
    
                % Perform rotations if requested.
                if nXAngle(iRx) ~= 0
                    R = [cosd(nXAngle(iRx)) sind(nXAngle(iRx))
                        -sind(nXAngle(iRx)) cosd(nXAngle(iRx))];
                    nFields(i,4:5) = nFields(i,4:5) * R;
                    nFields(i,7:8) = nFields(i,7:8) * R;
                end
                
                i = i + 1;
            end
        end
    end
    
    return
end
