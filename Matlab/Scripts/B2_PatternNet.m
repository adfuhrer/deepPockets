%==========================================================================
%                               Deep Pockets
%                  2: A simple Pattern-Regocnition-Network
%                                Marz 2017                       
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
labelUpDown = trainingSet(:,39);

clear trainingSet labelUp labelDown

%--------------------------------------------------------------------------
%%                   GENERATING AN EMPTY NETWORK
deepnet = patternnet([50 40 30 20 10]);
view(deepnet)

%%--------------------------------------------------------------------------
%%                   TRAINING THE NETWORK (supervised)
deepnet = train(deepnet,features,labelUpDown');


%%--------------------------------------------------------------------------
%%                   PERLIMINARY PERFORMANCE ATTRIBUTION
% We start by loading the test set:

load('test_newWithFutureValue.mat')
% Notice the transpose on the training Data, as the Function takes samples 
% on columns, not lines.
featuresTest = testSet(:,1:35)';
labelUpDownTest = testSet(:,39);%labelUpTest = (testSet(:,39)'==1);
returns = testSet(:,end);
%labelDownTest = not(labelUpTest);
%labelUpDownTest = [labelUpTest;labelDownTest];
clear testSet

y = deepnet(featuresTest);
% I scale y by the prior probabilities:
%y = (y.*0.5)./(mean(labelUpDownTest));

plotconfusion(labelUpDownTest',y);
returns2=returns';
returns2(returns>1)=0;

scatter(returns2,y)

% fit the regression, return the coeffs and their se's
stats = regstats(y,returns2,'linear',{'tstat','yhat'})
betahat = stats.tstat.beta
betaSE = stats.tstat.se

% compute r-squared
yhat = stats.yhat;
RSS = sum((yhat-mean(y)).^2); % regression sum of squares
TSS = sum((y-mean(y)).^2); % total sum of squares
rsquared = RSS ./ TSS

figure;
scatter(returns2,y);
lsline
