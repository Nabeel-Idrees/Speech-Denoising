clc; clear; close all

% Load audio file
fname = 'E:/Speech_Denoising/Data/noisyAudio_5dB_1hr_driving_noise_training.wav';

% Read audio file
[data, fsN] = audioread(fname);

% Initialization
% fsN = 48000;
overlap_size = 0.01*fsN; % 10 ms overlap
frame_size = 2*overlap_size; % 20 ms frame size
window = hanning(frame_size);

% Normilization
ch1 = data(:, 1);
ch2 = data(:, 2);

ch1 = ch1./max(ch1);
ch2 = ch2./max(ch2);

% Discard extra samples from end
% N_new = floor(length(ch1)/(overlap_size/3))*(overlap_size/3);
N_new = floor(length(ch1)/(overlap_size))*(overlap_size);
ch1 = ch1(1:N_new);
ch2 = ch2(1:N_new);

%plot channels
subplot(211)
plot(ch1);
title('Channel 1');
axis tight

subplot(212)
plot(ch2);
title('Channel 2');
axis tight

%framing
frames_ch1 = frame_sig(ch1, frame_size, overlap_size, @hanning)';
frames_ch2 = frame_sig(ch2, frame_size, overlap_size, @hanning)';

% saving frames
save('E:/Speech_Denoising/training_1_ch1.mat', 'frames_ch1')
disp('done writing frames for channel 1!')

save('E:/Speech_Denoising/training_1_ch2.mat', 'frames_ch2')
disp('done writing frames for channel 2!')
