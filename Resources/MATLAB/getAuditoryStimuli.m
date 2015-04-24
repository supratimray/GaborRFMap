% This program specifies a 1-1 mapping between a visual gabor stimulus that
% is characterized by 7 parameters and a auditory stimulus. The same
% mapping must be used in the GaborRFMap plugin.

function getAuditoryStimuli(a,e,s,f,o,c,t,T0,comp_phs_file,folderName)

if s==1 % 1: Ripple Protocol
    getRippleStimuli(a,e,s,f,o,c,t,T0,comp_phs_file,folderName);
elseif s==2 % 2: SAM Protocol
    getSAMStimuli(a,e,s,f,o,c,t,T0,comp_phs_file,folderName);
elseif s==3
    getNoiseBurst(a,e,s,f,o,c,t,T0,comp_phs_file,folderName)
end

end

function getRippleStimuli(a,e,s,f,o,c,t,T0,comp_phs_file,folderName) % a,e,c,

% Parameters for rippleList for use in Baphy code
Am = 1;         % Ripple Amplitude
w = t;          % Ripple velocities list
Om = f;         % Ripple frequencies list
Ph = o;         % Ripple phases list

% Stimulus location parameters
aList = a;      % Azimuth List
eList = e;      % Elevetion List

% cond parameters for use in Baphy code
dfA = 20;       % No. of frequencies per octave
f0 = 250;       % lowest freq
BW = 6;         % bandwidth, # of octaves
SF = 44100;     % sample freq, the minimum sampling frequency that iMac's Audio MIDI Setup specifies 
                % (This is kept at minimum so as to reduce processor load as all the frequencies of interest are within Nyquist frequency)
CF = 1;         % Log spacing of components
df = 1/dfA;     % Frequency spacing
RO = 0;         % Roll-off
AF = 1;         % Amplitude flag: Linear
Mo=c;           % Modulation Depth (List)
wM = 120;       % Maximum temporal velocity
PhFlag = 2;     % Phases of component frequencies: loaded from file

% parameters for ramping sound
rampTime = 0.01;                        % Ramp Time (s)
lengthSound = round((T0)*SF); 
timeAxis  = 0:1/SF:(lengthSound-1)/SF;  % Time Axis (s)

% Variables for loop
alen = length(aList);
elen = length(eList);
flen = length(Om);
olen = length(Ph);
clen = length(Mo);
tlen = length(w);

% Variables for waitbar
hW = waitbar(0,'Saving ripple sound stimuli...');
loopLength = alen*elen*flen*olen*clen*tlen; loopNum=0;

% Main loop
for ai=1:alen
    for ei=1:elen
        for fi=1:flen
            for oi=1:olen
                for ci=1:clen    
                    
                    % Save Command window output (stimulus report) as a text file in the same
                    % folder for future reference
                    diary(fullfile(folderName,['StimulusReport_Azi_' num2str(aList(ai)) '_Elev_' num2str(eList(ei)) '_Type_' num2str(s) '_RF_' num2str(Om(fi)) '_RP_' num2str(Ph(oi)*(180/pi)) '_MD_' num2str(Mo(ci)) '_Dur_' num2str(T0) '.txt']));
                    
                    % Call 'cond' before 'tlen' loop so that this info is
                    % entered only once ( in the beginning) of each stimulus
                    % report
                    cond = [T0, f0, BW, SF, CF, df, RO, AF, Mo(ci), wM, PhFlag];
                    disp('T0,           f0,             BW,             SF,             CF,             df,             RO,             AF,             Mo,             wM,             PhFlag');
                    disp(num2str(cond));
                        for ti=1:tlen

                            % For Waitbar
                            loopNum=loopNum+1;
                            waitbar(loopNum/loopLength,hW,['Saving ripple sound stimulus ' num2str(loopNum) ' of ' num2str(loopLength)]);

                            % Baphy code
                            disp([char(10) 'New Sound']);
                            disp('Am      w       Om      Ph');
                            rippleList = [Am w(ti) Om(fi) Ph(oi)];
                            disp(num2str(rippleList));
                            [soundData,profile] = multimvripfft1(rippleList, cond,comp_phs_file);                            

                            % Normalise (MD)
                            [normalisedSound] = soundNormalise(soundData,'max');

                            % Apply Ramp (MD)
                            [rampedSound] = rampSound(normalisedSound,timeAxis,rampTime,'Hanning');
                            
                            % Return same data to both channels (matrix of
                            % two columns)
                            soundFile(:,1)=rampedSound';
                            soundFile(:,2)=rampedSound';

                            % Save file: 2-channel data sampled at 44100
                            % Hz, with 24 bits per sample in .wav format                                                       
                            FileName = ['Azi_' sprintf('%.1f',aList(ai)) '_Elev_' sprintf('%.1f',eList(ei)) '_Type_' num2str(s) '_RF_' sprintf('%.1f',Om(fi)) '_RP_' num2str(Ph(oi)*(180/pi)) '_MD_' sprintf('%.1f',Mo(ci)) '_RV_' sprintf('%.1f',w(ti)) '_Dur_' num2str(T0*1000)];
                            audiowrite([folderName filesep [FileName '.wav']],soundFile,SF,'BitsPerSample',24);
                            disp(['Saved sound file: ' FileName '.wav to folder: ' folderName]);

                        end
                    diary('off')
                end
            end
        end
    end
