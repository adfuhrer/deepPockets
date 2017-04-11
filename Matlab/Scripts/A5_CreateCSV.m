%==========================================================================
%                               Deep Pockets
%                    5: Creating the .csv to be analyszed
%                                April 2016                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================
FOLDER_NAME = strrep(mfilename('fullpath'),mfilename,'');
if ismac
    backslashes = strfind(FOLDER_NAME,'/');
elseif isunix
    backslashes = strfind(FOLDER_NAME,'/');
elseif ispc
    backslashes = strfind(FOLDER_NAME,'\');
else
    disp('Platform not supported')
end
FOLDER_NAME = FOLDER_NAME(1:backslashes(end-1));
cd(FOLDER_NAME)
addpath(genpath(FOLDER_NAME))
%==========================================================================
close all
clear
%
%==========================================================================
%    Here, we create a single .csv-File that can be used by the Python
%    script to train or test a Neural Network. I hope to write it very
%    mutuable, with the possibility to include different values of data,
%    different time horizons and including dates etc...

%==========================================================================
% I load all the parameters form the Matlab Searchpath.
load('params');
secs = load('SecToSets.mat');
%==========================================================================

% I use the naming convention estabilshed before to get all the data in.
% Using this I can loop thorugh all the years from 1900 to 2100 and it will
% only use the files that are actually available.

% This is used to determine the first year that is in the test set vs. the
% training set (i.e. a value of 2012 indicates that all obs before the year
% 2012 are used to train the set, while all data starting in 2012 is used
% as an out-of-sample performance-test for the network.
trainingVStest = params.cutoffYear{1};
criticalValue = params.criticalValue{1};
varNames = params.VarNames{1};
%firstYear = params.firstYear;
%lastYear = params.lastYear;

% Here, I add the path where the data is stored to the searchpath:
%   DON'T FORGET TO CHAGE BACK!! (This is why I save it in FOLDER_NAME)
FOLDER_NAME = pwd;
cd(params.DATA_SAVE_PATH{1})
addpath(genpath(params.DATA_SAVE_PATH{1}))

% ---------------------->!! INITIALIZATION !!<-----------------------------
trainingSet = [];
testSet = [];
secs = secs.secToSets;
nrRandomSets = max(secs(:,4));
nrChosenSets = max(secs(:,5));
for rs=1:nrRandomSets
    randomSetCollection{rs}=[];
end
for cs=1:nrChosenSets
    chosenSetCollection{cs}=[];
end


for y = 1900:2100%firstYear:lastYear
    if exist(strcat('Output/Year_',int2str(y),'.mat'), 'file') == 2
        disp(y);
        
        %------ OLD ----------
        %if y < trainingVStest
        %    test = false;
        %else
        %    test = true;
        %end
        %------ New ----------
        % Dividing into multiple Test Sets, see below
        
        
        % Here we consruct the set. Any changes can be directly implemented
        % in this block:
        %==================================================================
        
        %-! data = eval(['Y',int2str(y),'Data']);
        %-! ret = eval(['Y',int2str(y),'Returns']);
        %-! culmRet = eval(['Y',int2str(y),'CulmReturns']);
        %-! zScoreRet = eval(['Y',int2str(y),'ZScoreReturns']);
        %-! zScoreCulmRet = eval(['Y',int2str(y),'ZScoreCulmReturns']);
        
        % I need the following elements in my .csv-File:
        load(strcat('Output/Year_',int2str(y),'.mat'));
        
        %-1 The ISIN of the Stocks (C1)
        %   It is probably best to store this in a cell array of strings
        %   until the very end, since otherwise I need to create tables,
        %   slowing down the code a lot.
        UniqueID = cSet(:,1);
        
        clear cSet
        
        %-2 Month and Year of the stock (C2 and C3)
        %   I use the set that we will use in the next step to get the
        %   dummy as well:
        load(strcat('Output/Year_',int2str(y),'Returns.mat'));
        MoYear = Returns(:,1:2);
        %-3 Dummy if it goes up (C4)
        Up = (Returns(:,4) > 0);
        load(strcat('Output/Year_',int2str(y),'MVReturns.mat'));
        MVMMatrix = cell2mat(table2array(MVMReturns(:,2:end)));
        medians = MVMMatrix(3:3:end,[1,4]);
        medianss = NaN(12,2);
        for m=1:12
            if sum(medians(:,1)==m)==0
                medianss(m,:) = NaN(1,2);
            else
                medianss(m,:) = medians(medians(:,1)==m,:);
            end
        end
        medianss = medianss(Returns(:,1),2);
        AboveMedian = (Returns(:,4)>medianss);
        ReturnsColumn = Returns(:,4);   % <---------- FOR PIXEL!!
        clear Returns
        
        %-4 Dummy if it is top/flop 5% (C5)
        %   For this we need the z-scores. If the z-score is bigger than
        %   +1.6449, it's in the 5% best, if it is below -1.6449, it is in
        %   the worst 5%.
        load(strcat('Output/Year_',int2str(y),'ZScoreReturns.mat'));
        bestOrWorst = double(ZScoreReturns(:,4) > criticalValue);
        bestOrWorst(ZScoreReturns(:,4) < -criticalValue)=-1;
        bestOrWorst= bestOrWorst+1;
        
        clear ZScoreReturns
        %-5 Actual Data, without the Date-specifier (C6-End)
        %   Here I use Z-Scores's for all the packages, but this can easily be
        %   changed to any desired setting:
        %   This creates a vector of the coulmns we want to use. We ignore
        %   the dates.
        %   IMPORTANT: I exclude the future observation! It is not in
        %   there! Only the dummy that indicates up/down or best/worst are
        %   in there, and they are obviously based on these observatinos,
        %   but I do not include the actual obs. That would be too simple.
        load(strcat('Output/Year_',int2str(y),'ZScoreCulmReturns.mat'));
        indices = 4 + 2.*[1:floor(size(ZScoreCulmReturns,2)/2-3)];
        dataPoints = ZScoreCulmReturns(:,indices);
        
        % Putting it all together:               FOR PIXEL---|____________
        temp = [dataPoints, UniqueID, MoYear, Up, bestOrWorst, ReturnsColumn, AboveMedian];
        
        % Matching in the Information on the sets:
        [~,rowsOfSecs] = ismember(temp(:,36),secs(:,1)); %Change if poition of ID cahnges
        temp = [temp, secs(rowsOfSecs,4:end)];
        killCols = size(secs(rowsOfSecs,4:end),2);
        
        for rs=1:nrRandomSets
            randomSetCollection{rs}=[randomSetCollection{rs};temp(temp(:,end-2)==rs,1:end-killCols)];
        end
        for cs=1:nrChosenSets
            chosenSetCollection{cs}=[chosenSetCollection{cs};temp(temp(:,end-1)==cs,:)];
        end
        trainingSet = [trainingSet;temp(temp(:,end)==1,:)];
        
        %==================================================================
        clearvars -except y trainingVStest trainingSet chosenSetCollection randomSetCollection criticalValue params secs nrRandomSets nrChosenSets
    end
end

% I do not do this anymore. It consumes way to many resources for what it
% actually is. I do no longer save to csv, but only store it as a .mat
% file.
%==========================================================================
%{ 
testSet = cell2table(num2cell(testSet));
trainingSet = cell2table(num2cell(trainingSet));
 
if size(testSet,2)>2 
    testSet.Properties.VariableNames{'Var1'} = ['N',int2str(size(testSet,1))];
    testSet.Properties.VariableNames{'Var2'} = ['N',int2str(size(testSet,2)-1)];
end

if size(trainingSet,2)>2
    trainingSet.Properties.VariableNames{'Var1'} = ['N',int2str(size(trainingSet,1))];
    trainingSet.Properties.VariableNames{'Var2'} = ['N',int2str(size(trainingSet,2)-1)];
end

% saving to .csv, for the network to read:
mkdir('homerun');
writetable(trainingSet,strcat(['homerun/training',params.nameSuffixOfSet{1},'.csv']));
clear trainingSet
writetable(testSet,strcat('homerun/test',params.nameSuffixOfSet{1},'.csv'));
%}
%==========================================================================
% NEW, directly to .mat:
mkdir('homerun');
if params.STORE_DOT_MAT{1}
    for i=1:size(randomSetCollection,2)
        randomSet = randomSetCollection{i}; 
        save(strcat('homerun/random',params.nameSuffixOfSet{1},'_',int2str(i),'.mat'),'randomSet','-v7.3');
    end
    for i=1:size(chosenSetCollection,2)
        chosenSet = chosenSetCollection{i}; 
        save(strcat('homerun/chosen',params.nameSuffixOfSet{1},'_',int2str(i),'.mat'),'chosenSet','-v7.3');
    end
    save(strcat('homerun/training',params.nameSuffixOfSet{1},'.mat'),'trainingSet','-v7.3');
end
