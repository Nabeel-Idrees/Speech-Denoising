clc
clearvars
% close all

load trainedNet

% Load audio file
filename = 'D:/Speech_Denoising/Data/noisyAudio_8dB_6min_driving_noise_testing.wav';
[y, fsN] = audioread(filename);

% Initialization
overlap_size = 0.01*fsN; % 10 ms overlap
frame_size = 2*overlap_size; % 20 ms frame size
window = hanning(frame_size);

% Normilization
ch = y(:, 1);
ch = ch./max(ch);

% Framing the audio
frames_ch = frame_sig(ch, 320, 160, @hanning)';

% Test using trained network
predictors = reshape(frames_ch, [size(frames_ch, 1), 1, 1, size(frames_ch, 2)]);
denoisedFrames = predict(net, predictors);
denoisedFrames = squeeze(denoisedFrames);

% Deframe
denoisedAudio = deframe_sig(denoisedFrames.', length(ch), 320, 160, @hanning);

% Plots
h=figure;

subplot(211)

ty = 0:length(y)-1;
ty = ty./fsN;

plot(ty(20:100000), y(20:100000))
title("Example Speech Signal")
xlabel("Time (s)")
grid on
axis tight


subplot(212)

tDy = 0:length(denoisedAudio)-1;
tDy = tDy./fsN;

plot(tDy(20:100000), denoisedAudio(20:100000))
title("Denoised Speech Signal")
xlabel("Time (s)")
grid on
axis tight

saveas(h,'noisyAudio_8dB_6min_driving_noise_testing_denoised_fig','jpg')

%saving the audio file
filename = 'D:/Speech_Denoising/Data/noisyAudio_8dB_6min_driving_noise_testing_denoised.wav';
audiowrite(filename,denoisedAudio,fsN);