end

% Close waitbar
close(hW);
end

function getSAMStimuli(a,e,s,f,o,c,t,T0,comp_phs_file,FolderName)

% Parameters for rippleList for use in Baphy code
Am = 1;         % SAM Amplitude
w = t;          % SAM velocities list
Om = 0;         % SAM frequencies list
Ph = o;         % SAM phases list

% Stimulus location parameters
aList = a;      % Azimuth List
eList = e;      % Elevetion List

% Parameters for cond for use in Baphy code
dfA = 1;        % No. of frequencies per octave
f0 = f;         % lowest freq List
BW = 1;         % bandwidth, # of octaves
SF = 44100;     % sample freq, the minimum sampling frequency that iMac's Audio MIDI Setup specifies 
                % (This is kept at minimum so as to reduce processor load as all the frequencies of interest are within Nyquist frequency)
CF = 1;         % Log spacing of components
df = 1/dfA;     % Frequency spacing
RO = 0;         % Roll-off
AF = 1;         % Amplitude flag: Linear
Mo=c;           % Modulation Depth (List)
wM = 120;       % Maximum temporal velocity
PhFlag = 2;     % Phases of component frequencies: loaded from file

% Parameters for ramping sound
rampTime = 0.01;                        % Ramp Time (s)
lengthSound = round((T0)*SF); 
timeAxis  = 0:1/SF:(lengthSound-1)/SF;  % Time Axis (s)

% Variables for loop
alen = length(aList);
elen = length(eList);
flen = length(f0);
olen = length(Ph);
clen = length(Mo);
tlen = length(w);

% Variables for waitbar
hW = waitbar(0,'Saving SAM sound stimuli...');
loopLength = alen*elen*flen*olen*clen*tlen; loopNum=0;

% Main loop
for ai=1:alen
    for ei=1:elen   
        for fi=1:flen        
            for oi=1:olen
                for ci=1:clen
                    
                    % Save Command window output (stimulus report) as a text file in the same
                    % folder for future reference
                    diary(fullfile(FolderName,['StimulusReport_Azi_' num2str(aList(ai)) '_Elev_' num2str(eList(ei)) '_Type_' num2str(s) '_RF_' num2str(f0(fi)) '_RP_' num2str(Ph*(180/pi)) '_MD_' num2str(Mo(ci)) '_Dur_' num2str(T0) '.txt']));       
                    
                    % Call 'cond' before 'tlen' loop so that this info is
                    % entered only once ( in the beginning) of each stimulus
                    % report
                    cond = [T0, f0(fi), BW, SF, CF, df, RO, AF, Mo(ci), wM, PhFlag];
                    disp([char(10) 'T0,           f0,             BW,             SF,             CF,             df,             RO,             AF,             Mo,             wM,             PhFlag']);
                    disp(num2str(cond));
                        for ti=1:tlen

                            % For Waitbar
                            loopNum=loopNum+1;
                            waitbar(loopNum/loopLength,hW,['Saving SAM sound stimulus ' num2str(loopNum) ' of ' num2str(loopLength)]);

                            % Baphy code
                            disp([char(10) 'New Sound']);
                            rippleList = [Am w(ti) Om Ph];
                            disp('Am      w       Om      Ph');
                            disp(num2str(rippleList));
                            [soundData,profile] = multimvripfft1(rippleList, cond,comp_phs_file);                            

                            % Normalise (MD)
                            [normalisedSound] = soundNormalise(soundData,'max');

                            % Apply Ramp (MD)
                            [rampedSound] = rampSound(normalisedSound,timeAxis,rampTime,'Hanning');
                            
                            % Return same data to both channels (matrix of
                            % two columns)
                            soundFile(:,1)=rampedSound';
                            soundFile(:,2)=rampedSound';

                            % Save file: 2-channel data sampled at 44100
                            % Hz, with 24 bits per sample in .wav format                            
                            FileName = ['Azi_' sprintf('%.1f',aList(ai)) '_Elev_' sprintf('%.1f',eList(ei)) '_Type_' num2str(s) '_RF_' sprintf('%.1f',f0(fi)) '_RP_' num2str(Ph*(180/pi)) '_MD_' sprintf('%.1f',Mo(ci)) '_RV_' sprintf('%.1f',w(ti)) '_Dur_' num2str(T0*1000)];
                            audiowrite([FolderName filesep FileName '.wav'],soundFile,SF,'BitsPerSample',24);
                            disp(['Saved sound file: ' FileName '.wav to folder: ' FolderName]);

                        end
                    diary('off');
                end
            end
        end
    end    
