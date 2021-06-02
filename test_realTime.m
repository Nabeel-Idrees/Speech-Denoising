% clc; clear; close all
filename = 'D:/Speech_Denoising/Data/voice_with_driving_noise_testing.mp4';
% filename = 'D:/Speech_Denoising/Data/drivingsample.mp4';

[All_sig, fsN] = audioread(filename);

% Initialization
overlap_size = 0.01*fsN; % 10 ms overlap
frame_size   = 2*overlap_size; % 20 ms frame size
window       = hanning(frame_size);

% Normilization
ch1 = All_sig(:,1) ;
ch2 = All_sig(:,2);

ch1 = ch1 ./ max(ch1);
ch2 = ch2 ./ max(ch2);

% Resampling (Down-sampling)
fs2 = 16000;
ch1 = resample(ch1(:,1), fs2, fsN); % resample 48 KHz to 16 KHz
ch2 = resample(ch2(:,1), fs2, fsN); % resample 48 KHz to 16 KHz

% Framing the audio
frames_ch1 = frame_sig( ch1, frame_size/3, overlap_size/3, @hanning )';
frames_ch2 = frame_sig( ch2, frame_size/3, overlap_size/3, @hanning )';

frames_ch = frames_ch1;

% Test using trained network
predictors = reshape(frames_ch, [size(frames_ch, 1), 1, 1, size(frames_ch, 2)]);
denoisedFrames = predict(net, predictors);
denoisedFrames = squeeze(denoisedFrames);

% Deframe
denoisedAudio = deframe_sig(denoisedFrames.', length(ch1), 320, 160, @hanning);

% Resampling (Up-sampling)
denoisedAudio = resample(denoisedAudio, fsN, fs2); % resample 48 KHz to 16 KHz

% Plots
h=figure;

subplot(211)

ty = 0:length(All_sig)-1;
ty = ty./fsN;

plot(ty(20:100000), All_sig(20:100000))
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

saveas(h,'voice_with_driving_noise_testing_denoised_fig','jpg')
% saveas(h,'drivingsample_denoised_fig','jpg')

%saving the audio file
filename = 'D:/Speech_Denoising/Data/voice_with_driving_noise_testing_denoised.mp4';
% filename = 'D:/Speech_Denoising/Data/Sdrivingsample_denoised.mp4';
audiowrite(filename,denoisedAudio,fsN);




