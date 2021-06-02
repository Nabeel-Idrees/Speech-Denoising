clc;
clearvars;
close all;

% Initialization
fsN = 48000;
fs2 = 16000;

%Load the speech signal (at 16KHz)
[speech_ch1, fsN1] = audioread('C:/Users/Montu/Desktop/Speech_Denoising/Data/clean_speech.wav');

%Load the noise signal
[noise_sig, fsn] = audioread('C:/Users/Montu/Desktop/Speech_Denoising/Data/Noise/babble noise_35min_Nabeel.mp4');

%Preprocess noise signal
[noise_ch1, noise_ch2] = process_noise(noise_sig, fsn, fs2);

% Make the length of noise signal same as speech signal
noise_ch1 = noise_ch1(1:size(speech_ch1),1);
noise_ch2 = noise_ch2(1:size(speech_ch1),1);

%Adding noise at 5dB SNR
noise = [noise_ch1 noise_ch2];
signal = speech_ch1;
snr = 10;

% Adding noise to signal
[ noisy, noise ] = addnoise( signal, noise, snr );

% Writing to audio file
audiowrite('noisyAudio_10dB_1hr_babble_noise_training.wav',noisy, fs2);

% Plotting
speech_ch1_new = speech_ch1(1:100000,:);
noisy_new = noisy(1:100000,:);

t = (1/fs2) * (0:numel(speech_ch1_new)-1);
subplot(2,1,1)
plot(t,speech_ch1_new)
title("Clean Audio")
grid on

subplot(2,1,2)
plot(t,noisy_new)
title("Noisy Audio")
xlabel("Time (s)")
grid on


% calculate correlation 
corr2(noise_ch1((1:100000),1),noise_ch2((1:100000),1))

%Preprocess noise signal
function [noise_ch1, noise_ch2] = process_noise(noise_sig, fsn, fs2)
    %Dividing half of the noise channel for speech channel 1, 2nd half for
    %speech channel 2
    noise_sig = noise_sig(:,1);
    noise_audio_len = ((size(noise_sig, 1)/fsn)/60) - mod(((size(noise_sig, 1)/fsn)/60),floor(((size(noise_sig, 1)/fsn)/60)));
    mid = noise_audio_len/2;

    noise_ch1_half = noise_sig(1:mid*60*fsn,1);
    noise_ch2_half = noise_sig((mid*60*fsn+1):noise_audio_len*60*fsn,1);

    %randomly generate start point to take 1 min chunks of noise signal 
    rand_noise_ch1_half = randi([1 ((mid-1)*60*fsn)],1,70);
    rand_noise_ch2_half = randi([(mid*60*fsn+1) ((noise_audio_len-1)*60*fsn)],1,70)-size(noise_ch1_half,1);

    %Creating new noise signal using the radomly taken 1min noise segments for
    %channel 1
    for k=1:numel(rand_noise_ch1_half)
        temp = noise_ch1_half(rand_noise_ch1_half(1,k):(rand_noise_ch1_half(1,k)+(fsn*60)),1);
        if k == 1
            noise_ch1 = temp;
        else
            noise_ch1 = cat(1, noise_ch1, temp);
        end
    end

    %Creating new noise signal using the radomly taken 1min noise segments for
    %channel 2
    for k=1:numel(rand_noise_ch2_half)
        temp = noise_ch2_half(rand_noise_ch2_half(1,k):(rand_noise_ch2_half(1,k)+(fsn*60)),1);
        if k == 1
            noise_ch2 = temp;
        else
            noise_ch2 = cat(1, noise_ch2, temp);
        end
    end

    % Normilization of noise signal
    noise_ch1 = noise_ch1./max(noise_ch1);
    noise_ch2 = noise_ch2./max(noise_ch2);

    % Resampling (Down-sampling) noise signal
    noise_ch1 = resample(noise_ch1(:, 1), fs2, fsn); %resample 44 KHz to 16 KHz
    noise_ch2 = resample(noise_ch2(:, 1), fs2, fsn); %resample 44 KHz to 16 KHz
end


function [ noisy, noise ] = addnoise( signal, noise, snr )
% ADDNOISE Add noise to signal at a prescribed SNR level.
%
%   [NOISY,NOISE]=ADDNOISE(SIGNAL,NOISE,SNR) adds NOISE to SIGNAL
%   at a prescribed SNR level. Returns the mixture signal as well 
%   as scaled noise such that NOISY=SIGNAL+NOISE.
%   
%   Inputs
%           SIGNAL is a target signal as vector.
%
%           NOISE is a masker signal as vector, such that 
%                 length(NOISE)>=length(SIGNAL). Note that 
%                 in the case that length(NOISE)>length(SIGNAL),
%                 a vector of length length(SIGNAL) is selected 
%                 from NOISE starting at a random sample number.
%           
%           SNR is the desired signal-to-noise ratio level (dB).
%
%   Outputs 
%           NOISY is a mixture signal of SIGNAL and NOISE at given SNR.
%
%           NOISE is a scaled masker signal, such that the mixture
%                 NOISY=SIGNAL+NOISE has the desired SNR.

    % needed for older realases of MATLAB
    randi = @(n)( round(1+(n-1)*rand) );

    % ensure masker is at least as long as the target
    S = length( signal );
    N = length( noise );
    if( S>N ), error( 'Error: length(signal)>length(noise)' ); end;

    % generate a random start location in the masker signal
    R = randi(1+N-S);

    % extract random section of the masker signal
    noise = noise(R:R+S-1,:);

    % scale the masker w.r.t. to target at a desired SNR level
    noise = noise / norm(noise) * norm(signal) / 10.0^(0.05*snr);

    % generate the mixture signal
    noisy = signal + noise;
end

