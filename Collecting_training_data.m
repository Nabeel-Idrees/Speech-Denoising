clc; clear; close all

%Initialization
fsN          = 48000;
overlap_size = 0.01*fsN; % 10 ms overlap
frame_size   = 2*overlap_size; % 20 ms frame size
window       = hanning(frame_size);
n_bits_per_sample = 24;
num_channels = 2;
DesiredTime = 60.0 *60; % 5 minutes (or 5.0*60 seconds)
All_sig   = [];

% Recording voice
disp('Start recording:')
recObj = audiorecorder(fsN, n_bits_per_sample, num_channels)
recordblocking(recObj, DesiredTime);
disp('End of recording.');

captured_signal = getaudiodata(recObj);

%saving the audio file
filename = 'voice_with_driving_noise.mp4';
audiowrite(filename,captured_signal,fsN);

% Normilization
ch1 = captured_signal(:,1) ;
ch2 = captured_signal(:,2);

%Selecting noise segments
ch1_noise_only = ch1(5*fs2:20*fs2,:);
ch1_speech_and_noise = ch1(40*fs2:55*fs2,:);

%Selecting speech segments
ch2_noise_only = ch2(5*fs2:20*fs2,:);
ch2_speech_and_noise = ch2(40*fs2:55*fs2,:);

% SNR calculation for channel 1
avg_speech_and_noise_pow_ch1 = sum(ch1_speech_and_noise.^2);
avg_noise_pow_ch1 = sum(ch1_noise_only.^2);
snr_ch1 = 10*log10(avg_speech_and_noise_pow_ch1/avg_noise_pow_ch1);

% SNR calculation for channel 2
avg_speech_and_noise_pow_ch2 = sum(ch2_speech_and_noise.^2);
avg_noise_pow_ch2 = sum(ch2_noise_only.^2);
snr_ch2 = 10*log10(avg_speech_and_noise_pow_ch2/avg_noise_pow_ch2);