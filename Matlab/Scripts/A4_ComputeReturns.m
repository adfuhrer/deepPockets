%==========================================================================
%                               Deep Pockets
%               4: From the basic sets, returns are computed.
%                               February 2017                       
%--------------------------------------------------------------------------
%                              Adrian Fuhrer
%==========================================================================
FOLDER_NAME = strrep(mfilename('fullpath'),mfilename,'');
cd(FOLDER_NAME)
addpath(genpath(FOLDER_NAME))
%==========================================================================
close all
clear
%
%==========================================================================
%
%  
load('params');
firstYear = params.firstYear;
lastYear = params.lastYear;
disp('Using Price-Data to compute and save all Data per year:');

% Here, I add the path where the data is stored to the searchpath:
cd(DATA_SAVE_PATH)
addpath(genpath(DATA_SAVE_PATH))

% ---------------------->!! INITIALIZATION !!<-----------------------------
nanMonitor = [(firstYear:lastYear)', nan(lastYear-firstYear+1,2)];
% -------------------------->!! LOOP !!<-----------------------------------
for y = firstYear:lastYear
    disp(y);
    if exist(strcat('Output/Year_',int2str(y),'.mat'), 'file') == 2
        load(strcat('Output/Year_',int2str(y),'.mat'));
    end
    Returns = getReturns(cSet);
    CulmReturns = getCulmulativeReturns(Returns);
    MVReturns = getMeanVariance(Returns);
    MVCulmReturns = getMeanVariance(CulmReturns);
    [ZScoreReturns, nanMonitor(y-firstYear+1,2)] = getZScore(Returns,MVReturns);
    [ZScoreCulmReturns, nanMonitor(y-firstYear+1,3)] = getZScore(CulmReturns,MVCulmReturns);
    save(strcat('Output/Year_',int2str(y),'Returns.mat'),'Returns','-v7.3');
    save(strcat('Output/Year_',int2str(y),'CulmReturns.mat'),'CulmReturns','-v7.3');
    save(strcat('Output/Year_',int2str(y),'MVReturns.mat'),'MVReturns','-v7.3');
    save(strcat('Output/Year_',int2str(y),'MVCulmReturns.mat'),'MVCulmReturns','-v7.3');
    save(strcat('Output/Year_',int2str(y),'ZScoreReturns.mat'),'ZScoreReturns','-v7.3');
    save(strcat('Output/Year_',int2str(y),'ZScoreCulmReturns.mat'),'ZScoreCulmReturns','-v7.3');
    clearvars -except y firstYear lastYear nanMonitor
end
disp('In the following years, some z-scores had to be replaced with 0 due to too few observations:')
nanMonitor = nanMonitor(nanMonitor(:,3)>0,:)