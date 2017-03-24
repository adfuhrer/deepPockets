%==========================================================================
%                               Deep Pockets
%                         1: A simple Neural Network
%                                M?rz 2017                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================
FOLDER_NAME = strrep(mfilename('fullpath'),mfilename,'');
cd(FOLDER_NAME)
addpath(genpath(FOLDER_NAME))
%==========================================================================
close all
clear
clc
%
%==========================================================================
% I follow closely a tutorial by Matlab that can be brought up with
% openExample('nnet/AutoencoderDigitsExample')
%--------------------------------------------------------------------------
load('params')
DATA_SAVE_PATH          = params.DATA_SAVE_PATH{1};
% Loading the data:
FOLDER_NAME = pwd;
cd(DATA_SAVE_PATH)
addpath(genpath(DATA_SAVE_PATH))
load('training_newWithFutureValue.mat')
% Notice the transpose on the training Data, as the Function takes samples 
% on columns, not lines.
features = trainingSet(:,1:35)';
labelUpDown = trainingSet(:,39)';
clear trainingSet

%--------------------------------------------------------------------------
%%                   FIRST LAYER (unsupervised)
hiddenSize1 = 20;
% This is basically the magic sauce that we apply...
% Parameters are used like in the tutorial so far.
autoenc1 = trainAutoencoder(features',hiddenSize1, ...
    'MaxEpochs',400, ...
    'L2WeightRegularization',0.004, ...
    'SparsityRegularization',4, ...
    'SparsityProportion',0.15, ...
    'ScaleData', false);
% Here, I extract the compressed representation of the data. Notice, again,
% the transpose on the features.
feat1 = encode(autoenc1,features');

%%--------------------------------------------------------------------------
%%                   SECOND LAYER (unsupervised)
hiddenSize2 = 12;
autoenc2 = trainAutoencoder(feat1,hiddenSize2, ...
    'MaxEpochs',400, ...
    'L2WeightRegularization',0.002, ...
    'SparsityRegularization',4, ...
    'SparsityProportion',0.1, ...
    'ScaleData', false);

feat2 = encode(autoenc2,feat1);

%%--------------------------------------------------------------------------
%%                   THIRD LAYER (supervised)

softnet = trainSoftmaxLayer(feat2,labelUpDown,'MaxEpochs',400);
deepnet = stack(autoenc1,autoenc2,softnet);