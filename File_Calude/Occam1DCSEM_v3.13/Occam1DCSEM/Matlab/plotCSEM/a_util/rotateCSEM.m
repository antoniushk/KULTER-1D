%  function  sCSEM = rotateCSEM(sCSEM,theta,alpha,beta) 
% 
% 
% Rotates CSEM model or data responses in sCSEM structure by 3D rotation angles.
% For now uses the same angles for all receivers in the structure.
% 
% KWK: what about data uncertainties...
%
%--------------------------------------------------------------------------    
    function  sCSEM = rotateCSEM(sCSEM,theta,alpha,beta)   
%--------------------------------------------------------------------------

    for iRx = 1:sCSEM.nRx

         cc = cosd(theta);
         ss = sind(theta);
         Rz = [cc -ss  0 ; ss  cc 0; 0 0 1 ];

         cc = cosd(alpha);
         ss = sind(alpha);
         Ry = [cc 0 -ss; 0 1 0; ss 0 cc ];

         cc = cosd(beta);
         ss = sind(beta);
         Rx = [1 0 0;  0 cc -ss; 0 ss  cc ];

         R = Rz*Ry*Rx;

         for iFreq = 1:sCSEM.nFreq

            % loop over Tx's
            for iTx = 1:sCSEM.nTx
 
                exr = sCSEM.ex_resp(iRx,iTx,iFreq);
                eyr = sCSEM.ey_resp(iRx,iTx,iFreq);
                ezr = sCSEM.ez_resp(iRx,iTx,iFreq);

                bxr = sCSEM.bx_resp(iRx,iTx,iFreq);
                byr = sCSEM.by_resp(iRx,iTx,iFreq);
                bzr = sCSEM.bz_resp(iRx,iTx,iFreq);

                exd = sCSEM.ex_data(iRx,iTx,iFreq);
                eyd = sCSEM.ey_data(iRx,iTx,iFreq);
                ezd = sCSEM.ez_data(iRx,iTx,iFreq);

                bxd = sCSEM.bx_data(iRx,iTx,iFreq);
                byd = sCSEM.by_data(iRx,iTx,iFreq);
                bzd = sCSEM.bz_data(iRx,iTx,iFreq);   
                
                % Model responses
                Er = [ exr eyr ezr ];
                Br = [ bxr byr bzr ];
                Er(isnan(Er)) = 0;
                Br(isnan(Br)) = 0;
                
                A = Er*R;
                exr = A(1);
                eyr = A(2);
                ezr = A(3);

                A = Br*R;
                bxr = A(1);
                byr = A(2);
                bzr = A(3);

                % Data:
                Ed = [ exd eyd ezd ];
                Bd = [ bxd byd bzd ];
                Ed(isnan(Ed)) = 0;
                Bd(isnan(Bd)) = 0;
                
                A = Ed*R;
                exd = A(1);
                eyd = A(2);
                ezd = A(3);

                A = Bd*R;
                bxd = A(1);
                byd = A(2);
                bzd = A(3);



                sCSEM.ex_resp(iRx,iTx,iFreq) = exr;
                sCSEM.ey_resp(iRx,iTx,iFreq) = eyr;
                sCSEM.ez_resp(iRx,iTx,iFreq) = ezr;

                sCSEM.bx_resp(iRx,iTx,iFreq) = bxr;
                sCSEM.by_resp(iRx,iTx,iFreq) = byr;
                sCSEM.bz_resp(iRx,iTx,iFreq) = bzr;


                sCSEM.ex_data(iRx,iTx,iFreq) = exd;
                sCSEM.ey_data(iRx,iTx,iFreq) = eyd;
                sCSEM.ez_data(iRx,iTx,iFreq) = ezd;

                sCSEM.bx_data(iRx,iTx,iFreq) = bxd;
                sCSEM.by_data(iRx,iTx,iFreq) = byd;
                sCSEM.bz_data(iRx,iTx,iFreq) = bzd;

            end
         end
    end 

