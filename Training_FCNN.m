clc;
% clearvars;
close all;

% load training_1_ch1
% load training_1_ch2

%Initialization
X = frames_ch1;
Y = frames_ch2;

% Defining targets and predictors
targets = reshape(X, size(X, 1), 1, 1, size(X, 2));
predictors = reshape(Y, size(Y, 1), 1, 1, size(Y, 2));

%Initializing the parameters of the network
filter_size = [30 1]; %50 1
n_filter = 55; % 75
%initial learning rate = 0.004

layers = [
    imageInputLayer([size(Y, 1), 1],"Name","imageinput")
    
    convolution2dLayer(filter_size, n_filter,"Name","conv_1","Padding","same")
    batchNormalizationLayer("Name", "batchnorm_1")
    reluLayer("Name","relu_1")
    
    convolution2dLayer(filter_size, n_filter,"Name","conv_2","Padding","same")
    batchNormalizationLayer("Name", "batchnorm_2")
    reluLayer("Name","relu_2")
    
    convolution2dLayer(filter_size, n_filter,"Name","conv_3","Padding","same")
    batchNormalizationLayer("Name", "batchnorm_3")
    reluLayer("Name","relu_3")
    
    convolution2dLayer(filter_size, n_filter,"Name","conv_4","Padding","same")
    batchNormalizationLayer("Name", "batchnorm_4")
    reluLayer("Name","relu_4")
    
    convolution2dLayer(filter_size, n_filter,"Name","conv_5","Padding","same")
    batchNormalizationLayer("Name", "batchnorm_5")
    reluLayer("Name","relu_5")
    
    % Added convolutional layer
%     convolution2dLayer(filter_size, n_filter,"Name","conv_6","Padding","same")
%     batchNormalizationLayer("Name", "batchnorm_6")
%     reluLayer("Name","relu_6")
   
    convolution2dLayer([1, 1], 1,"Name","conv_21","Padding","same")
    regressionLayer("Name","regressionoutput")];

%Specify training options
options = trainingOptions("adam", ...
    "MaxEpochs", 25, ...
    "InitialLearnRate", .0004,...
    "MiniBatchSize", 512, ...
    "Plots", "training-progress", ...
    'ExecutionEnvironment','gpu');

%Train the neural network
net = trainNetwork(predictors, targets, layers, options);

%saving the network
save('E:/Speech_Denoising/trainedNet.mat', 'net')









