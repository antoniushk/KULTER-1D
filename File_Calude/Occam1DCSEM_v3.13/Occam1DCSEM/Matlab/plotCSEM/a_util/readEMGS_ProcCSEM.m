function CSEM = readEMGS_ProcCSEM(sFile)
%
% Function to read in an EMGS processed data file.  Sorta kludgey for now.
%
% I've only tested it on a file with this header for the data columns:
%
% Offset	Ex1-Mag	Ex1-Pha	Ex2-Mag	Ex2-Pha	Ey1-Mag	Ey1-Pha Ey2-Mag	Ey2-Pha	Hx1-Mag	Hx1-Pha	Hy1-Mag	Hy1-Pha	x	y	z	wd	hd	
%
% So it might crash if you give it a 9 component file (Exyz,Exyz2,Bxyz)
%
% Also plotCSEM.m isn't set up to handle the duplicate E channels so I hae
% a dialog window pop up to ask which ones to plot...
%
% Outputs CSEM responses in CSEM structure:
%
% CSEM.filename  
% CSEM.nTx
% CSEM.xTx, CSEM.yTx, CSEM.zTx, CSEM.AzimuthTx, CSEM.DipTx
% CSEM.nRx
% CSEM.xRx, CSEM.yRx, CSEM.zRx
% CSEM.ThetaRx,CSEM.AlphaRx, CSEM.BetaRx   Orientation angles for Rx
% CSEM.nFreq
% CSEM.Freq
% CSEM.ex_data, CSEM.ey_data, CSEM.ez_data    [ nRxs by nTx by nFreq] complex data arrays
% CSEM.bx_data, CSEM.by_data, CSEM.bz_data    [ nRxs by nTx by nFreq] complex data arrays
% CSEM.ex_resp, CSEM.ey_resp, CSEM.ez_resp    [ nRxs by nTx by nFreq] complex model response arrays
% CSEM.bx_resp, CSEM.by_resp, CSEM.bz_resp    [ nRxs by nTx by nFreq] complex model response arrays
% CSEM.ex_sd, CSEM.ey_sd, CSEM.ez_sd  Standard errors = nan for forward code
% CSEM.bx_sd, CSEM.by_sd, CSEM.bz_sd  Standard errors = nan for forward code
% CSEM.exp, CSEM.eyp, CSEM.ezp   Primary fields from scattered field comp = nan for 1D code
% CSEM.bxp, CSEM.byp, CSEM.bzp   Primary fields from scattered field comp = nan for 1D code
%

    fid = fopen( sFile, 'r' );
    if fid <= 0
        beep;
        fprintf('Error opening file: %s\n',sFile)
        return
    end
    
    % set Filename:
    CSEM.filename = sFile;
    sLine = fgets( fid ); % job_id
    sLine = fgets( fid ); % rec_id
    sLine = fgets( fid ); % rec_id
    CSEM.nRx =1;
    [sCode, sValue] = strtok( sLine, ':' );
     sValue(1) = [];     % remove the leading token
    CSEM.xRx = sscanf(sValue,'%g');
    sLine = fgets( fid ); % rec_id
    [sCode, sValue] = strtok( sLine, ':' );
     sValue(1) = [];     % remove the leading token
    CSEM.yRx = sscanf(sValue,'%g');
    sLine = fgets( fid ); % rec_id
    [sCode, sValue] = strtok( sLine, ':' );
     sValue(1) = [];     % remove the leading token
    CSEM.zRx = sscanf(sValue,'%g');
    sLine = fgets( fid ); % list of freqs, skipping since we can get this per block of data below.
    CSEM.nFreq = 0;
    
    % These aren't given in EMGS data files, so nan them:
     CSEM.ThetaRx = nan;
     CSEM.AlphaRx = nan;
     CSEM.BetaRx = nan;
    
    % Decode the header line:
    sLine = fgets( fid ); % header line for labeling columns...
    Header ={};
    sRem = sLine;
    icnt = 0;
    while ~isempty(sRem);
        icnt = icnt+1;
        [Header{icnt} sRem]= strtok(sRem);
    end
    
    % Check for duplicate channels

    if any(strcmpi( 'Ex2-Mag',Header))
        str = 'File has duplicate Ex channels, choose which ones to plot:';
        
        % KWK: make this a selectable dialog for choosing which of the 4
        % combos:
        button = questdlg(str,'Duplicate Channels','Ex1','Ex2','Ex1'); %,Ey1','Ex2,Ey2','Ex1,Ey1');
        switch button
            case 'Ex1'
                 useExChan = 1;
            case 'Ex2'
                 useExChan = 2;
        end
    else
        useExChan =1; % default to use first
    end
    if any(strcmpi( 'Ey2-Mag',Header))
        str = 'File has duplicate Ey channels, choose which ones to plot:';
        
        % KWK: make this a selectable dialog for choosing which of the 4
        % combos:
        button = questdlg(str,'Duplicate Channels','Ey1','Ey2','Ey1'); %,Ey1','Ex2,Ey2','Ex1,Ey1');
        switch button
            case 'Ey1'
                 useEyChan = 1;
            case 'Ey2'
                 useEyChan = 2;
        end
    else
        useEyChan =1; % default to use first
    end
    if any(strcmpi( 'Ez2-Mag',Header))
        str = 'File has duplicate Ez channels, choose which ones to plot:';
        
        % KWK: make this a selectable dialog for choosing which of the 4
        % combos:
        button = questdlg(str,'Duplicate Channels','Ez1','Ez2','Ez1'); %,Ey1','Ex2,Ey2','Ex1,Ey1');
        switch button
            case 'Ez1'
                 useEzChan = 1;
            case 'Ez2'
                 useEzChan = 2;
        end
    else
        useEzChan =1; % default to use first
    end    
    % Now loop though file getting lines of data and parsing them.
    while ~feof(fid)
        % Get the current line:
        sLine = fgets( fid );
        
        % look for frequency field and update structure:
        if strcmpi(sLine(1),'#')
           CSEM.nFreq = CSEM.nFreq + 1;
           CSEM.Freq(CSEM.nFreq) = sscanf(sLine,'# f=%g');
           nd = 0;
        else % data line...
            % Offset	Ex1-Mag	Ex1-Pha	Ex2-Mag	Ex2-Pha	Ey1-Mag	Ey1-Pha Ey2-Mag	Ey2-Pha	Hx1-Mag	Hx1-Pha	Hy1-Mag	Hy1-Pha	x	y	z	wd	hd	
             
            temp = sscanf(sLine,'%g');
            nd = nd+1;           
            % push this into the temp DATA array
            DATA(CSEM.nFreq,nd,1:length(temp)) = temp;
        end
    
        
    end
    CSEM.Freq = CSEM.Freq';
    % Close up file
    fclose(fid);
    
    % Test to make sure all frequencies have data at the same Tx positions:
    if any(diff(DATA(:,:,1)))
        % there's a different range, not supported for now...
          fprintf('Error in reading data file, not all Tx positions the same between frequencies, stopping\n')
        return
    end
    
    % Now  parse the Tx stuff into the CSEM structure, assuming these 
    % columns exist: x,y,z,wd,heading.
    xcol = strmatch( 'x',Header);
    ycol = strmatch( 'y',Header);
    zcol = strmatch( 'z',Header);
    hdcol = strmatch( 'hd',Header);
    wdcol = strmatch('wd',Header);
    CSEM.xTx = DATA(1,:,xcol);
    CSEM.yTx = DATA(1,:,ycol);
    CSEM.zTx = DATA(1,:,zcol);
    CSEM.nTx = length(CSEM.zTx);
   % CSEM.AltitudeTx = DATA(1,:, wdcol) - CSEM.zTx;
   % Why is Altitude so erratic, and even goes negative...?
    CSEM.AzimuthTx = DATA(1,:, hdcol);
    CSEM.DipTx = 0*CSEM.AzimuthTx; 

    fprintf('Warning: assuming EMGS antenna has 0 dip since no dip given in data file!\n')
    
    % Now insert data in stucture
    
        % First allocate the data arrays:
        CSEM.ex_data = zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
        CSEM.ey_data = CSEM.ex_data;
        CSEM.ez_data = CSEM.ex_data; 
        CSEM.bx_data = CSEM.ex_data;
        CSEM.by_data = CSEM.ex_data;
        CSEM.bz_data = CSEM.ex_data;

        CSEM.ex_sd = nan*CSEM.ex_data;
        CSEM.ey_sd = nan*CSEM.ex_data;
        CSEM.ez_sd = nan*CSEM.ex_data;
        CSEM.bx_sd = nan*CSEM.ex_data;
        CSEM.by_sd = nan*CSEM.ex_data;
        CSEM.bz_sd = nan*CSEM.ex_data;       

        

    
    % Create some dummy arrays:
    CSEM.exp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.eyp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.ezp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bxp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.byp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bzp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);

     % Create some dummy arrays:
    CSEM.ex_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.ey_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.ez_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bx_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.by_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq);
    CSEM.bz_resp = nan*zeros(CSEM.nRx,CSEM.nTx,CSEM.nFreq); 
    
  % Offset	Ex1-Mag	Ex1-Pha	Ex2-Mag	Ex2-Pha	Ey1-Mag	Ey1-Pha Ey2-Mag	Ey2-Pha	Hx1-Mag	Hx1-Pha	Hy1-Mag	Hy1-Pha	x	y	z	wd	hd	
  % DATA(CSEM.nfreq,nd,1:18)
  % Get column indices: 
    BxAcol = strmatch('Hx1-Mag',Header);
    BxPcol = strmatch('Hx1-Pha',Header);
    ByAcol = strmatch('Hy1-Mag',Header);
    ByPcol = strmatch('Hy1-Pha',Header);    
    BzAcol = strmatch('Hz1-Mag',Header);
    BzPcol = strmatch('Hz1-Pha',Header);        
    if  useExChan == 1;
        ExAcol = strmatch('Ex1-Mag',Header);
        ExPcol = strmatch('Ex1-Pha',Header);
    else
        ExAcol = strmatch('Ex2-Mag',Header);
        ExPcol = strmatch('Ex2-Pha',Header);
    end
    if  useEyChan == 1;
        EyAcol = strmatch('Ey1-Mag',Header);
        EyPcol = strmatch('Ey1-Pha',Header);  
    else    
        EyAcol = strmatch('Ey2-Mag',Header);
        EyPcol = strmatch('Ey2-Pha',Header);     
    end
    if  useEzChan == 1;
        EzAcol = strmatch('Ez1-Mag',Header);
        EzPcol = strmatch('Ez1-Pha',Header);     
    else
        EzAcol = strmatch('Ez2-Mag',Header);
        EzPcol = strmatch('Ez2-Pha',Header);             
    end


    
  % Using phase lag convention below...
    if ~isempty( ExAcol) && ~isempty( ExPcol)
        CSEM.ex_data(1,:,:) = transpose(DATA(:,:,ExAcol).*exp(sqrt(-1)*DATA(:,:,ExPcol)));
    end
    if ~isempty( EyAcol) && ~isempty( EyPcol)
        CSEM.ey_data(1,:,:) = transpose(DATA(:,:,EyAcol).*exp(sqrt(-1)*DATA(:,:,EyPcol)));
    end
    if ~isempty( EzAcol) && ~isempty( EzPcol)
        CSEM.ez_data(1,:,:) = transpose(DATA(:,:,EzAcol).*exp(sqrt(-1)*DATA(:,:,EzPcol)));
    end    

    mu0 = 4*pi*10^-7;
    if ~isempty( BxAcol) && ~isempty( BxPcol)
        CSEM.bx_data(1,:,:) = mu0*transpose(DATA(:,:,BxAcol).*exp(sqrt(-1)*DATA(:,:,BxPcol)));
    end
    if ~isempty( ByAcol) && ~isempty( ByPcol)
        CSEM.by_data(1,:,:) = mu0*transpose(DATA(:,:,ByAcol).*exp(sqrt(-1)*DATA(:,:,ByPcol)));
    end
    if ~isempty( BzAcol) && ~isempty( BzPcol)
        CSEM.bz_data(1,:,:) = mu0*transpose(DATA(:,:,BzAcol).*exp(sqrt(-1)*DATA(:,:,BzPcol)));
    end
    
            
    % Nan the data arrays where amplitude is 0:
    CSEM.ex_data( abs(CSEM.ex_data)==0 ) = nan;
    CSEM.ey_data( abs(CSEM.ey_data)==0 ) = nan;
    CSEM.ez_data( abs(CSEM.ez_data)==0 ) = nan;
    CSEM.bx_data( abs(CSEM.bx_data)==0 ) = nan;
    CSEM.by_data( abs(CSEM.by_data)==0 ) = nan;
    CSEM.bz_data( abs(CSEM.bz_data)==0 ) = nan;
    
  % Sort the fields in alphabetical order  
    CSEM = orderfields(CSEM);
    
    return           