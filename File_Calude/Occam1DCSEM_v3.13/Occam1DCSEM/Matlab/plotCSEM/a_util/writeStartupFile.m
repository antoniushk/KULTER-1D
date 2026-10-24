function writeStartupFile(dataFile,modelFile,misfit,nSeaBedLay,startingRho)
%
% function
% writeStartupFile(dataFile,modelFile,misfit,nSeaBedLay,startingRho)
% 
% Writes out a startup file for Occam's inversion.
%
%

% Open file:
    fid = fopen('startup','w');
    if fid <= 0 
        fprintf('Error creating startup file.\n'); 
        status = -1;
        return
    end


    fprintf(fid,'Format:             OCCAMITER_FLEX\n');
    fprintf(fid,'Description:        \n');
    fprintf(fid,'Model File:         %s\n',modelFile);
    fprintf(fid,'Data File:          %s\n',dataFile);
    fprintf(fid,'Date/Time:          %s\n',datestr(now));       
    fprintf(fid,'Iterations to run:  100 \n');       
    fprintf(fid,'Target Misfit:      %g\n',misfit);       
    fprintf(fid,'Roughness Type:     1 \n');       
    fprintf(fid,'Stepsize Cut Count: 8\n');       
                              
    fprintf(fid,'!Model Limits:       min,max\n');                                          
    fprintf(fid,'!Model Value Steps:  stepsize (e.g. 0.2 or 0.1)\n'); 
    fprintf(fid,'Debug Level:        1\n');
    fprintf(fid,'Iteration:          0\n');       
    fprintf(fid,'Lagrange Value:     5.000000\n');
    fprintf(fid,'Roughness Value:    1.00E+10\n');         
    fprintf(fid,'Misfit Value:       1000.000\n');
    fprintf(fid,'Misfit Reached:     0 \n');
% Write out the parameters
    fprintf(fid,'Param Count:        %i\n',nSeaBedLay); 
    params = ones(nSeaBedLay,1)*startingRho;
    fprintf(fid,'%12g %12g %12g %12g %12g\n',params'); 

% Close the file:
    fclose(fid);
   
  

end

