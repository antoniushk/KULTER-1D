function varargout = createEMDataFile(varargin)
%
% A function with a GUI for creating an EMData_1.0 file for use with the
% OCCAM1DCSEM inversion.  The gui allows you to select components, ranges,
% noise levels etc.  Enjoy.
%
% Copyright 2009
% Kerry Key
% Scripps Institution of Oceanography
% University of California, San Diego
% kkey@ucsd.edu
%
%
% A product of the Seafloor Electromagnetic Methods Consortium
% http://marineemlab.ucsd.edu/semc.html
%
% License:
%
%
%    createEMDataFile is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    createEMDataFile is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with plotCSEM.  If not, see <http://www.gnu.org/licenses/>.
%
%
% Versions:
%
% 1.0, January 2009.
%
%

% CREATEEMDATAFILE M-file for createEMDataFile.fig
%      CREATEEMDATAFILE, by itself, creates a new CREATEEMDATAFILE or raises the existing
%      singleton*.
%
%      H = CREATEEMDATAFILE returns the handle to a new CREATEEMDATAFILE or the handle to
%      the existing singleton*.
%
%      CREATEEMDATAFILE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CREATEEMDATAFILE.M with the given input arguments.
%
%      CREATEEMDATAFILE('Property','Value',...) creates a new CREATEEMDATAFILE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before createEMDataFile_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to createEMDataFile_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help createEMDataFile

% Last Modified by GUIDE v2.5 15-Jan-2009 11:04:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @createEMDataFile_OpeningFcn, ...
                   'gui_OutputFcn',  @createEMDataFile_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before createEMDataFile is made visible.
function createEMDataFile_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to createEMDataFile (see VARARGIN)

% Choose default command line output for createEMDataFile
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes createEMDataFile wait for user response (see UIRESUME)
% uiwait(handles.createEMDataFileFigure);


% --- Outputs from this function are returned to the command line.
function varargout = createEMDataFile_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in useEx.
function useEx_Callback(hObject, eventdata, handles)
% hObject    handle to useEx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useEx


% --- Executes on button press in useBx.
function useBx_Callback(hObject, eventdata, handles)
% hObject    handle to useBx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useBx


% --- Executes on button press in useEy.
function useEy_Callback(hObject, eventdata, handles)
% hObject    handle to useEy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useEy


% --- Executes on button press in useBy.
function useBy_Callback(hObject, eventdata, handles)
% hObject    handle to useBy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useBy


% --- Executes on button press in useEz.
function useEz_Callback(hObject, eventdata, handles)
% hObject    handle to useEz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useEz


% --- Executes on button press in useBz.
function useBz_Callback(hObject, eventdata, handles)
% hObject    handle to useBz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useBz





% --- Executes on button press in selectFileButton.
function selectFileButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectFileButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
  % Select some new files for plotting:
    [filename, pathname] = uigetfile({'*.csem;*.mat;*.data;*.emdata;*.resp;*.txt'}, 'Select .csem,.data or .resp file(s)','multiselect','off');
  
    if isnumeric(filename) && filename ==0
        set(gcf,'userdata',[]);
        return
    end
% 

    fname = fullfile(pathname,filename);
    readAndLoadFile(hObject,fname);
    
function readAndLoadFile(hObject,fname) 
    
    if isempty(fname)
        selectFileButton_Callback(hObject, [], [])
        return;
    end
    [ path filename] = fileparts(fname);
  % Read in the new file:
    CSEM =  readCSEM(fname); 
    if isempty(CSEM)
        set(gcf,'userdata',[]);
        return
    end
  % Call the function to update the fields using the CSEM structure:  
    updateGUIfields(CSEM);  
    