end

% Close waitbar
close(hW)
end

function getNoiseBurst(a,e,s,f,o,c,t,T0,comp_phs_file,folderName) % a,e,c,

% Parameters for rippleList for use in Baphy code
Am = 1;         % Ripple Amplitude
w = t;          % Ripple velocities list
Om = f;         % Ripple frequencies list
Ph = o;         % Ripple phases list

% Stimulus location parameters
aList = a;      % Azimuth List
eList = e;      % Elevetion List

% cond parameters for use in Baphy code
dfA = 20;       % No. of frequencies per octave
f0 = 250;       % lowest freq
BW = 6;         % bandwidth, # of octaves
SF = 44100;     % sample freq, the minimum sampling frequency that iMac's Audio MIDI Setup specifies 
                % (This is kept at minimum so as to reduce processor load as all the frequencies of interest are within Nyquist frequency)
CF = 1;         % Log spacing of components
df = 1/dfA;     % Frequency spacing
RO = 0;         % Roll-off
AF = 1;         % Amplitude flag: Linear
Mo=c;           % Modulation Depth (List)
wM = 120;       % Maximum temporal velocity
PhFlag = 2;     % Phases of component frequencies: loaded from file

% parameters for ramping sound
rampTime = 0.01;                        % Ramp Time (s)
lengthSound = round((T0)*SF); 
timeAxis  = 0:1/SF:(lengthSound-1)/SF;  % Time Axis (s)

% Variables for loop
alen = length(aList);
elen = length(eList);
flen = length(Om);
olen = length(Ph);
clen = length(Mo);
tlen = length(w);

% Variables for waitbar
hW = waitbar(0,'Saving noise sound stimuli...');
loopLength = alen*elen*flen*olen*clen*tlen; loopNum=0;

% Main loop
for ai=1:alen
    for ei=1:elen
        for fi=1:flen
            for oi=1:olen
                for ci=1:clen    
                    
                    % Save Command window output (stimulus report) as a text file in the same
                    % folder for future reference
                    diary(fullfile(folderName,['Noise_Dur_' num2str(T0) '.txt']));
                    
                    % Call 'cond' before 'tlen' loop so that this info is
                    % entered only once ( in the beginning) of each stimulus
                    % report
                    cond = [T0, f0, BW, SF, CF, df, RO, AF, Mo(ci), wM, PhFlag];
                    disp('T0,           f0,             BW,             SF,             CF,             df,             RO,             AF,             Mo,             wM,             PhFlag');
                    disp(num2str(cond));
                        for ti=1:tlen

                            % For Waitbar
                            loopNum=loopNum+1;
                            waitbar(loopNum/loopLength,hW,['Saving noise sound stimulus ' num2str(loopNum) ' of ' num2str(loopLength)]);

                            % Baphy code
                            disp([char(10) 'New Sound']);
                            disp('Am      w       Om      Ph');
                            rippleList = [Am w(ti) Om(fi) Ph(oi)];
                            disp(num2str(rippleList));
                            [soundData,profile] = multimvripfft1(rippleList, cond,comp_phs_file);                            

                            % Normalise (MD)
                            [normalisedSound] = soundNormalise(soundData,'max');

                            % Apply Ramp (MD)
                            [rampedSound] = rampSound(normalisedSound,timeAxis,rampTime,'Hanning');
                            
                            % Return same data to both channels (matrix of
                            % two columns)
                            soundFile(:,1)=rampedSound';
                            soundFile(:,2)=rampedSound';

                            % Save file: 2-channel data sampled at 44100
                            % Hz, with 24 bits per sample in .wav format                                                       
                            FileName = ['Noise_Dur_' num2str(T0*1000)];
                            audiowrite([folderName filesep [FileName '.wav']],soundFile,SF,'BitsPerSample',24);
                            disp(['Saved sound file: ' FileName '.wav to folder: ' folderName]);

                        end
                    diary('off')
                end
            end
        end
    end
