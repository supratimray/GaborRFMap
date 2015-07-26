% runGetAuditoryStimuli

%% Default Folder
clear; clc

%%%%%%%%%%%%%%%%%%%%%%%%%% Get Matlab file path %%%%%%%%%%%%%%%%%%%%%%%%%%%
pathStr = which('runGetAuditoryStimuli.m');
sepStr = filesep;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Sound folder %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Matlab code is located on a folder (codeFolder) within a parent folder. 
% Parent folder also contains 'Sounds' folder
codeFolder = pathStr(1:max(strfind(pathStr,sepStr))-1); 
parentFolder = codeFolder(1:max(strfind(codeFolder,sepStr))-1); 
folderName = fullfile(parentFolder,'Sounds'); % This step creates 'Sounds' folder in the parent folder if it does not exist. 
makeDirectory(folderName);

% In GaborRFMap, codeFolder is named 'MATLAB'
%                parentFolder is named 'Resources'
%                folderName (soundsFolder) is named 'Sounds'
%       Hence, 'Resources' contains 'MATLAB' and 'Sounds' that contain
%       Matlab code and sound stimuli respectively.

%% Stimulus Type 1: Ripple Protocol

%%%%%%%%%%%%%%%%%% Auditory Stimulus Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Azimuth and elevation are used ot specify the location of the sound
% source. Both are set to zero by default.
Azi_List=0; Elev_List=0;

w_List = 0:4:40; % Ripple velocity
Om_List = -2:0.4:2; % Ripple frequency
Ph_List = [0 0.25 0.5 0.75]*pi; % Ripple phase; should be in radians (eg. pi/2, pi/4, etc.)

T0 = 1; % Stimulus duration
Mo_List = [0.1 0.3 0.5 0.7 0.9]; % Modulation Depth

comp_phs_file=fullfile(codeFolder,'save_comp_phs_20'); % File containing 120 random phases for 120 frequency components of the carrier

%%%%%%%%%%%%%%%%%%%%%%% Mapping to visual stimulus %%%%%%%%%%%%%%%%%%%%%%%%
a=Azi_List; e=Elev_List; % Stimulus location
s=1;           % sigma is mapped to the Stimulus Type
f=Om_List;          % spatial frequency is mapped to Ripple frequency 
o=Ph_List;          % orientation is mapped to ripple phase          
c=Mo_List;          % contrast is mapped to Modulation depth
t=w_List;           % temporal frequency is mapped to Ripple velocity

getAuditoryStimuli(a,e,s,f,o,c,t,T0,comp_phs_file,folderName);

%% Stimulus Type 2: Sinusoidally Amplitude Modulated (SAM) Protocol

%%%%%%%%%%%%%%%%%% Auditory Stimulus Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Azimuth and elevation are used ot specify the location of the sound
% source. Both are set to zero by default.
Azi_List=0; Elev_List=0;

w_List = 4:4:40; % Ripple velocity
f0_List = [500 1000 2000 4000]; % Carrier frequency
Ph_List = 0; % Ripple phase; should be in radians (eg. pi/2, pi/4, etc.)

T0 = 1; % Duration
Mo_List = 0.9; % Modulation Depth

comp_phs_file=fullfile(codeFolder,'save_comp_phs_20'); % File containing 120 random phases for 120 frequency components of the carrier

%%%%%%%%%%%%%%%%%%%%%%% Mapping to visual stimulus %%%%%%%%%%%%%%%%%%%%%%%%
a=Azi_List; e=Elev_List; % Stimulus location
s=2;           % sigma is mapped to the Stimulus Type
f=f0_List;          % spatial frequency is mapped to Ripple frequency 
o=Ph_List;          % orientation is mapped to ripple phase          
c=Mo_List;          % contrast is mapped to Modulation depth
t=w_List;           % temporal frequency is mapped to Ripple velocity 

getAuditoryStimuli(a,e,s,f,o,c,t,T0,comp_phs_file,folderName);

%% Stimulus Type 3: Noise Burst Protocol

%%%%%%%%%%%%%%%%%% Auditory Stimulus Properties %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Azimuth and elevation are used ot specify the location of the sound
% source. Both are set to zero by default.
Azi_List=0; Elev_List=0;

w_List = 0; % Ripple velocity
Om_List = 0; % Ripple frequency
Ph_List = 0; % Ripple phase; should be in radians (eg. pi/2, pi/4, etc.)

T0 = 100/1000; % Stimulus duration
Mo_List = 0; % Modulation Depth

comp_phs_file=fullfile(codeFolder,'save_comp_phs_20'); % File containing 120 random phases for 120 frequency components of the carrier

%%%%%%%%%%%%%%%%%%%%%%% Mapping to visual stimulus %%%%%%%%%%%%%%%%%%%%%%%%
a=Azi_List; e=Elev_List; % Stimulus location
s=3;           % sigma is mapped to the Stimulus Type
f=Om_List;          % spatial frequency is mapped to Ripple frequency 
o=Ph_List;          % orientation is mapped to ripple phase          
c=Mo_List;          % contrast is mapped to Modulation depth
t=w_List;           % temporal frequency is mapped to Ripple velocity

getAuditoryStimuli(a,e,s,f,o,c,t,T0,comp_phs_file,folderName);