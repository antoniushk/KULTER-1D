function CSEM = getSingleRx(CSEM)
%
%Function to extract single Rx data from CSEM structure
%

    if isempty(CSEM)
        return
    end
    
   
% Ask which Rx to plot:
    for i = 1:CSEM(1).nRx
            s{i} = sprintf('# %i, %6.1f %6.1f %6.1f',i,CSEM(1).xRx(i)/1d3,CSEM(1).yRx(i)/1d3,CSEM(1).zRx(i)/1d3);  %#ok<AGROW>
    end
    index = 1;
    str = sprintf(' Select a receiver to use (#,x,y,z km): ');
     [answer] = listdlg('PromptString',str,...
                      'SelectionMode','single',...
                      'ListString',s,'InitialValue',index,'fus',12,'ffs',12,'uh',32);
    if isempty(answer)
        CSEM = [];
        return
    end
    index = answer(1);
    
% Get the subset of CSEM structure:

    CSEM.nRx = 1;
    CSEM.xRx = CSEM.xRx(index);
    CSEM.yRx = CSEM.yRx(index);
    CSEM.zRx = CSEM.zRx(index);   
    CSEM.ThetaRx = CSEM.ThetaRx(index); 
    CSEM.AlphaRx = CSEM.AlphaRx(index); 
    CSEM.BetaRx  = CSEM.BetaRx(index); 
    
    CSEM.ex_data = CSEM.ex_data(index,:,:);
    CSEM.ey_data = CSEM.ey_data(index,:,:);
    CSEM.ez_data = CSEM.ez_data(index,:,:);
    CSEM.bx_data = CSEM.bx_data(index,:,:);
    CSEM.by_data = CSEM.by_data(index,:,:);
    CSEM.bz_data = CSEM.bz_data(index,:,:);
    
    CSEM.ex_resp = CSEM.ex_resp(index,:,:);
    CSEM.ey_resp = CSEM.ey_resp(index,:,:);
    CSEM.ez_resp = CSEM.ez_resp(index,:,:);
    CSEM.bx_resp = CSEM.bx_resp(index,:,:);
    CSEM.by_resp = CSEM.by_resp(index,:,:);
    CSEM.bz_resp = CSEM.bz_resp(index,:,:);    
    
    CSEM.ex_sd = CSEM.ex_sd(index,:,:);
    CSEM.ey_sd = CSEM.ey_sd(index,:,:);
    CSEM.ez_sd = CSEM.ez_sd(index,:,:);
    CSEM.bx_sd = CSEM.bx_sd(index,:,:);
    CSEM.by_sd = CSEM.by_sd(index,:,:);
    CSEM.bz_sd = CSEM.bz_sd(index,:,:);