function updateGUIfields(varargin)  

 % Make UI figure current:
  figure(findobj('tag','createEMDataFileFigure'));

 % Get CSEM structure:
    CSEM = varargin{1};
    [ path filename] = fileparts(CSEM.filename);
    
 % If more than 1 Rx, select which one to use: 
    while CSEM.nRx > 1
         CSEM = getSingleRx(CSEM);
         if isempty(CSEM) % user cancelled...
            beep;
            h = errordlg('createEMDataFile currently only supports single receiver data files. Try selecting single Rx again.', 'Error', 'modal');  
            waitfor(h);
            close(gcf);
            return
         end
    end

  % Create frequency / noise level menu:
    dd = cell(length(CSEM.Freq),8);
 
    for i = 1:length(CSEM.Freq)
        dd{i,1} = sprintf('%g',CSEM.Freq(i));
        dd{i,2} = true;
    end
    set(findobj(gcf,'tag','freqNoiseUItable'),'data',dd);
    
  % Add rotations to GUI, if available:
    if isfinite(CSEM.ThetaRx)
       set(findobj(gcf,'tag','theta'),'string',CSEM.ThetaRx);
    else
       set(findobj(gcf,'tag','theta'),'string','');
    end
    if isfinite(CSEM.AlphaRx)
       set(findobj(gcf,'tag','alpha'),'string',CSEM.AlphaRx);
    else
       set(findobj(gcf,'tag','alpha'),'string','');       
    end
    if isfinite(CSEM.BetaRx)
       set(findobj(gcf,'tag','beta'),'string',CSEM.BetaRx);
    else
       set(findobj(gcf,'tag','beta'),'string','');         
    end   
    if ~isfinite(CSEM.ThetaRx)
        % Default to OPRA method:
         set(findobj(gcf,'tag','OPRAbutton'),'value',1)
         OPRAbutton_Callback([], [], [])
    end
    
  % Add Rx depth to 1D approx fields:
    set(findobj(gcf,'tag','rxDepth'),'string',CSEM.zRx(1));
    set(findobj(gcf,'tag','useRxDepth'),'value',1);
    set(findobj(gcf,'tag','oceanDepth'),'string',CSEM.zRx(1));
    
  % If model response data only, select that button:
    lex = all(~isfinite(CSEM.ex_data));
    ley = all(~isfinite(CSEM.ey_data));
    lez = all(~isfinite(CSEM.ez_data));
    led = all ([lex ley lez]); 
    
    lex = all(isfinite(CSEM.ex_resp));
    ley = all(isfinite(CSEM.ey_resp));
    lez = all(isfinite(CSEM.ez_resp));
    ler = all ([lex ley lez]);    
    if all(ler) && all(led)
        set(findobj(gcf,'tag','useModelRespButton'),'value',1);
    end

     
  % Store CSEM structure in USER data:  
    set(gcf,'userdata',CSEM);
  
  % Place filename on button:  
    set(findobj(gcf,'tag','selectFileButton'),'string',filename);

  % Set output filename:
    str = strcat(filename,'.emdata');
    set(findobj(gcf,'tag','outputFilename'),'string',str);
    
    
% --- Executes on button press in loadSettings.
function loadSettings_Callback(hObject, eventdata, handles)
% hObject    handle to loadSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [filename, pathname] = uigetfile('*.fig',  'Select settings .fig file');
    if isequal(filename,0) || isequal(pathname,0)
        disp('User pressed cancel, not loading settings!')
        return
    end
    close(gcf);
    openfig(fullfile(pathname,filename));
    
% --- Executes on button press in saveSettings.
function saveSettings_Callback(hObject, eventdata, handles)
% hObject    handle to saveSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    [filename, pathname] = uiputfile('*.fig',  'Save settings as');
    
    if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel, settings not saved!')
       return
    end
 
    saveas(gcf,fullfile(pathname,filename),'fig');

    fprintf('Settings saved to file: %s\n',filename);

