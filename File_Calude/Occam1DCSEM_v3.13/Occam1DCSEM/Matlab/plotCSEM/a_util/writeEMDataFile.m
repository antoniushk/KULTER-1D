% function  writeEMDataFile(outputFileName,CSEM,DATA,comment,phaseConvention) 
%
% Utility function to write out an EMData_1.1 format file used in the
% Occam1DCSEM inverions.
%
% Inputs:
% DipoleLen:   length of transmitter antenna (m), use 0 for point dipole
% xTx,yTx,zTx,azimuthTx,dipTx : vectors of position and angles of transmitters
%
% xRx,yRx,zRx,theta,alpha,beta : vectors of positions and angles of receivers
%
% frequencies : vector of frequencies
%
% DATA :    array of  [TYPE  FREQ#  TX#  RX#  DATA  SD_ERROR]
%
% comment :  any comment text you want near the top of the data file.
%
% phaseConvention  : 'lag' or 'lead'
%
%
% Kerry Key
% Scripps Institution of Oceanography
%
% Revisions:      
% 1.1   February, 2010      Add DipoleLen and format EMData_1.2
% 1.0   December, 2008      Moved to separate file for clarity
% 
%
function  writeEMDataFile(outputFileName,CSEM,DATA,comment,phaseConvention) 

%  
% Create the output Data file:
%

    fid = fopen(outputFileName,'w');
    fprintf(fid,'Format:  EMData_1.2\n');
    
    % Print comment line:
    fprintf(fid,'%s\n', comment);
 
    % Write out the transmitters:'
    if isfield(CSEM,'DipoleLen')
         fprintf(fid,'Dipole Length:   %g\n', CSEM.DipoleLen);
    end
    fprintf(fid,'# Transmitters:   %i\n',length(CSEM.xTx));
    fprintf(fid,'%1s %12s %12s %12s %12s %12s \n','!','X','Y','Z','Azimuth','Dip');
    
    for i = 1:length(CSEM.xTx)
        fprintf(fid,'  %12f %12f %12f %12f %12f \n', CSEM.xTx(i),CSEM.yTx(i),CSEM.zTx(i),CSEM.AzimuthTx(i),CSEM.DipTx(i));
    end

    % Write out the frequencies:
    fprintf(fid,'# Frequencies:    %i\n',length(CSEM.Freq));
    for i = 1:length(CSEM.Freq)
      fprintf(fid,'%12g\n',CSEM.Freq(i));
    end
    fprintf(fid,'Phase Convention: %s\n',phaseConvention);
    % Write out the receivers:
    fprintf(fid,'# Receivers:      %i\n',length(CSEM.xRx));
    fprintf(fid,'%1s %12s %12s %12s %12s %12s %12s\n','!','X','Y','Z','Theta','Alpha','Beta');
    
    for i = 1:length(CSEM.xRx)
         % handle rotation solver flags ('?') in angles:
        if isnumeric(CSEM.ThetaRx(i))
            fmt = '%12g'; % numeric
        else
            fmt = '%12c';  % character:
        end
        st1 = sprintf(fmt,CSEM.ThetaRx(i));
        st2 = sprintf(fmt,CSEM.AlphaRx(i));
        st3 = sprintf(fmt,CSEM.BetaRx(i));             
          
        fprintf(fid,'  %12f %12f %12f %12s %12s %12s \n',CSEM.xRx(i),CSEM.yRx(i),CSEM.zRx(i),st1,st2,st3);
         
    end
    
    
    % Write out the data:
     fprintf(fid,'# Data:       %i\n',length(DATA(:,1)));
     fprintf(fid,'!         Type        Freq#        Tx#           Rx#       Data 	  Std_Error\n');
     fprintf(fid,'%12i %12i %12i %12i %12g %12g \n', DATA');

     
    % Close the file
    fclose(fid);
    