end

% Close waitbar
close(hW);
end
%% [rampedSound,rampingFunction] = rampSound(soundFile,timeVals,rampTime,ramp)
% Murty V P S Dinavahi 20/04/2015

function [rampedSound,rampingFunction] = rampSound(soundFile,timeVals,rampTime,ramp,PlotFlag) % rampTime is in seconds

% Input arguments:
% timeVals
% rampTime: is in same units as timeVals
% optional: 
% 1. ramp:
%    1. 'SquaredSine'
%    2. 'Hanning' (Default)
% 2. soundFile
% 
% Output arguments:
% rampedSound:
% rampingFunction
%

%% Set defaults
if ~exist('ramp','var'); ramp='Hanning'; end
if ~exist('PlotFlag','var'); PlotFlag=0; end
if size(soundFile,1)> size(soundFile,2)
    soundFile = soundFile';
end

%% Calculate ramping function
rampPonits=timeVals(1:(find(timeVals>=rampTime,1))-1);
rampPonits=rampPonits./max(rampPonits);

% create upward ramp
switch ramp
    case 'SquredSine'
        disp(['Applying squared sine ramp of ' num2str(rampTime) ' sec']);
        a=sin(0.5*pi*rampPonits);
        a=(a./max(a)).^2; % squaring the sinusoid smoothens the function at zero
    case 'Hanning'
        disp(['Applying hanning ramp of ' num2str(rampTime) ' sec']);
        a=hanning(length(rampPonits)*2)';
        a = a(1:floor(length(a)/2));
        a=(a./max(a));
end

% static ramp is constant at 1
b=ones(1,(length(timeVals)-(2*(length(a)))));

% downward ramp is time-flipped version of upward to maintain symmetry
c=fliplr(a);

% create ramping function
% The function ramps up from 0 to 1 in time rampTime sec, stays at value 1
% till length(timeVals)-rampTime sec, and ramps down symmetrically as upward ramp in rampTime secs.
rampingFunction=[a b c]; 


%% Plot Ramping Function if PlotFlag
if PlotFlag
    figure(2345); plot(timeVals,rampingFunction);
end
%% Apply Ramping Function: Multiply soundFile with the Ramping Function
if ~isempty(soundFile)
    
    % it is presumed that the sound file is an m*n matrix, n represnting
    % data and m representing channels. Otherwise, invert the matrix
    if size(soundFile,1)> size(soundFile,2)
        soundFile = soundFile';
    end
    
    % element-wise multiplication of each channel. This is useful for
    % lateralisation experiments.
    for i=1:size(soundFile,1)
        rampedSound(i,:)=soundFile(i,:).*rampingFunction;
    end
else
    rampedSound = [];
end

end

%% [normalisedSound] = soundNormalise(originalSound,tag)
% Murty V P S Dinavahi 21/04/2015

function [normalisedSound] = soundNormalise(originalSound,tag)

%% Set defaults
    if ~exist('tag','var'); tag='rms'; end; % Default: rms
    if size(originalSound,1)> size(originalSound,2)
        originalSound = originalSound';
    end

%% Normalise
    for i=1:size(originalSound,1)
        switch tag
            case 'max'
                maxSound = max(abs(originalSound(i,:)));
                
            case 'rms'
                maxSound = rms(originalSound(i,:));
        end
            disp(['rms of original sound: ' num2str(rms(originalSound(i,:)))]);
            normalisedSound(i,:)=originalSound(i,:)/maxSound;
            disp(['rms of normalised sound: ' num2str(rms(normalisedSound(i,:)))]);
    end
end