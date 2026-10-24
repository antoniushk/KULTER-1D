% Note: KKey has created Dipole1D.m as training wheels for mexDipole1D. If you have
% difficulties getting the params right, you might try that.
%
% ! nFields = mexDipole1D( nXmtr, nFreq, nModel, nRcvr, nTalk, bPhaseConv, nDipLen, nNumIntegPts )
% ! 
% ! MatLab interface for Kerry Key's Dipole 1D CSEM forward model code.
% !
% ! David Myer
% ! Copyright 2009
% ! Scripps Institution of Oceanography
% ! dmyer@ucsd.edu
% !
% ! This function ('mexDipole1D' in MatLab, NOT 'MEXFUNCTION') definition:
% ! Params:
% !       nXmtr     - array with cols: X, Y, Z, Azimuth, Dip
% !       nFreq     - vector of frequencies
% !       nModel    - array with cols: TopDepth, Resistivity
% !       nRcvr     - array with cols: X, Y, Z
% !       nTalk     - (optional) 0=say nothing, 1=show fwd calls, 
% !                    2=spew lots of text (default)
% !       bPhaseConv   - (optional) 0=phase lag (dflt), 1=phase lead
% !       nDipLen   - (optional; dflt=0) length of dipole in meters centered
% !                    at the transmitter position(s).  Zero = point dipole.
% !       nNumIntegPts - (optional; dflt=10) number of integration points to
% !                       use along nDipLen in gaussian quadrature
% !                       integration.
% ! Returns:
% !       nFields   - cols: Xmtr #, Freq #, Rcvr #, Ex, Ey, Ez, Bx, By, Bz
% !                     Sorted by columns 1,2,3
% !
% See also Dipole1D, fileDipole1D, readDipole1D
