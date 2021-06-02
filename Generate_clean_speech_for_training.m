clc;
clearvars;
close all;

%Initialization
fsN = 48000;
fs2 = 16000;

%File names
k = {'D:/DS_10283_2651/VCTK-Corpus/VCTK-Corpus/wav48/p237/', 'D:/DS_10283_2651/VCTK-Corpus/VCTK-Corpus/wav48/p238/', 'D:/DS_10283_2651/VCTK-Corpus/VCTK-Corpus/wav48/p239/','D:/DS_10283_2651/VCTK-Corpus/VCTK-Corpus/wav48/p361/', 'D:/DS_10283_2651/VCTK-Corpus/VCTK-Corpus/wav48/p362/', 'D:/DS_10283_2651/VCTK-Corpus/VCTK-Corpus/wav48/p363/'};
k = string(k);

% Load audio files for augmentation
for i = 1:numel(k)
    folder = k(1,i);
    audio_files=dir(fullfile(folder, '*.wav'));

    %Augmenting clean speech of same person
    y = augment_clean_speech(folder, audio_files, fsN); 

    %Preprocess clean speech
    speech_ch = process_clean_speech(y, fsN, fs2);
    
    %Randomizing amount of speech to be included from different speakers
    if i==1
        speech_ch1 = speech_ch;
    elseif i==4
        speech_ch1 = cat(1, speech_ch1, speech_ch);
    elseif i==2 || i==5
        speech_ch1 = cat(1, speech_ch1, speech_ch(7*60*fs2:15*60*fs2,1));
    else
        speech_ch1 = cat(1, speech_ch1, speech_ch(10*60*fs2:15*60*fs2,1));       
    end
end

% Writing clean speech
f_name = 'clean_speech.wav';
audiowrite(f_name,speech_ch1, fs2);

%Augmenting clean speech of same person
function y = augment_clean_speech(folder, audio_files, fsN)
    for k=1:numel(audio_files)
        fileLocation = strcat(folder, audio_files(k).name);
        [yTemp, fsnTemp] = audioread(fileLocation);
        fsN = max([fsN, fsnTemp]);
        if k == 1
            y = yTemp;
        else
            y = cat(1, y, yTemp);
        end
    end
end

%Preprocess clean speech
function speech_ch = process_clean_speech(y, fsN, fs2)
    % Normilization of speech signal
    speech_ch1 = y; %48KHz
    speech_ch1 = speech_ch1./max(speech_ch1);

    % Resampling (Down-sampling) speech signal
    speech_ch = resample(speech_ch1(:, 1), fs2, fsN); 
end