%==========================================================================
%                               Deep Pockets
%                    4: Creating the .csv to be analyszed
%                                April 2016                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================
cd('/Users/adrian/Dropbox/MatlabForDeep')
addpath(genpath('/Users/adrian/Dropbox/MatlabForDeep'))
%==========================================================================
close all
clear
clc
%
%==========================================================================
%    Here, we create a single .csv-File that can be used by the Python
%    script to train or test a Neural Network. I hope to write it very
%    mutuable, with the possibility to include different values of data,
%    different time horizons and including dates etc...

%==========================================================================
% I load all the parameters and the Ticker list form the Matlab Searchpath.
load('params');

%==========================================================================

% I use the naming convention estabilshed before to get all the data in.
% Using this I can loop thorugh all the years from 1900 to 2100 and it will
% only use the files that are actually available.

% This is used to determine the first year that is in the test set vs. the
% training set (i.e. a value of 2012 indicates that all obs before the year
% 2012 are used to train the set, while all data starting in 2012 is used
% as an out-of-sample performance-test for the network.
trainingVStest = 2014;
%
trainingSet = [];
testSet = [];

for y = 1900:2100
    disp(y);
    if exist(strcat('Output/Year_',int2str(y),'.mat'), 'file') == 2
        load(strcat('Output/Year_',int2str(y),'.mat'));
    end
    if exist(['Y',int2str(y)],'var')
        if y < trainingVStest
            test = false;
        else
            test = true;
        end
        
        % Here we consruct the set. Any changes can be directly implemented
        % in this block:
        %==================================================================
        %-! data = eval(['Y',int2str(y),'.Data']);
        %-! ret = eval(['Y',int2str(y),'.Returns']);
        culmRet = eval(['Y',int2str(y),'.CulmReturns']);
        %-! zScoreRet = eval(['Y',int2str(y),'.ZScoreReturns']);
        %-! zScoreCulmRet = eval(['Y',int2str(y),'.ZScoreCulmReturns']);
        
        % Here I use culmRet's for all the packages, but this can easily be
        % changed to any desired setting:
        
        % This creates a vector of the coulmns we want to use. We ignore
        % the dates, but include a month-indicator
        indices = 3 + 2.*[1:floor(size(culmRet,2)/2-1)];
        indices = [2 indices];
        temp = culmRet(:,indices);
        temp.Class = (cell2mat(temp.Future) > cell2mat(temp.Day1));
        if test 
            testSet = vertcat(testSet,temp);
        else
            trainingSet = vertcat(trainingSet,temp);
        end
        
        %==================================================================
        clearvars -except y trainingVStest trainingSet testSet
    end
end
testSet.Properties.VariableNames{'month'} = ['N',int2str(size(testSet,1))];
testSet.Properties.VariableNames{'Future'} = ['N',int2str(size(testSet,2)-1)];

trainingSet.Properties.VariableNames{'month'} = ['N',int2str(size(trainingSet,1))];
trainingSet.Properties.VariableNames{'Future'} = ['N',int2str(size(trainingSet,2)-1)];

% saving to .csv, for the network to read:
mkdir('homerun');
writetable(trainingSet,strcat('homerun/training_full2014.csv'));
clear trainingSet
writetable(testSet,strcat('homerun/test_full2014.csv'));