function alpha_Callback(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of alpha as text
%        str2double(get(hObject,'String')) returns contents of alpha as a double


% --- Executes during object creation, after setting all properties.
function alpha_CreateFcn(hObject, eventdata, handles)
% hObject    handle to alpha (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function theta_Callback(hObject, eventdata, handles)
% hObject    handle to theta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of theta as text
%        str2double(get(hObject,'String')) returns contents of theta as a double


% --- Executes during object creation, after setting all properties.
function theta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to theta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function beta_Callback(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of beta as text
%        str2double(get(hObject,'String')) returns contents of beta as a double


% --- Executes during object creation, after setting all properties.
function beta_CreateFcn(hObject, eventdata, handles)
% hObject    handle to beta (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in writeDataFile.
function writeDataFile_Callback(hObject, eventdata, handles)
% hObject    handle to writeDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% This is the main callback for when the Write Data File button is pressed.
%
% 

% First check that we have some data in CSEM structure:
    CSEM = get(gcf,'userdata');
    if isempty(CSEM)
        beep;
        fprintf('Error, no data read in! \nTry again buddy!\n');
        return
    end
        
%
% Get all the GUI inputs:
%


  % Apply masks:
    if get(findobj(gcf,'tag','useDataMask'),'value') == 1 
        [p n e v] = fileparts(CSEM.filename);
        maskFile = fullfile(p,strcat(n,'.masks'));
     
        try 
            load(maskFile,'-mat');
            CSEM.ex_data = CSEM.ex_data.*Mask.E;
            CSEM.ey_data = CSEM.ey_data.*Mask.E;
            CSEM.ez_data = CSEM.ez_data.*Mask.E;
            CSEM.bx_data = CSEM.bx_data.*Mask.B;
            CSEM.by_data = CSEM.by_data.*Mask.B;
            CSEM.bz_data = CSEM.bz_data.*Mask.B;
            CSEM.ex_resp = CSEM.ex_resp.*Mask.E;
            CSEM.ey_resp = CSEM.ey_resp.*Mask.E;
            CSEM.ez_resp = CSEM.ez_resp.*Mask.E;
            CSEM.bx_resp = CSEM.bx_resp.*Mask.B;
            CSEM.by_resp = CSEM.by_resp.*Mask.B;
            CSEM.bz_resp = CSEM.bz_resp.*Mask.B;
            
        catch ME    
            beep
            display('Error trying to apply masks to data, skipping')
        end
    end

% Downsample data:
    if get(findobj(gcf,'tag','useDecimation'),'value') == 1
        decimation = str2double(get(findobj(gcf,'tag','decimationFactor'),'string'));
        if isempty(decimation)
            errordlg('No decimation value given, try again!', 'Error', 'modal');  
            return
        end
        decimation = round(decimation);
        if decimation > 1
            CSEM = downsampleCSEM(CSEM,decimation);
        end
    end

% Get the Data type to use (data or model response):
    if get(findobj(gcf,'tag','useDataButton'),'value') == 1
         lCreateSyntheticData = false;
    else  % elseif get(findobj(gcf,'tag','useModelRespButton'),'value') == 1
       %  Set flag for creating synthetic data:
        lCreateSyntheticData = true;
    end
    
% Get components to output:
    outputComps ={};
    
    if get(findobj(gcf,'tag','useEx'),'value') == 1
        outputComps = {outputComps{:} 'Ex'};
    end
    if get(findobj(gcf,'tag','useEy'),'value') == 1
        outputComps = {outputComps{:} 'Ey'};
    end
    if get(findobj(gcf,'tag','useEz'),'value') == 1
        outputComps = {outputComps{:} 'Ez'};
    end
    if get(findobj(gcf,'tag','useBx'),'value') == 1
        outputComps = {outputComps{:} 'Bx'};
    end
    if get(findobj(gcf,'tag','useBy'),'value') == 1
        outputComps = {outputComps{:} 'By'};
    end
    if get(findobj(gcf,'tag','useBz'),'value') == 1
        outputComps = {outputComps{:} 'Bz'};
    end    
    if isempty(outputComps)
        errordlg('No components selected for output. Try again', 'Error', 'modal');        
        return
    end
    
    
% Get Tow subset flag:
     if get(findobj(gcf,'tag','towSubsetAll'),'value') == 1 
        towSubset = 'All';
     elseif get(findobj(gcf,'tag','towSubsetInTow'),'value') == 1 
        towSubset = 'In';
     elseif get(findobj(gcf,'tag','towSubsetOutTow'),'value') == 1 
        towSubset = 'Out';
     end
     
     % Get the subset:
     CSEM = getTowSubSet(CSEM,towSubset);
     
     % Check to make sure there's some data left:
     if isempty(CSEM.xTx)
        str = sprintf('Error using tow subset: %s. No data avaiable! Try again.',towSubset);
        errordlg(str, 'Error', 'modal');        
        return   
     end
     

% Receiver orientation:
    theta = 0;
    alpha = 0;
    beta = 0;
    if get(findobj(gcf,'tag','OPRAbutton'),'value') == 1 
        theta = '?'; 
        alpha = '?'; 
        beta  = '?'; 
    elseif get(findobj(gcf,'tag','knownRxRotButton'),'value') == 1 
        theta = str2double(get(findobj(gcf,'tag','theta'),'string'));
        alpha = str2double(get(findobj(gcf,'tag','alpha'),'string'));
        beta  = str2double(get(findobj(gcf,'tag','beta'),'string'));   
        % Catch for blank fields:
        if isnan(theta); theta = 0; end      
        if isnan(alpha); alpha = 0; end      
        if isnan(beta); beta = 0; end      
    end
   % Reassign to CSEM str:
   CSEM.ThetaRx = theta;
   CSEM.AlphaRx = alpha;
   CSEM.BetaRx  = beta;
    
% Rotate survey coordinate axes?
    str = get(findobj(gcf,'tag','rotSurveyX'),'string');
    if isempty(str)
        %rotSurveyXY = 0;
    else
        rotSurveyXY = str2double(str);
        if ~isfinite(rotSurveyXY)
             errordlg('Error in value for rotating survey coordinates. Try again', 'Error', 'modal');
            return
        else
            CSEM = rotateSurveyAxes(CSEM,rotSurveyXY);
 
        end
    end
    
% Rotate receiver x,y,z axes to survey x,y,z axes?
    val = get(findobj(gcf,'tag','rotRxXYtoSurveyXY'),'value');
    if val == 1 &&   get(findobj(gcf,'tag','knownRxRotButton'),'value') == 1;
        CSEM = rotateCSEM(CSEM,-CSEM.ThetaRx,-CSEM.AlphaRx,-CSEM.BetaRx);  
        % update rotation parameters:
        CSEM.ThetaRx = 0;
        CSEM.AlphaRx = 0;
        CSEM.BetaRx  = 0;
    end
    
% Output format for data:

    if get(findobj(gcf,'tag','outputRealImag'),'value') == 1 
        dataType = 'realimag';
    elseif get(findobj(gcf,'tag','outputAmpPhs'),'value') == 1 
        dataType = 'ampphs';
    elseif get(findobj(gcf,'tag','outputAmp'),'value') == 1 
        dataType = 'amp';
    elseif get(findobj(gcf,'tag','outputPhs'),'value') == 1 
        dataType = 'phs';  
    elseif get(findobj(gcf,'tag','pMaxpMin'),'value') == 1    
        dataType = 'pmaxpmin'; 
    elseif get(findobj(gcf,'tag','pMax'),'value') == 1    
        dataType = 'pmax';         
    end
    
% Noise levels and frequencies to use:
    if get(findobj(gcf,'tag','omitMinAbs'),'value') == 1 
        lomitMinAbs = true;
    else
        lomitMinAbs = false;
    end
 % noise table:
    dd = get(findobj(gcf,'tag','freqNoiseUItable'),'data');
    
    % subset freqs:
    lfreq = find(cell2mat(dd(:,2)));
    CSEM.Freq = CSEM.Freq(lfreq);
    CSEM.nFreq = length( CSEM.Freq);
        % [ nRxs by nTx by nFreq]
    CSEM.ex_data = CSEM.ex_data(:,:,lfreq);
    CSEM.ey_data = CSEM.ey_data(:,:,lfreq);
    CSEM.ez_data = CSEM.ez_data(:,:,lfreq);
    CSEM.bx_data = CSEM.bx_data(:,:,lfreq);
    CSEM.by_data = CSEM.by_data(:,:,lfreq);
    CSEM.bz_data = CSEM.bz_data(:,:,lfreq);
    
    CSEM.ex_resp = CSEM.ex_resp(:,:,lfreq);
    CSEM.ey_resp = CSEM.ey_resp(:,:,lfreq);
    CSEM.ez_resp = CSEM.ez_resp(:,:,lfreq);
    CSEM.bx_resp = CSEM.bx_resp(:,:,lfreq);
    CSEM.by_resp = CSEM.by_resp(:,:,lfreq);
    CSEM.bz_resp = CSEM.bz_resp(:,:,lfreq);
    
    CSEM.ex_sd = CSEM.ex_sd(:,:,lfreq);
    CSEM.ey_sd = CSEM.ey_sd(:,:,lfreq);
    CSEM.ez_sd = CSEM.ez_sd(:,:,lfreq);
    CSEM.bx_sd = CSEM.bx_sd(:,:,lfreq);
    CSEM.by_sd = CSEM.by_sd(:,:,lfreq);
    CSEM.bz_sd = CSEM.bz_sd(:,:,lfreq);    
    
    % Get noise levels:
    absNoiseE = dd(lfreq,3);
    relNoiseE = dd(lfreq,4);
    absNoiseB = dd(lfreq,5);
    relNoiseB = dd(lfreq,6);
    minRange = dd(lfreq,7);
    maxRange = dd(lfreq,8);   
    
    % check for empty values and then convert from cell to mat:
      if isempty(absNoiseE{1})
            absNoiseE{1} = 0;
        end
        if isempty(relNoiseE{1})
            relNoiseE{1} = 0;
        end        
        if isempty(absNoiseB{1})
            absNoiseB{1} = 0;
        end
        if isempty(relNoiseB{1})
            relNoiseB{1} = 0;
        end           
        if isempty(minRange{1})
            minRange{1} = 0;
        end           
        if isempty(maxRange{1})
            maxRange{1} = 1d99;
        end            
    
    
    for i = 2:length(lfreq);
        if isempty(absNoiseE{i})
            absNoiseE{i} = absNoiseE{1};
        end
        if isempty(relNoiseE{i})
            relNoiseE{i} = relNoiseE{1};
        end        
        if isempty(absNoiseB{i})
            absNoiseB{i} = absNoiseB{1};
        end
        if isempty(relNoiseB{i})
            relNoiseB{i} = relNoiseB{1};
        end           
        if isempty(minRange{i})
            minRange{i} = minRange{1};
        end           
        if isempty(maxRange{i})
            maxRange{i} = maxRange{1};
        end                      
    end
    absNoiseE = cell2mat(absNoiseE); 
    relNoiseE = cell2mat(relNoiseE); 
    absNoiseB = cell2mat(absNoiseB); 
    relNoiseB = cell2mat(relNoiseB); 
    minRange = cell2mat(minRange); 
    maxRange = cell2mat(maxRange);   
    
 
    
% Get 1D approximations and apply them:
   % modified Rx depth:
    if get(findobj(gcf,'tag','useRxDepth'),'value') == 1 
         str = get(findobj(gcf,'tag','rxDepth'),'string');
         if isempty(str)    
            errordlg('No value given for Rx Depth in 1D Approximation. Try again', 'Error', 'modal');
            return
         end
         rxDepth = str2double(str);
         CSEM.zRx(:) = rxDepth;
    end
        
% Tx Depth approximation (for topo):
    if get(findobj(gcf,'tag','useTxDepth'),'value') == 1 
      % do nothing..
    elseif get(findobj(gcf,'tag','useFixedTxDepth'),'value') == 1 
       str = get(findobj(gcf,'tag','fixedTxDepth'),'string'); 
        if isempty(str)    
            errordlg('No value given for Fixed Tx Depth in 1D Approximation. Try again', 'Error', 'modal');
            return
        end       
        fixedTxDepth = str2double(str);
        CSEM.zTx(:) = fixedTxDepth;
        
    elseif get(findobj(gcf,'tag','useTxAlt'),'value') == 1 
        oceanDepth = get(findobj(gcf,'tag','oceanDepth'),'string');
        if isempty(oceanDepth)
           errordlg('Ocean Depth not set. Try again.', 'Error', 'modal');
           return
        else
            oceanDepth = str2double(oceanDepth);
        end           
        if ~all(isfinite(CSEM.hTx)) % tx height
           errordlg('Tx altitude not given in data file, so 1D altitude approx not possible. Try again.', 'Error', 'modal');
           return
        end
        CSEM.zTx(:) = oceanDepth - CSEM.hTx;

    end
    if any (CSEM.zTx < 0)
        beep
        warndlg('Warning!  Negative transmitter depth detected.  Check ocean depth and Tx depth settings.', 'Warning', 'modal');        
    end
   if any (CSEM.zTx > CSEM.zRx)
       str1 = sprintf('Beware! Transmitter depth is greater than receiver depth in some places. \n');
       str2 = sprintf(' This is okay for 2D/3D modeling, but not 1D modeling.\n');
       str3 = sprintf(' You might want to set a fixed Tx depth for 1D inversion');
       str = strcat(str1,str2,str3);
       warndlg(str, 'Warning', 'modal');
       return
   end
    

   
% Get output file name:
    outputFileName = get(findobj(gcf,'tag','outputFilename'),'string');
    if isempty(outputFileName);
         f = errordlg('Error: no output file name given, try again!', 'Error Dialog');
       return
    end

% Everything has been read in from the GUI, now call the external function
% that does the work:

% Omit minRange,maxRange ?
    CSEM = getRangeSubset(CSEM,minRange,maxRange );
  
% Now create DATA array:
    DATA = makeEMDataArray(CSEM,lCreateSyntheticData,outputComps,dataType,...
                             lomitMinAbs,absNoiseE, relNoiseE, ...
                             absNoiseB, relNoiseB );

% As last check update CSEM array based on Tx's actually in the DATA
% array:
    iTxUsed = unique(DATA(:,3));
    iNewTxNumber = 0*[1:CSEM.nTx];
    iNewTxNumber(iTxUsed) = 1:length(iTxUsed);
    DATA(:,3) = iNewTxNumber(DATA(:,3));
    
    CSEM.xTx = CSEM.xTx(iTxUsed);
    CSEM.yTx = CSEM.yTx(iTxUsed);
    CSEM.zTx = CSEM.zTx(iTxUsed);   
    CSEM.AzimuthTx = CSEM.AzimuthTx(iTxUsed);   
    CSEM.DipTx = CSEM.DipTx(iTxUsed);  
    CSEM.nTx = length(iTxUsed);
    
% Now write the array to a file:
    if  get(findobj(gcf,'tag','phaseConvention'),'value') == 1 
        phaseConvention = 'lag';
    elseif get(findobj(gcf,'tag','phaseConvention'),'value') == 2 
        phaseConvention = 'lead';
    end
    comment = '';
    
    
    writeEMDataFile(outputFileName,CSEM,DATA,comment,phaseConvention) 
    
% Let the user know we're done:
    msgbox('Done writing data file.','','modal')
   
% --- Executes during object creation, after setting all properties.
function outputFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on button press in useModelRespButton.
function useModelRespButton_Callback(hObject, eventdata, handles)
% hObject    handle to useModelRespButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useModelRespButton

% --- Executes on button press in useDataButton.
function useDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to useDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useDataButton


% --- Executes on button press in outputRealImag.
function outputRealImag_Callback(hObject, eventdata, handles)
% hObject    handle to outputRealImag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of outputRealImag



% --- Executes on button press in omitMinAbs.
function omitMinAbs_Callback(hObject, eventdata, handles)
% hObject    handle to omitMinAbs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of omitMinAbs





function rotSurveyX_Callback(hObject, eventdata, handles)
% hObject    handle to rotSurveyX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rotSurveyX as text
%        str2double(get(hObject,'String')) returns contents of rotSurveyX as a double


% --- Executes during object creation, after setting all properties.
function rotSurveyX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rotSurveyX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rotRxXYtoSurveyXY.
function rotRxXYtoSurveyXY_Callback(hObject, eventdata, handles)
% hObject    handle to rotRxXYtoSurveyXY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rotRxXYtoSurveyXY



function nLayers_Callback(hObject, eventdata, handles)
% hObject    handle to nLayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nLayers as text
%        str2double(get(hObject,'String')) returns contents of nLayers as a double


% --- Executes during object creation, after setting all properties.
function nLayers_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nLayers (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxDepth_Callback(hObject, eventdata, handles)
% hObject    handle to maxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxDepth as text
%        str2double(get(hObject,'String')) returns contents of maxDepth as a double


% --- Executes during object creation, after setting all properties.
function maxDepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function modelFilename_Callback(hObject, eventdata, handles)
% hObject    handle to modelFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of modelFilename as text
%        str2double(get(hObject,'String')) returns contents of modelFilename as a double


% --- Executes during object creation, after setting all properties.
function modelFilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modelFilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in createModel.
function createModel_Callback(hObject, eventdata, handles)
% hObject    handle to createModel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    modelFilename = get(findobj(gcf,'tag','modelFilename'),'string');
    if isempty(modelFilename)
       errordlg('No model file name given. Try again.', 'Error', 'modal');
       return
    end
    
    nSeaBedLay = get(findobj(gcf,'tag','nLayers'),'string');
    if isempty(nSeaBedLay)
       errordlg('# Seabed Layers not set. Try again.', 'Error', 'modal');
       return
    else
        nSeaBedLay = str2double(nSeaBedLay);
    end
    
    maxDepth = get(findobj(gcf,'tag','maxDepth'),'string');
    if isempty(maxDepth)
       errordlg('Max Depth not set. Try again.', 'Error', 'modal');
       return
    else
        maxDepth = str2double(maxDepth);
    end    
    zScale = get(findobj(gcf,'tag','zScale'),'value');
    
    if zScale == 1
        zScale = 'uniform';
    else
        zScale = 'log';
    end
    
    oceanDepth = get(findobj(gcf,'tag','oceanDepth'),'string');
    if isempty(oceanDepth)
       errordlg('Ocean Depth not set. Try again.', 'Error', 'modal');
       return
    else
        oceanDepth = str2double(oceanDepth);
    end   
    
    % Check to make sure oceanDepth and transmitter depth are sensible:
     if get(findobj(gcf,'tag','useTxDepth'),'value') == 1 
          CSEM = get(gcf,'userdata');
          TxDepth = CSEM.zTx;
     elseif get(findobj(gcf,'tag','useFixedTxDepth'),'value') == 1 
       str = get(findobj(gcf,'tag','fixedTxDepth'),'string'); 
        if isempty(str)    
             return
        end       
        TxDepth = str2double(str);
         
     end
     if any(TxDepth >  oceanDepth)
       warndlg('Beware! Transmitter depth is greater than ocean depth. Check your settings.', 'Warning', 'modal');
       return
     end
    
    
    % Ocean resistivity:
    useSingleSeaLayer = get(findobj(gcf,'tag','useSingleSeaLayer'),'value');
    useMultiSeaLayer  = get(findobj(gcf,'tag','useMultiSeaLayer'),'value');
    if useSingleSeaLayer == 1
        seaZ = 0;
        seaRho = get(findobj(gcf,'tag','seaRho'),'string');
        if isempty(seaRho)
           errordlg('Ocean Resistivity not set. Try again.', 'Error', 'modal');
           return
        else
            seaRho = str2double(seaRho);
        end      
    elseif useMultiSeaLayer == 1
        zrho = get(findobj(gcf,'tag','setSeaResFile'),'userdata');
        
        if isempty(zrho)
           errordlg('No ocean resistivity file given, try again.', 'Error', 'modal');
           return
        else
            seaZ = zrho(:,1); 
            seaRho = zrho(:,2);
            
            % First we take subset of seaZ that is shallower than
            % oceanDepth:
            ii = find(seaZ < oceanDepth);
            seaZ = seaZ(ii);
            seaRho = seaRho(ii);
            if seaZ(1) ~= 0; % let's add in the sea surface:
                seaZ = [0; seaZ];
                seaRho = [seaRho(1);seaRho];
            end
        end    
    end
    
% Input Error Check
    if oceanDepth > maxDepth
         errordlg('Ocean Depth is greater than Max Depth. Try again.', 'Error', 'modal');
        return
    end
    
% Call the function to write the model file:
    makeResistivity1DModel(modelFilename,oceanDepth,seaZ,seaRho,...
                                nSeaBedLay,maxDepth,zScale)

% Create a startup file:
    dataFilename = get(findobj(gcf,'tag','outputFilename'),'string');
    if isempty(dataFilename)
       h = warndlg('No output data filename given. You will need to add this by hand to the startup file.', 'Warning', 'modal');
       uiwait(h)
       dataFilename = 'add data file name here!';
    end   
    startingRho = get(findobj(gcf,'tag','startingRho'),'string');
    if isempty(startingRho)
       errordlg('Starting model resistivity not set. Try again.', 'Error', 'modal');
       return
    else
        startingRho = log10(str2double(startingRho));
    end    
    misfit = get(findobj(gcf,'tag','misfit'),'string');
    if isempty(misfit)
       errordlg('Target misfit not set. Try again.', 'Error', 'modal');
       return
    else
        misfit = str2double(misfit);
    end        
    
 % write out the startupfile:   
    writeStartupFile(dataFilename,modelFilename,misfit,nSeaBedLay,startingRho)
    
% Let the user know we're done:
    msgbox('Done writing model and startup files.','','modal')
   

function oceanDepth_Callback(hObject, eventdata, handles)
% hObject    handle to oceanDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of oceanDepth as text
%        str2double(get(hObject,'String')) returns contents of oceanDepth as a double


% --- Executes during object creation, after setting all properties.
function oceanDepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to oceanDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in zScale.
function zScale_Callback(hObject, eventdata, handles)
% hObject    handle to zScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns zScale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from zScale


% --- Executes during object creation, after setting all properties.
function zScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in useRxDepth.
function useRxDepth_Callback(hObject, eventdata, handles)
% hObject    handle to useRxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useRxDepth



function rxDepth_Callback(hObject, eventdata, handles)
% hObject    handle to rxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rxDepth as text
%        str2double(get(hObject,'String')) returns contents of rxDepth as a double


% --- Executes during object creation, after setting all properties.
function rxDepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fixedTxDepth_Callback(hObject, eventdata, handles)
% hObject    handle to fixedTxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fixedTxDepth as text
%        str2double(get(hObject,'String')) returns contents of fixedTxDepth as a double
    set(findobj(gcf,'tag','useFixedTxDepth'),'value',1);

% --- Executes during object creation, after setting all properties.
function fixedTxDepth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fixedTxDepth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function seaRho_Callback(hObject, eventdata, handles)
% hObject    handle to seaRho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of seaRho as text
%        str2double(get(hObject,'String')) returns contents of seaRho as a double


% --- Executes during object creation, after setting all properties.
function seaRho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to seaRho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in setSeaResFile.
function setSeaResFile_Callback(hObject, eventdata, handles)
% hObject    handle to setSeaResFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Select some new files for plotting:
    [filename, pathname] = uigetfile({'*.*'}, 'Select Ocean resistivity file','multiselect','off');
  
    if isnumeric(filename) && filename ==0
        return
    end

  % Read in the file:
     fname = fullfile(pathname,filename);
     try
        seaZandRho = load (fname);
     catch
        errordlg(sprintf('Unable to read ocean resistivity file: %s',filename), 'Error', 'modal'); 
        return;
     end
     
  %  Store data in object's userdata:
    set(hObject,'userdata',seaZandRho);
    
  % Place filename on button:  
    set(hObject,'string',filename);
         
  % Auto check its radio button:
    set(findobj(gcf,'tag','useMultiSeaLayer'),'value',1);
  


function startingRho_Callback(hObject, eventdata, handles)
% hObject    handle to startingRho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of startingRho as text
%        str2double(get(hObject,'String')) returns contents of startingRho as a double


% --- Executes during object creation, after setting all properties.
function startingRho_CreateFcn(hObject, eventdata, handles)
% hObject    handle to startingRho (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function misfit_Callback(hObject, eventdata, handles)
% hObject    handle to misfit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of misfit as text
%        str2double(get(hObject,'String')) returns contents of misfit as a double


% --- Executes during object creation, after setting all properties.
function misfit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to misfit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in knownRxRotButton.
function knownRxRotButton_Callback(hObject, eventdata, handles)
% hObject    handle to knownRxRotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of knownRxRotButton

% turn these options back on in case OPRA button turned them off
set(findobj(gcf,'tag','outputAmpPhs'),'enable','on');
set(findobj(gcf,'tag','outputAmp'),'enable','on');
set(findobj(gcf,'tag','outputPhs'),'enable','on');
set(findobj(gcf,'tag','pMaxpMin'),'enable','on');
set(findobj(gcf,'tag','pMax'),'enable','on');
set(findobj(gcf,'tag','rotRxXYtoSurveyXY'),'enable','on');

% --- Executes on button press in OPRAbutton.
function OPRAbutton_Callback(hObject, eventdata, handles)
% hObject    handle to OPRAbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of OPRAbutton

% Select Real/imag button:
set(findobj(gcf,'tag','outputRealImag'),'value',1);
% turn other options off since they don't work for OPRA
set(findobj(gcf,'tag','outputAmpPhs'),'enable','off');
set(findobj(gcf,'tag','outputAmp'),'enable','off');
set(findobj(gcf,'tag','outputPhs'),'enable','off');
set(findobj(gcf,'tag','pMaxpMin'),'enable','off');
set(findobj(gcf,'tag','pMax'),'enable','off');
set(findobj(gcf,'tag','rotRxXYtoSurveyXY'),'enable','off');

 set(findobj(gcf,'tag','useEx'),'value', 1);
 set(findobj(gcf,'tag','useEy'),'value', 1);
 set(findobj(gcf,'tag','useEz'),'value', 1);
 set(findobj(gcf,'tag','useBx'),'value', 1);
 set(findobj(gcf,'tag','useBy'),'value', 1);
 set(findobj(gcf,'tag','useBz'),'value', 1);

% --- Executes during object creation, after setting all properties.
function freqNoiseUItable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqNoiseUItable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Create dummy freq tble:
    dd = cell(10,8);
    for i = 1:10
        dd{i,2} = false;
    end
    set(findobj(gcf,'tag','freqNoiseUItable'),'data',dd);


% --------------------------------------------------------------------
function uipushtool1_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


saveas(gcf,filename,'fig')
% KWK debug: doesn't save data in freq-noise table, wtf?


% --- Executes on button press in useDataMaskFile.
function useDataMaskFile_Callback(hObject, eventdata, handles)
% hObject    handle to useDataMaskFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useDataMaskFile


% --- Executes on button press in createDataMasks.
function createDataMasks_Callback(hObject, eventdata, handles)
% hObject    handle to createDataMasks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% this function will allow the user to
% add/subtract from the data masks as a function of frequency and E and B.
% Data mask notes data NOT to use.
% mask is a function of (f,E|B,Tx_pos);

  % Get the CSEM data structure:
    CSEM = get(gcf,'userdata');
    if isempty(CSEM)
       return
    end
    set(findobj(gcf,'tag','useDataMask'),'value',1)
  % Look to see if mask file exists already, if so load it:
    [p n e v] = fileparts(CSEM.filename);
     
    maskFile = fullfile(p,strcat(n,'.masks'));
     
    try 
        load(maskFile,'-mat');
        CSEM.Mask.E = Mask.E;
        CSEM.Mask.B = Mask.B;
    catch ME    
      % Else create initial masks:
        CSEM.Mask.E = ones(size(CSEM.ex_data));  % [ nRxs by nTx by nFreq]
        CSEM.Mask.B = ones(size(CSEM.bx_data));  % [ nRxs by nTx by nFreq] 
    end
    
    % Set in/out tow masks based on gui buttons:
    % Get Tow subset flag:
     if get(findobj(gcf,'tag','towSubsetAll'),'value') == 1 
        towSubset = 'All';
     elseif get(findobj(gcf,'tag','towSubsetInTow'),'value') == 1 
        towSubset = 'In';
     elseif get(findobj(gcf,'tag','towSubsetOutTow'),'value') == 1 
        towSubset = 'Out';
     end
    r = sqrt( (CSEM.xTx-CSEM.xRx).^2 + (CSEM.yTx-CSEM.yRx).^2)/1d3;       
    rsign = sign(diff(r));
    rsign = rsign([ 1 1:end]);

    switch lower(towSubset)
        case 'all'
            iOmit = [];
        case 'in'
            iOmit = rsign > 0;

        case 'out'
            iOmit = rsign < 0; 
    end
    CSEM.Mask.E(1,iOmit,:) = nan;
    CSEM.Mask.B(1,iOmit,:) = nan; 
    
    % Check for real/synth data:
    if get(findobj(gcf,'tag','useDataButton'),'value') == 1
        lCreateSyntheticData = false;
    else  % elseif get(findobj(gcf,'tag','useModelRespButton'),'value') == 1
       %  Set flag for creating synthetic data:
        lCreateSyntheticData = true;
    end    
    
    % Call the function that creates the masks:
     editCSEMDataMasks('initializeMasks',CSEM,lCreateSyntheticData)

    


% --- Executes on button press in useDataMask.
function useDataMask_Callback(hObject, eventdata, handles)
% hObject    handle to useDataMask (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useDataMask


% --- Executes on button press in towSubsetInTow.
function towSubsetInTow_Callback(hObject, eventdata, handles)
% hObject    handle to towSubsetInTow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of towSubsetInTow
    set(hObject,'Value',1)
  % Set output filename:
   
    filename = get(findobj(gcf,'tag','outputFilename'),'string');
    [ p n e v] = fileparts(filename);
    
    n = stripIntowOuttowFilename(n);
 
    str = fullfile(p,strcat(n,'_intow','.emdata'));
    set(findobj(gcf,'tag','outputFilename'),'string',str);
     
% --- Executes on button press in towSubsetOutTow.
function towSubsetOutTow_Callback(hObject, eventdata, handles)
% hObject    handle to towSubsetOutTow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
     set(hObject,'Value',1)
% Hint: get(hObject,'Value') returns toggle state of towSubsetOutTow
    filename = get(findobj(gcf,'tag','outputFilename'),'string');
    [ p n e v] = fileparts(filename);

    n = stripIntowOuttowFilename(n);
        
    str = fullfile(p,strcat(n,'_outtow','.emdata'));
    set(findobj(gcf,'tag','outputFilename'),'string',str);
     
    

function newname = stripIntowOuttowFilename(n)

    k = 1;
    while ~isempty(k)
        k = strfind(n,'_intow');
        if k>1
            n = n(1:k-1);
        elseif k == 1
            n = [];            
        end
    end
    k = 1;
    while ~isempty(k)
        k = strfind(n,'_outtow');
        if k>1
            n = n(1:k-1);
        elseif k == 1
            n = [];            
        end
    end       
    newname = n;
        
% --- Executes on button press in towSubsetAll.
function towSubsetAll_Callback(hObject, eventdata, handles)
% hObject    handle to towSubsetAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of towSubsetAll

    filename = get(findobj(gcf,'tag','outputFilename'),'string');
    [ p n e v] = fileparts(filename);

    n = stripIntowOuttowFilename(n);
        
    str = fullfile(p,strcat(n,'.emdata'));
    set(findobj(gcf,'tag','outputFilename'),'string',str);
    
     


% --- Executes on button press in useDecimation.
function useDecimation_Callback(hObject, eventdata, handles)
% hObject    handle to useDecimation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of useDecimation



function decimationFactor_Callback(hObject, eventdata, handles)
% hObject    handle to decimationFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of decimationFactor as text
%        str2double(get(hObject,'String')) returns contents of decimationFactor as a double
    set(findobj(gcf,'tag','useDecimation'),'value',1) 

% --- Executes during object creation, after setting all properties.
function decimationFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to decimationFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pMaxpMinbutton_Callback(hObject,eventdata,handles)

 set(findobj(gcf,'tag','useEx'),'value', 1);
 set(findobj(gcf,'tag','useEy'),'value', 1);
 
 set(findobj(gcf,'tag','useBx'),'value', 1);
 set(findobj(gcf,'tag','useBy'),'value', 1);
 

